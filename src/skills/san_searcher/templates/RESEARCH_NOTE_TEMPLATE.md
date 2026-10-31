# FICHE CANONIQUE DE RECHERCHE TECHNIQUE & INVESTIGATION
# Référence : `docs/research/TECH_INVESTIGATION_[DOMAINE]_[JJMMAAAA].md`
# Framework Antigravity (`san_*`) — Moteur `san_searcher`

---

# FICHE DE RECHERCHE TECHNIQUE : [SUJET / TECHNOLOGIE]
- **Date d'Investigation :** JJ/MM/AAAA
- **Auteur / Éclaireur :** `san_searcher` (Sas étanche de Context Shielding)
- **Version Détectée du Projet (Pinning) :** [ex: Laravel 11.28, React 19.0.0, Expo SDK 52.0.0, Tailwind CSS 4.0.0, Go 1.23]
- **Domaine Officiel Consulté :** [ex: laravel.com, react.dev, docs.expo.dev, tailwindcss.com, owasp.org]
- **Sources Officielles :**
  - [Documentation Officielle](https://...)
  - [Release Notes / Changelog de Version](https://...)
  - [RFC / Pull Request de Référence](https://...)

---

## 1. Contexte & Problématique Résolue
[Description concise et chirurgicale du verrou technique, de la signature d'API à clarifier, de l'incompatibilité de dépendances ou du choix d'architecture à trancher. Préciser le composant ou fichier cible impacté dans le projet.]

## 2. Pattern Canonique Officiel (Recommandé)
[Explication didactique du design pattern actuel préconisé par la documentation officielle de l'éditeur pour la version active. Expliquer pourquoi cette approche est supérieure aux anciennes pratiques et comment elle s'intègre avec les principes Clean Code / SOLID.]

## 3. Snippet de Référence Typé (Zéro Hallucination)
```typescript
// Exemple officiel vérifié, 100% typé et prêt pour l'implémentation locale
// Version testée compatible : [TECHNOLOGIE_VERSION]
export interface ServiceContract {
  id: string;
  idempotencyKey: string;
  status: 'PENDING' | 'SETTLED' | 'REJECTED';
}

export async function executeOfficialPattern(payload: ServiceContract): Promise<boolean> {
  // Implémentation certifiée conforme à la documentation officielle
  return true;
}
```

## 4. Tableau Comparatif Multi-Options

*Confrontation méthodique des alternatives étudiées avec balance objective avantages / inconvénients / risques / effort.*

| Option | Approche / Pattern | Avantages Clés | Inconvénients & Concessions | Risques Identifiés | Effort Estimé | Verdict |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Option A (Canonique)** | [Ex: Server Actions + Zod] | [Typage de bout en bout, bundle client allégé] | [Couplage au runtime Next.js] | [Lock-in framework] | [Faible (1-2 jours)] | **RECOMMANDÉ** |
| **Option B (Alternative)** | [Ex: Route Handlers + Bruno] | [Standard REST universel, découplage total] | [Duplication de validation client/serveur] | [Dérive de types manuelle] | [Moyen (2-3 jours)] | **RECEVABLE** |
| **Option C (Contournement)** | [Ex: Bibliothèque tierce X] | [Mise en place immédiate via plugin] | [Poids bundle +45 Ko, maintenance opaque] | [Abandon upstream, faille CVE] | [Immédiat (< 4h)] | **ÉCARTÉ** |

## 5. Tableau Comparatif : Déprécié vs Canonique
| Ancien Pattern (Déprécié / À Proscrire) | Pattern Canonique Actuel (Recommandé) | Risque Technique / Justification |
| :--- | :--- | :--- |
| `ancien_parametre` ou méthode obsolète | `nouveau_parametre` ou nouvelle API | Déprécié en vN, rupture ou exception levée en vN+1 |
| Configuration manuelle `tailwind.config.js` | Directives CSS `@theme` (Tailwind v4) | Rupture de build et incompatibilité de rechargement à chaud |
| Polling actif non sécurisé | Événements asynchrones ou webhooks HMAC | Saturation socket, surcoût serveur et risque de rejeu |

## 6. Pièges Connus & Réalités Terrain (3G/EDGE & Idempotence)
- **Résilience Réseau Dégradé (3G / Latence élevée) :**
  - Comportement en cas de coupure socket ou timeout de passerelle.
  - Stratégie de retry recommandée (Exponential Backoff avec Jitter).
- **Idempotence & Prévention des Doublons :**
  - Spécification de l'en-tête `Idempotency-Key` ou du verrou atomique Redis (`Cache::lock`).
  - Durée de rétention recommandée de la clé en cache.
- **Sécurité & Intégrité des Données :**
  - Validation cryptographique des signatures (HMAC-SHA256).
  - Assainissement strict des payloads entrants.

## 7. Synthèse d'Intégration & Préconisations pour l'Orchestrateur
- **Impact sur la Roadmap :** [Tâches à insérer ou modifier dans /roadmaps/]
- **Fichiers Applicatifs à Créer / Adapter :**
  - `file:///chemin/absolu/vers/fichier_1.ext`
  - `file:///chemin/absolu/vers/fichier_2.ext`
- **Commande de Validation Déterministe :**
  - Commande recommandée : `[COMMANDE_TEST]`
