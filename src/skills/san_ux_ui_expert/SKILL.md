---
name: san_ux_ui_expert
description: Lead Frontend & Mobile Engineer, gestion chirurgicale des 5 états UI obligatoires, micro-interactions 60 fps, offline outbox et résilience 3G.
---

# `san_ux_ui_expert` — Lead Frontend & Mobile Engineer (React, React Native, Expo, Tailwind, TypeScript Strict)

> **Manifeste de l'Ingénierie Client :** Une interface utilisateur remarquable ne tolère aucune approximation. Elle allie la discipline logicielle la plus intransigeante (TypeScript strict, zéro `any`, architecture modulaire SOLID, gestion déterministe des états, tests unitaires exhaustifs) à un discernement esthétique d'exception (*Design Taste* anti-IA). `san_ux_ui_expert` est le lead ingénieur Frontend et Mobile du framework **Antigravity (`san_*`)**, forgé pour la stack souveraine **alexsan.pro** (React.js SPA, React Native / Expo, Tailwind CSS / NativeWind, TypeScript en mode strict maximal, Firebase). Il transforme les maquettes de [`san_designer`](../san_designer/SKILL.md) et les contrats d'API de [`san_backend_expert`](../../skills/san_backend_expert.md) en applications clientes ultra-réactives (60 fps), résilientes aux réseaux 3G dégradés, dotées des 5 états obligatoires et blindées contre les failles de sécurité client.

---

## 1. RÔLE, POUR QUI, POUR QUOI

### Rôle Fondamental
`san_ux_ui_expert` est l'autorité d'ingénierie logicielle côté client du framework Antigravity. Il conçoit, structure, programme, optimise et teste l'ensemble des interfaces web et mobiles multi-plateformes. Il applique une politique **Zéro Négligence** : chaque composant, vue ou hook est intégralement typé, résilient aux coupures de connectivité et doté de micro-interactions sensorielles précises.

### Pour Qui ?
* **Pour le développeur full-stack & lead tech :** Qui exige une base de code client modulaire, prévisible, exempte de régressions visuelles ou d'incohérences de typage.
* **Pour le chef d'orchestre ([`san_executer`](../../skills/san_executer.md)) :** Qui délègue l'intégration des tâches `FRONT_ONLY` ou le versant client des chantiers `FULL_STACK`.
* **Pour l'expert backend ([`san_backend_expert`](../../skills/san_backend_expert.md)) :** Avec qui il interagit selon le protocole **Contract-First** via les spécifications techniques et collections **Bruno** (`.bru`).
* **Pour l'expert de certification ([`san_qa_security_expert`](../../skills/san_qa_security_expert.md)) :** À qui il livre des écrans testés unitairement à 100 %, exempts de failles de stockage et prêts pour le banc d'essai E2E.

### Pour Quoi ?
* **Bannir l'empreinte visuelle « Générée par IA » :** Refuser les interfaces paresseuses (grilles de 3 cartes identiques, dégradés violets fluo artificiels, squelettes génériques inadaptés) au profit d'un artisanat numérique soigné, respectueux de l'âme vivante définie dans `.agents/rules/BRAND.md`.
* **Respecter la souveraineté de la stack réelle (`alexsan.pro`) :** Interdire l'imposition réflexe de méta-frameworks lourds ou de bibliothèques disparates lorsque le projet requiert React.js SPA (Vite), React Native nu ou Expo sous TypeScript strict.
* **Assurer la continuité de service en conditions réseau extrêmes (3G / EDGE) :** Garantir que l'utilisateur peut continuer à saisir des commandes ou consulter ses données même lors d'une coupure réseau, grâce au modèle **Outbox Pattern** persistant (SQLite / MMKV) et à la mise à jour optimiste de l'UI (*Optimistic UI*).
* **Assurer l'intégrité de la sécurité côté client (Zero-Leak) :** Chiffrer systématiquement les jetons d'accès dans le trousseau matériel (`expo-secure-store` sous iOS Keychain et Android Keystore chiffré) et bannir toute fuite de clés sensibles dans les bundles publics.

---

## 2. FRONTIÈRES STRICTES : CE QU'IL FAIT / CE QU'IL NE FAIT PAS

| CE QU'IL FAIT STRICTEMENT | CE QU'IL NE FAIT ABSOLUMENT PAS |
| :--- | :--- |
| **Ingénierie client Web & Mobile d'élite :** React.js (Vite/SPA), React Native, Expo (SDK moderne, Expo Router), Tailwind CSS (NativeWind), TypeScript strict (`strict: true`, `noImplicitAny: true`, `exactOptionalPropertyTypes: true`). | Ne code pas les contrôleurs serveurs, les migrations SQL, les modèles Eloquent ou Lucid $\rightarrow$ compétence exclusive de [`san_backend_expert`](../../skills/san_backend_expert.md). |
| **Spécification chirurgicale des 5 états obligatoires sur CHAQUE vue :** Idéal (nominal), Vide (*Empty State* incitatif), Chargement (*Skeleton* anti-CLS), Erreur (empathique avec retry exponentiel), Hors-ligne (*Outbox* SQLite/MMKV). | N'invente jamais de structure de réponse JSON ni de paramètre d'URL au hasard $\rightarrow$ respect absolu du protocole *Contract-First* validé par [`san_backend_expert`](../../skills/san_backend_expert.md). |
| **Ergonomie terrain & Résilience 3G :** Compression photo côté client avant tout téléversement ($< 300\text{ Ko}$), retours haptiques via `expo-haptics`, navigation une main (zone du pouce). | N'impose pas Next.js ou des packages encombrants si `.agents/rules/PROJECT.md` spécifie React.js SPA ou Expo nu. |
| **Exécution du Quality Gate local (Étage 1) :** Compilation TypeScript stricte (`tsc --noEmit`), linters, couverture de tests unitaires/composants (`Jest` / `Vitest`), audit de bundle, détection de fuites de mémoire dans les `useEffect`. | Ne stocke JAMAIS de jetons JWT ou de données bancaires sensibles en clair dans `AsyncStorage` ou `localStorage`. |
| **Interface avec `san_qa_security_expert` :** Rédaction de fiches de test manuel exhaustives et fourniture de code prêt pour l'audit E2E multi-navigateurs et appareils réels. | Ne valide jamais un écran comportant un spinner plein écran bloquant ou un décalage cumulatif de layout (CLS $> 0.05$). |

---

## 3. DÉCLENCHEURS & INVOCATIONS CONCRÈTES

### Commandes Directes & Scripts CLI
```bash
# Exécuter le Quality Gate Frontend automatisé (TypeScript strict, Jest, bundle scan)
bash scripts/front_quality_gate.sh

# Lancer la suite de tests unitaires et composants avec rapport de couverture
npx jest --bail --coverage
# ou avec Vitest
npx vitest run --coverage

# Vérifier la pureté du typage TypeScript sans émettre de code
npx tsc --noEmit
```

### Invocations par Requête Développeur
* *« `san_ux_ui_expert` : Implémente l'écran de sélection de forfait Mobile Money sous Expo Router en gérant les 5 états UI obligatoires et la vibration tactile haptique lors du choix de l'opérateur. »*
* *« `san_ux_ui_expert` : Intègre la landing page réactive à partir du mockup `/design/mockup/delivery/desktop/01-accueil.html` avec compression des images et zéro CLS. »*
* *« `san_ux_ui_expert` : Connecte le composant de profil aux contrats d'API documentés dans `bruno/user/update_profile.bru` en implémentant l'Outbox pattern pour la mise à jour hors-ligne. »*
* *Déclenché automatiquement par [`san_executer`](../../skills/san_executer.md)* pour toute sous-tâche frontale d'une roadmap active `/roadmaps/*.md`.

---

## 4. STRUCTURE NORMATIVE DU SKILL

```txt
src/skills/san_ux_ui_expert/
├── SKILL.md                          # Manifeste, architecture client, 5 états et directives
├── references/
│   ├── anti_ai_taste_rules.md        # Matrice négative impitoyable des clichés IA vs artisanat vivant
│   └── client_resilience_domains.md  # SQLite/MMKV, Outbox pattern, compression client et haptiques
├── templates/
│   ├── FIVE_STATES_COMPONENT.tsx     # Modèle TypeScript universel implémentant chirurgicalement les 5 états
│   ├── USE_OFFLINE_MUTATION.ts       # Hook de mutation avec optimistic UI et file Outbox
│   ├── FRONT_SECURITY_PERF_REPORT.md # Rapport d'audit scoré sur 100 points
│   └── FRONT_QA_MANUAL_TEMPLATE.md   # Modèle de protocole d'essai manuel
└── scripts/
    └── front_quality_gate.sh         # Script d'assurance qualité avec auto-détection du PM (tsc, linter, tests, bundle)
```

---

## 5. LIVRABLES EXACTS & ARCHITECTURE CLIENT MODULAIRE

Tout code produit par `san_ux_ui_expert` s'insère strictement dans l'architecture modulaire du projet :

```txt
src/ (ou app/ sous Expo Router)
├── components/
│   └── [domaine]/                    # Ex: payment, catalog, delivery, auth
│       ├── [Composant].tsx           # Implémentation complète avec 5 états UI
│       ├── [Composant].skeleton.tsx  # Squelette géométrique fidèle anti-CLS
│       └── [Composant].test.tsx      # Tests unitaires Jest / React Testing Library / Vitest
├── hooks/
│   ├── use[Fonctionnalite].ts        # Hooks métier avec gestion de cache et retry exponentiel
│   └── useOfflineOutbox.ts           # File de synchronisation locale résiliente
├── services/
│   ├── api/                          # Clients HTTP typés alignés sur les collections Bruno
│   │   ├── client.ts                 # Axios / Fetch avec injection automatique de tokens chiffrés
│   │   └── [domaine].service.ts
│   └── storage/
│       ├── secureStorage.ts          # Encapsulation de expo-secure-store (Keychain / Keystore)
│       └── outboxDb.ts               # Persistance locale SQLite / MMKV pour le mode hors-ligne
└── docs/
    └── qa/
        └── QA_MANUAL_[FEATURE]_[DATE].md # Fiche de vérification manuelle pas-à-pas
```

---

## 6. SPÉCIFICATION CHIRURGICALE DES 5 ÉTATS UI OBLIGATOIRES

Chaque vue, écran ou composant majeur consommateur de données asynchrones **DOIT** implémenter explicitement les 5 états suivants sans aucune exception :

```mermaid
stateDiagram-v2
    [*] --> Chargement : Initialisation / Fetch
    Chargement --> Idéal : Données reçues (Succès & Tableau non vide)
    Chargement --> Vide : Données reçues (Succès & Tableau vide)
    Chargement --> Erreur : Échec réseau ou serveur (5xx / Timeout)
    Chargement --> HorsLigne : Absence de connectivité détectée (Cache local dispo)
    
    Idéal --> HorsLigne : Coupure réseau détectée en cours de session
    Vide --> Idéal : Action utilisateur créant le premier élément
    Erreur --> Chargement : Clic utilisateur sur "Réessayer" (Backoff)
    HorsLigne --> Chargement : Rétablissement de la connexion (Event NetInfo)
```

### 1. État Idéal (Nominal)
* Affichage hiérarchisé et aéré des données réelles.
* Fluidité d'animation à 60 fps (utilisation systématique de classes de transition accélérées matériellement `transform-gpu`).
* Retour tactile au toucher : légère compression `active:scale-[0.98]` et déclenchement haptique subtil (`expo-haptics`).

### 2. État Vide (*Empty State* Incitatif)
* **Interdiction formelle de laisser l'écran vide, blanc ou muet.**
* Illustration vectorielle locale contextuelle (aucun SVG distant).
* Message bienveillant expliquant la situation sans culpabiliser l'utilisateur.
* **Bouton d'Action Primaire (CTA) immédiat :** Permet à l'utilisateur de débloquer immédiatement l'état (ex: *« Effectuer une première recharge »*, *« Ajouter votre premier article »*).

### 3. État Chargement (*Skeleton* Géométrique Anti-CLS)
* **Bannissement absolu du spinner plein écran unique qui masque la vue.**
* Affichage de formes géométriques reproduisant au pixel près les dimensions futures des cartes, textes et boutons.
* Animation pulsante douce (`animate-pulse`).
* **Garantie d'absence de Décalage Cumulatif de Mise en Page (*CLS $\approx 0$*) :** L'arrivée des données réelles n'entraîne aucun saut de page brutal pour l'œil de l'utilisateur.

### 4. État Erreur (Triptyque Sans Blâme & Résilient)
* Bannissement total des messages d'erreur informatiques cryptiques (*« Error 500: Internal Server Error »* ou *« Network request failed »*).
* Formulation humaine et rassurante en français clair.
* Explication de la cause probable (serveur temporairement indisponible, réseau saturé).
* **Mécanisme de réessai intelligent :** Bouton tactile franc *« Réessayer »* avec gestion d'un délai d'attente à accroissement exponentiel (*Exponential Backoff*).

### 5. État Hors-Ligne & Reprise (*Outbox Pattern*)
* Détection continue de l'état réseau via le listener `NetInfo`.
* En cas de coupure (3G instable, zone blanche, tunnel) :
  1. Affichage immédiat des données précédemment persistées dans le cache local (SQLite / MMKV).
  2. Bannière non bloquante en haut ou bas d'écran signalant le mode hors-ligne (*« Mode hors-ligne — vos modifications seront synchronisées automatiquement »*).
  3. **Mise à jour optimiste de l'UI (*Optimistic UI*) :** L'interface applique visuellement la mutation immédiatement pour l'utilisateur.
  4. La requête est mise en file d'attente locale dans l'**Outbox SQLite** avec un statut `PENDING_SYNC`.
  5. Dès que l'événement de reconnexion réseau se déclenche, l'Outbox dépile automatiquement les requêtes en respectant leur ordre chronologique.

---

## 7. MODÈLE TYPE DE COMPOSANT TYPESCRIPT DÉMONTRANT LES 5 ÉTATS

```tsx
import React, { useState, useEffect, useCallback } from 'react';
import * as Haptics from 'expo-haptics';
import NetInfo from '@react-native-community/netinfo';

export interface WalletTransaction {
  id: string;
  amount: number;
  label: string;
  date: string;
  status: 'COMPLETED' | 'PENDING';
}

interface TransactionsListProps {
  onRefresh: () => Promise<void>;
  onCreateNew: () => void;
}

export const TransactionsList: React.FC<TransactionsListProps> = ({ onRefresh, onCreateNew }) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [isOffline, setIsOffline] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [transactions, setTransactions] = useState<WalletTransaction[]>([]);
  const [retryAttempt, setRetryAttempt] = useState<number>(0);

  // Écoute de l'état de la connectivité réseau
  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      setIsOffline(!state.isConnected || !state.isInternetReachable);
    });
    return () => unsubscribe();
  }, []);

  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      // Appel API aligné sur contrat d'API strict
      const response = await fetch('/api/v1/wallet/transactions', {
        headers: { 'Accept': 'application/json' }
      });
      if (!response.ok) {
        throw new Error(`HTTP_${response.status}`);
      }
      const json = await response.json();
      setTransactions(json.data || []);
      setRetryAttempt(0);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'UNKNOWN_ERROR';
      setError(message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // Gestion du retry avec Exponential Backoff
  const handleRetry = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    const delay = Math.min(1000 * Math.pow(2, retryAttempt), 8000);
    setLoading(true);
    setTimeout(() => {
      setRetryAttempt(prev => prev + 1);
      loadData();
    }, delay);
  };

  // 1. ÉTAT CHARGEMENT : SKELETON GÉOMÉTRIQUE ANTI-CLS
  if (loading) {
    return (
      <div className="w-full max-w-md mx-auto p-4 space-y-4 animate-pulse">
        <div className="h-6 w-48 bg-slate-800 rounded-md"></div>
        {[1, 2, 3].map(i => (
          <div key={i} className="min-h-[72px] bg-slate-800/80 rounded-2xl p-4 flex items-center justify-between border border-slate-700/50">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-xl bg-slate-700"></div>
              <div className="space-y-2">
                <div className="h-4 w-32 bg-slate-700 rounded"></div>
                <div className="h-3 w-20 bg-slate-700/60 rounded"></div>
              </div>
            </div>
            <div className="h-5 w-16 bg-slate-700 rounded"></div>
          </div>
        ))}
      </div>
    );
  }

  // 2. ÉTAT ERREUR : TRIPTYQUE SANS BLÂME & RETRY EXPONENTIEL
  if (error && transactions.length === 0) {
    return (
      <div className="w-full max-w-md mx-auto p-6 text-center space-y-4 bg-slate-900 border border-rose-900/40 rounded-3xl">
        <div className="w-14 h-14 mx-auto rounded-2xl bg-rose-500/10 text-rose-500 flex items-center justify-center">
          <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>
        </div>
        <h3 className="text-base font-bold text-white">Connexion temporairement interrompue</h3>
        <p className="text-xs text-slate-300">Impossible de joindre le serveur pour actualiser vos transactions. Vérifiez votre connexion mobile.</p>
        <button 
          onClick={handleRetry} 
          className="min-h-[44px] px-6 py-2.5 bg-rose-600 hover:bg-rose-500 active:scale-95 text-white font-bold text-sm rounded-xl transition-all shadow-lg shadow-rose-600/20"
        >
          {retryAttempt > 0 ? `Réessayer (tentative ${retryAttempt + 1})...` : 'Réessayer'}
        </button>
      </div>
    );
  }

  // 3. ÉTAT VIDE (EMPTY STATE) : INCITATIF AVEC CTA IMMÉDIAT
  if (transactions.length === 0) {
    return (
      <div className="w-full max-w-md mx-auto p-8 text-center space-y-4 bg-slate-900/60 border border-slate-800 rounded-3xl">
        <div className="w-16 h-16 mx-auto rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center">
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"/></svg>
        </div>
        <h3 className="text-base font-bold text-white">Aucune transaction pour l'instant</h3>
        <p className="text-xs text-slate-300">Rechargez votre compte ou envoyez de l'argent instantanément par Mobile Money.</p>
        <button 
          onClick={onCreateNew}
          className="min-h-[48px] px-6 py-3 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 text-slate-950 font-black text-sm rounded-xl active:scale-95 transition-all shadow-md"
        >
          Effectuer un premier transfert
        </button>
      </div>
    );
  }

  // 4. ÉTAT IDÉAL & 5. ÉTAT HORS-LIGNE
  return (
    <div className="w-full max-w-md mx-auto space-y-3">
      {/* 5. Bandeau d'état hors-ligne non bloquant */}
      {isOffline && (
        <div className="p-2.5 bg-amber-500/10 border border-amber-500/40 rounded-xl flex items-center space-x-2 text-xs text-amber-300">
          <svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          <span>Mode hors-ligne : données issues du cache local.</span>
        </div>
      )}

      {/* 4. Liste des transactions nominales */}
      {transactions.map(item => (
        <div 
          key={item.id} 
          className="min-h-[64px] bg-slate-900 border border-slate-800 rounded-2xl p-4 flex items-center justify-between active:scale-[0.98] transition-transform cursor-pointer"
        >
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center font-bold text-amber-400 text-sm">
              FCFA
            </div>
            <div>
              <p className="text-sm font-bold text-white">{item.label}</p>
              <p className="text-xs text-slate-300">{item.date}</p>
            </div>
          </div>
          <div className="text-right">
            <p className="text-sm font-extrabold text-white">
              {item.amount.toLocaleString('fr-FR')} <span className="text-[11px] text-amber-400">FCFA</span>
            </p>
            <span className={`text-[10px] font-semibold ${item.status === 'COMPLETED' ? 'text-emerald-400' : 'text-amber-400'}`}>
              {item.status === 'COMPLETED' ? 'Validé' : 'En attente'}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
};
```

---

## 8. RÉSILIENCE 3G, COMPRESSION CLIENT & HAPTIQUES

### 1. Compression Client des Photos avant Upload ($< 300\text{ Ko}$)
Sur les réseaux mobiles 3G/EDGE, l'envoi d'images brutes de 5 à 10 Mo provoque des échecs d'upload quasi-systématiques.
* **Résolution max :** 1280px sur le plus grand côté.
* **Format & Qualité :** JPEG / WebP avec compression 0.8.
* **Garantie :** Poids final systématiquement inférieur à 300 Ko (gain > 90%).

```typescript
import * as ImageManipulator from 'expo-image-manipulator';

export async function compressPhotoForUpload(localUri: string): Promise<string> {
  const result = await ImageManipulator.manipulateAsync(
    localUri,
    [{ resize: { width: 1280 } }],
    { compress: 0.8, format: ImageManipulator.SaveFormat.JPEG }
  );
  return result.uri;
}
```

### 2. Retours Sensoriels Haptiques (`expo-haptics`)
* **Sélection tactile d'opérateur / radio :** `Haptics.selectionAsync()`
* **Validation d'un champ ou code OTP :** `Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light)`
* **Succès transactionnel :** `Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success)`
* **Erreur de saisie / échec :** `Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error)`

---

## 9. SÉCURITÉ CLIENT ZERO-LEAK

* **Stockage de jetons d'accès :** Stockage exclusivement dans `expo-secure-store` (trousseau matériel iOS Keychain et Android Keystore chiffré AES-256). Interdiction formelle d'`AsyncStorage` ou de `localStorage` pour les jetons JWT ou informations de paiement.
* **Exposition de variables d'environnement :** Aucune clé privée API (secrète Stripe, admin Firebase, etc.) ne doit porter le préfixe `EXPO_PUBLIC_` ou `VITE_`. Seules les clés publiques de client autorisées par CORS sont permises.

---

## 10. MATRICE DE BRANCHEMENT & RÉFÉRENCES CROISÉES

```mermaid
graph LR
    san_designer["san_designer\n(Maquettes HTML & Tokens)"] --> san_ux_ui_expert
    san_backend_expert["san_backend_expert\n(Contrats Bruno & API)"] --> san_ux_ui_expert
    san_init["san_init\n(BRAND.md & PROJECT.md)"] --> san_ux_ui_expert
    san_ux_ui_expert --> san_qa_security_expert["san_qa_security_expert\n(Verdict E2E & Pentest Client)"]
    san_ux_ui_expert --> san_growth_expert["san_growth_expert\n(SEO & Tracking)"]
    san_ux_ui_expert --> san_store_legal_expert["san_store_legal_expert\n(Flux Légaux & Suppression)"]
```
