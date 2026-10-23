# RAPPORT DE PERFORMANCE, CHARGE & CORE WEB VITALS

> **Projet :** [Nom du Projet Client]  
> **Date de Mesure :** AAAA-MM-JJ — HH:MM  
> **Auditeur Responsable :** `san_qa_security_expert`  
> **Environnement de Test :** Profil Mobile 3G Dégradée (750 kbps down / 250 kbps up / 150ms RTT)  
> **Verdict Performance :** CONFORME / NON CONFORME  

---

## 1. SYNTHÈSE DES CORE WEB VITALS (APPLICATION WEB)

Mesures réalisées avec Lighthouse CI et Playwright Performance Tracing sous profil réseau bridé :

| Métrique | Seuil Cible Antigravity | Valeur Mesurée | Statut |
| :--- | :---: | :---: | :---: |
| **LCP (Largest Contentful Paint)** | $< 2.5\text{ s}$ | **1.82 s** | CONFORME |
| **INP (Interaction to Next Paint)** | $< 200\text{ ms}$ | **82 ms** | CONFORME |
| **CLS (Cumulative Layout Shift)** | $< 0.10$ | **0.012** | CONFORME |
| **TTFB (Time to First Byte)** | $< 600\text{ ms}$ | **180 ms** | CONFORME |
| **FCP (First Contentful Paint)** | $< 1.5\text{ s}$ | **1.05 s** | CONFORME |
| **Score Mobile Lighthouse** | $\ge 90 / 100$ | **96 / 100** | CONFORME |

---

## 2. LATENCE & CHARGE DES ENDPOINTS CRITIQUES (BACKEND)

Benchmarks exécutés avec un tir de 50 requêtes concurrentes réparties sur 1 000 requêtes totales :

| Endpoint Testé | Échantillon | Latence p50 | Latence p95 | Seuil p95 Max | Taux d'Erreur |
| :--- | :---: | :---: | :---: | :---: | :---: |
| `POST /api/v1/auth/otp/verify` | 500 req | 42 ms | **105 ms** | $< 200\text{ ms}$ | 0.0 % |
| `GET /api/v1/catalog/items` | 1 000 req | 30 ms | **72 ms** | $< 200\text{ ms}$ | 0.0 % |
| `POST /api/v1/orders` | 500 req | 68 ms | **145 ms** | $< 200\text{ ms}$ | 0.0 % |
| `POST /api/v1/checkout/momo` | 200 req | 135 ms | **260 ms** | $< 500\text{ ms}$ | 0.0 % |

---

## 3. EMPREINTE MOBILE (APPLICATION REACT NATIVE / EXPO)

Mesures effectuées sur binaire Android Release (compilation universelle) :

- **Taille totale de l'APK (Android Release) :** **18.2 Mo** (Seuil maximal autorisé : $< 25\text{ Mo}$).
- **Taille du bundle JS Hermes compilé :** **2.4 Mo** (minifié et pré-analysé en bytecode).
- **Consommation mémoire RAM au repos :** **65 Mo** (Seuil maximal toléré : $< 150\text{ Mo}$).
- **Consommation mémoire sous défilement intensif :** **115 Mo** (Seuil maximal toléré : $< 250\text{ Mo}$).
- **Taux de rafraîchissement des animations :** **60 fps** constant (zéro freeze observé lors du rendu de listes virtualisées).

---

## 4. ANALYSE ET RECOMMANDATIONS D'OPTIMISATION

*(Si des optimisations mineures sont identifiées, les consigner ci-après :)*

1. **Mise en cache HTTP des assets statiques :**
   S'assurer que les polices de caractères et images SVG intègrent l'en-tête `Cache-Control: public, max-age=31536000, immutable`.
2. **Compression WebP / AVIF :**
   Toutes les photographies du catalogue doivent être converties au format moderne WebP pour économiser la bande passante des clients mobiles.
