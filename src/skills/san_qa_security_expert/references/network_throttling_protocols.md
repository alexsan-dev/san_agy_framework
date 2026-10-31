# Protocoles de Throttling Réseau 3G / EDGE & Simulation Dégradée
# Framework Antigravity (`san_*`) — Moteur `san_qa_security_expert`

Ce document technique définit les spécifications et helpers Playwright CDP (Chrome DevTools Protocol) pour éprouver la résilience des interfaces et flux transactionnels sous réseau mobile dégradé (Afrique subsaharienne / 3G instable).

---

## 1. PROFIL OFFICIEL 3G SUBSAHARIENNE

| Paramètre | Valeur Standard | Justification |
| :--- | :---: | :--- |
| **Download Throughput** | 750 kbps (93 750 B/s) | Débit descendant moyen en zone urbaine dense dégradée |
| **Upload Throughput** | 250 kbps (31 250 B/s) | Débit montant sous forte contention réseau |
| **Latence RTT** | 150 ms | Temps d'aller-retour paquet standard sur antenne 3G |

---

## 2. HELPERS PLAYWRIGHT CDP

```typescript
// tests/e2e/helpers/networkThrottling.ts
import { Page, CDPSession } from '@playwright/test';

export interface NetworkProfile {
  name: string;
  downloadThroughput: number; // octets/seconde
  uploadThroughput: number;   // octets/seconde
  latency: number;            // millisecondes
}

export const PROFILE_3G_AFRICA: NetworkProfile = {
  name: '3G_SLOW_EDGE',
  downloadThroughput: (750 * 1024) / 8, // 750 kbps
  uploadThroughput: (250 * 1024) / 8,   // 250 kbps
  latency: 150,                         // 150ms RTT
};

/**
 * Applique le profil de throttling réseau via une session CDP Chrome DevTools.
 */
export async function applyNetworkThrottling(
  page: Page,
  profile: NetworkProfile = PROFILE_3G_AFRICA
): Promise<CDPSession> {
  const client: CDPSession = await page.context().newCDPSession(page);

  await client.send('Network.enable');
  await client.send('Network.emulateNetworkConditions', {
    offline: false,
    latency: profile.latency,
    downloadThroughput: profile.downloadThroughput,
    uploadThroughput: profile.uploadThroughput,
    connectionType: 'cellular3g',
  });

  return client;
}

/**
 * Simule une coupure brutale et totale de la connectivité réseau.
 */
export async function simulateNetworkCut(client: CDPSession): Promise<void> {
  await client.send('Network.emulateNetworkConditions', {
    offline: true,
    latency: 0,
    downloadThroughput: 0,
    uploadThroughput: 0,
    connectionType: 'none',
  });
}

/**
 * Rétablit la connectivité réseau sous profil 3G standard.
 */
export async function restoreNetwork(
  client: CDPSession,
  profile: NetworkProfile = PROFILE_3G_AFRICA
): Promise<void> {
  await client.send('Network.emulateNetworkConditions', {
    offline: false,
    latency: profile.latency,
    downloadThroughput: profile.downloadThroughput,
    uploadThroughput: profile.uploadThroughput,
    connectionType: 'cellular3g',
  });
}
```

---

## 3. CHECKLIST DE RÉSILIENCE SOUS 3G

- [ ] **Zéro écran blanc :** Skeleton immédiat (< 100 ms) sans détruire les données existantes (*Stale-While-Revalidate*).
- [ ] **Idempotence des actions :** En-tête `Idempotency-Key: [UUID]` sur toute transaction financière ou commande.
- [ ] **Tolérance aux pannes :** Message non-bloquant informant de la file d'attente locale lors d'une déconnexion.
- [ ] **Reprise transparente :** Déstockage ordonné de l'Outbox locale dès rétablissement de la liaison.
