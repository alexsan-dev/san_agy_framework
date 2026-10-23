# Référentiel de Performance & Seuils d'Acceptation Antigravity

Ce document définit les normes et métriques de performance impératives pour toute application validée par `san_qa_security_expert` au sein du framework Antigravity (`san_*`).

---

## 1. CORE WEB VITALS & EXPÉRIENCE WEB

Les seuils suivants s'appliquent à l'ensemble des applications Web (React, Next.js, Blade) évaluées sous conditions de production et simulées sous profil réseau mobile :

| Métrique | Indicateur | Seuil Maximal Toléré | Seuil Optimal Visé | Outil de Mesure |
| :--- | :--- | :---: | :---: | :--- |
| **LCP** | *Largest Contentful Paint* (Affichage du bloc principal) | **$< 2.5\text{ s}$** | $< 1.8\text{ s}$ | Lighthouse / Playwright Performance |
| **INP** | *Interaction to Next Paint* (Réactivité aux clics/saisies) | **$< 200\text{ ms}$** | $< 80\text{ ms}$ | Chrome DevTools Tracing |
| **CLS** | *Cumulative Layout Shift* (Stabilité visuelle) | **$< 0.10$** | $< 0.02$ | Playwright Layout Shift Observer |
| **FCP** | *First Contentful Paint* (Premier élément rendu) | **$< 1.5\text{ s}$** | $< 1.0\text{ s}$ | Lighthouse |
| **TTFB** | *Time to First Byte* (Latence initiale du serveur) | **$< 600\text{ ms}$** | $< 200\text{ ms}$ | cURL / Web Vitals API |
| **Score Global** | Performance Lighthouse (Audit Mobile) | **$\ge 90 / 100$** | $\ge 95 / 100$ | Lighthouse CI |

---

## 2. LATENCE BACKEND & ENDPOINTS D'APIS REST

Les temps de réponse des APIs (Laravel, AdonisJS v6) sont mesurés sous charge nominale (50 requêtes concurrentes) avec des outils de benchmark (`autocannon`, `k6`) :

| Catégorie d'Endpoint | Seuil p50 | Seuil p95 Maximal | Taux d'Erreur Toléré |
| :--- | :---: | :---: | :---: |
| **Lecture en Cache / Catalogue public** (`GET /catalog`) | $< 40\text{ ms}$ | **$< 100\text{ ms}$** | 0.0 % |
| **Authentification & Validation OTP** (`POST /auth/otp`) | $< 80\text{ ms}$ | **$< 150\text{ ms}$** | 0.0 % |
| **Transactions Métier & Mutations SQL** (`POST /orders`) | $< 120\text{ ms}$ | **$< 200\text{ ms}$** | 0.0 % |
| **Opérations Fintech / Mobile Money** (`POST /checkout/momo`) | $< 250\text{ ms}$ | **$< 500\text{ ms}$** | $< 0.1 \%$ |

---

## 3. EMPREINTE MOBILE (REACT NATIVE / EXPO)

Les métriques mobiles ciblent des terminaux d'entrée de gamme (Android 2 Go de RAM, processeur quad-core modeste) représentatifs du parc d'Afrique subsaharienne :

| Indicateur Mobile | Seuil Strict Toléré | Seuil Optimal | Méthode de Mesure |
| :--- | :---: | :---: | :--- |
| **Taille de l'APK Universel** (Android Release) | **$< 25\text{ Mo}$** | $< 18\text{ Mo}$ | `ls -lh build/*.apk` |
| **Taille du Bundle JavaScript Hermes** | **$< 5\text{ Mo}$** | $< 2.5\text{ Mo}$ | Minifié & Bytecode compilé |
| **Consommation Mémoire RAM au Repos** | **$< 150\text{ Mo}$** | $< 80\text{ Mo}$ | Android Profiler / Flipper |
| **Consommation Mémoire sous Défilement Intensif** | **$< 250\text{ Mo}$** | $< 140\text{ Mo}$ | Android Profiler |
| **Fluidité des Animations & Défilement** | **$60\text{ fps}$** (chute max $55\text{ fps}$) | $60\text{ fps}$ | React Native Performance Monitor |
| **Temps de Démarrage à Froid** (*Cold Start*) | **$< 2.5\text{ s}$** | $< 1.5\text{ s}$ | Android Vitals / Logcat |

---

## 4. CONDITIONS DU BENCHMARK RÉSEAU DÉGRADÉ (3G SUBSAHARIENNE)

Pour garantir que les applications restent parfaitement exploitables sur le terrain, tous les tests de charge client et de Core Web Vitals sont répétés sous les conditions de profil réseau contraignant :

* **Profil :** `3G_SLOW_EDGE` (Afrique Subsaharienne / Mobilité)
* **Débit Descendant (*Download*) :** $750\text{ kbps}$ ($93\,750\text{ octets/s}$)
* **Débit Montant (*Upload*) :** $250\text{ kbps}$ ($31\,250\text{ octets/s}$)
* **Latence RTT (*Round Trip Time*) :** $150\text{ ms}$
* **Paquets Perdus / Jitter Simulé :** $1.5\%$ de perte intermittente lors des tests d'idempotence

### Critères d'Acceptation sous Throttling 3G :
1. **Zéro Écran Blanc :** Les squelettes de chargement (Skeletons) doivent se substituer au contenu dans un délai inférieur à $100\text{ ms}$ après le déclenchement de l'action.
2. **Debouncing Applicatif :** Toute sollicitation répétée de boutons d'action (achats, validation de transferts) doit être filtrée par debounce ou désactivation temporaire du composant afin d'éviter la prolifération de requêtes réseau inutiles.
3. **Maintien de l'Interactivité :** Aucune opération réseau en attente ne doit bloquer le fil d'exécution principal (*Main Thread*) ni figer les animations d'interface.
