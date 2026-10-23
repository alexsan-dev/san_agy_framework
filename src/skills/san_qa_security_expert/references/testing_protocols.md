# Protocoles de Tests E2E Déterministes & Résilience Réseau Dégradé

Ce guide opérationnel documente les règles, conventions et architectures de suites de tests de bout en bout (E2E) exigées par `san_qa_security_expert` au sein du framework Antigravity (`san_*`).

---

## 1. PRINCIPES DE DÉTERMINISME DES TESTS E2E

Les tests intermittents (*flaky tests*) sont formellement bannis du cycle de validation. Pour assurer une répétabilité déterministe à 100 % :

### Règle 1 : Interdiction des `sleep()` ou Temporisations Arbitraires
- **Interdit :** `await page.waitForTimeout(3000)` ou `sleep(2)`.
- **Obligatoire :** Attente explicite des états de l'application via les assertions automatiques de Playwright :
  ```typescript
  // Attente déterministe de la disparition du skeleton et de l'affichage du libellé
  await expect(page.locator('[data-testid="skeleton-order"]')).toHaveCount(0);
  await expect(page.locator('[data-testid="order-confirmed-banner"]')).toBeVisible({ timeout: 5000 });
  ```

### Règle 2 : Sélecteurs Résilients Dédiés aux Tests
- Les sélecteurs basés sur des classes CSS dynamiques (Tailwind) ou des structures XPath complexes sont proscrits.
- Utiliser impérativement des attributs stables : `data-testid="..."`, `aria-label`, ou des rôles sémantiques accessibles :
  ```typescript
  // Sélecteur recommandé
  await page.getByTestId('btn-submit-momo').click();
  await page.getByRole('button', { name: /valider le paiement/i }).click();
  ```

### Règle 3 : Isolation Complète des Données de Test
- Chaque suite de tests initialise et nettoie son état :
  - Soit via une base de données de test éphémère (`sqlite::memory:` ou conteneur PostgreSQL isolé).
  - Soit via des fixtures Playwright générant des identifiants uniques (UUIDv4) pour chaque exécution afin d'interdire les collisions d'états.

---

## 2. MATRICE DE TESTS À 4 DIMENSIONS

Chaque parcours utilisateur critique doit être évalué selon une matrice rigoureuse couvrant quatre dimensions :

| Dimension | Objectif | Exemples de Scénarios |
| :--- | :--- | :--- |
| **1. Parcours Nominal** | Valider la fluidité du flux idéal sans erreur. | Inscription d'un utilisateur avec OTP valide $\rightarrow$ Ajout au panier $\rightarrow$ Validation Mobile Money avec solde suffisant. |
| **2. Conditions aux Limites** | Éprouver le système face aux saisies inhabituelles ou extrêmes. | Saisie d'un montant de 0 FCFA ou 50 000 000 FCFA $\rightarrow$ Panier avec 99 exemplaires $\rightarrow$ Nom contenant des caractères spéciaux/emojis. |
| **3. Comportement Hostile / Pentest** | Vérifier la résistance aux injections et détournements d'autorisations. | Altération du champ `amount` dans la requête réseau $\rightarrow$ Tentative d'accès au profil d'un autre utilisateur sans token $\rightarrow$ Rejeu de requête. |
| **4. Défaillances Réseau & Reprise** | Vérifier la résilience face aux pannes télécoms et coupures. | Coupure de la connectivité en cours de validation $\rightarrow$ Passage hors-ligne $\rightarrow$ Reconnexion $\rightarrow$ Dédoublonnement par `Idempotency-Key`. |

---

## 3. CONFIGURATION PLAYWRIGHT AVEC SUPPORT 3G SUBSAHARIENNE

Fichier de configuration type pour orchestrer les tests multi-environnements sous Playwright :

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30 * 1000,
  expect: {
    timeout: 5000,
  },
  fullyParallel: false, // Évite la concurrence sur les comptes de test transactionnels
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : 2,
  reporter: [
    ['list'],
    ['html', { open: 'never', outputFolder: 'docs/qa-artifacts/playwright-report' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    {
      name: 'desktop-chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'mobile-android-3g',
      use: {
        ...devices['Pixel 5'],
        viewport: { width: 393, height: 851 },
      },
    },
  ],
});
```

---

## 4. SUITE DE TEST MODÈLE : PAIEMENT MOBILE MONEY SOUS COUPURE RÉSEAU

Ce scénario illustre l'évaluation du parcours de paiement avec throttling réseau et coupure inopinée :

```typescript
// tests/e2e/momo_payment_resilience.spec.ts
import { test, expect } from '@playwright/test';
import { applyNetworkThrottling, simulateNetworkCut, restoreNetwork, PROFILE_3G_AFRICA } from './helpers/networkThrottling';

test.describe('Résilience Paiement Mobile Money sous contrainte réseau', () => {
  test('Doit afficher le skeleton, résister à la coupure et synchroniser la transaction', async ({ page }) => {
    // 1. Connexion initiale et application du throttling 3G
    const cdpClient = await applyNetworkThrottling(page, PROFILE_3G_AFRICA);
    await page.goto('/checkout');

    // 2. Sélection du mode de paiement MTN Mobile Money
    await page.getByTestId('payment-method-momo').click();
    await page.getByTestId('input-momo-phone').fill('061234567');

    // 3. Coupure réseau juste avant la validation
    await simulateNetworkCut(cdpClient);

    // 4. L'utilisateur clique sur « Confirmer le paiement » hors-ligne
    await page.getByTestId('btn-submit-momo').click();

    // 5. Vérification du bandeau de mise en attente (Outbox locale)
    const offlineBanner = page.getByTestId('banner-offline-queued');
    await expect(offlineBanner).toBeVisible({ timeout: 2000 });
    await expect(offlineBanner).toContainText(/Connexion interrompue. Votre commande sera traitée dès rétablissement/i);

    // 6. Rétablissement du réseau sous profil 3G
    await restoreNetwork(cdpClient, PROFILE_3G_AFRICA);

    // 7. Vérification de la reprise automatique de la requête Outbox
    const successConfirmation = page.getByTestId('order-success-title');
    await expect(successConfirmation).toBeVisible({ timeout: 10000 });

    // 8. Vérification de l'unicité de la commande (Idempotence)
    const orderRef = await page.getByTestId('order-reference-code').innerText();
    expect(orderRef).toMatch(/^ORD-[A-Z0-9]{8}$/);
  });
});
```
