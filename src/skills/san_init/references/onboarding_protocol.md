# Protocole d'Onboarding & Déploiement des Règles de Gouvernance

Ce guide détaille les branches opérationnelles appliquées lors de l'onboarding d'un dépôt par `san_init`.

---

## 1. Branchement par Typologie de Projet

### Branche A : Starter Neuf ou Dépôt Vierge
Si le dépôt ne contient aucun code applicatif substantiel, l'agent utilise `ask_question` pour soumettre un questionnaire cadré en 2 volets majeurs :

1. **Profil de Projet (`PROJECT_PROFILE`) :**
   - `emerging_market` : Forte friction réseau (3G/EDGE), paiements Mobile Money (MTN MoMo, Airtel), terminaux contraints (1-2 Go RAM).
   - `global_saas` : Web desktop / mobile, bande passante standard, abonnements Stripe / carte bancaire.
   - `mobile_consumer` : Application mobile iOS / Android grand public (Expo / Bare), notifications push, offline outbox.
   - `cli_devtools` : Outil en ligne de commande, utilitaire développeur, performance locale, zéro friction réseau imposée.
   - `api_platform` : Microservices, APIs haute disponibilité, forte volumétrie de transactions, SDKs.

2. **Identité Visuelle & Archétype de Marque :**
   - Archétype esthétique issu de `BRAND_TEMPLATE.md` : Néo-brutaliste structuré, FinTech sobre suisse, Minimaliste monochrome, Cyberpunk immersif.
   - Palette de couleurs primaires et secondaires, polices Display / Sans, token de base.

### Branche B : Codebase Existante ou Monorepo
Si le dépôt contient déjà une application développée, **interdiction d'interroger le développeur sur des éléments déjà inscrits dans le code**.
L'agent délègue à `san-researcher` (`Model: 'flash'`, read-only) :
- **Design & Tokens :** Inspection de `tailwind.config.*`, `globals.css`, `tokens.scss` $\rightarrow$ Déduction pour `BRAND.md`.
- **Logos & Médias :** Détection des SVG dans `public/`, `assets/`, `resources/` $\rightarrow$ Inventaire pour `LOGO.md`.
- **Domaine & Modèles :** Analyse des migrations SQL, schémas Prisma/Drizzle, modèles Eloquent $\rightarrow$ Synthèse pour `PRODUCT.md` et `API.md`.
- **Runtimes & Tests :** Analyse de `package.json`, `composer.json`, `go.mod`, suites de tests $\rightarrow$ Configuration de `PROJECT.md`.

---

## 2. Déploiement des Règles Normatives dans `.agents/rules/`

Les 5 règles de gouvernance sont instanciées avec leurs frontmatters YAML officiels Antigravity v2.0 :

| Fichier de Règle | Frontmatter YAML | Rôle & Contenu |
| :--- | :--- | :--- |
| `PROJECT.md` | `trigger: always_on` | Socle technique, commandes de build/lint/test, profil de projet. |
| `PRODUCT.md` | `trigger: model_decision` | Vision produit, personas, contraintes marché, parcours clés. |
| `BRAND.md` | `trigger: glob: "**/*.{tsx,jsx,vue,svelte,html,css,scss}"` | Charte graphique, tokens de couleurs/espacements, cinétique 60 fps, anti-platitude. |
| `API.md` | `trigger: glob: "**/*.{ts,php,py,go,bru}"` | Conventions REST, formats JSON d'enveloppe, verrous d'idempotence `Idempotency-Key`. |
| `LOGO.md` | `trigger: model_decision` | Directives d'utilisation du logo et inventaire des déclinaisons PNG générées. |

---

## 3. Constitution Racine `AGENTS.md`

À la racine du projet, le fichier `AGENTS.md` est généré à partir de `templates/AGENTS_INDEX_TEMPLATE.md`.
Ce fichier constitue la charte suprême d'Antigravity, chargée nativement en contexte permanent (`always_on`), garantissant le respect de la doctrine d'excellence et l'orientation sous-agents sur l'ensemble de la codebase.
