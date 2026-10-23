# RÉPERTOIRE D'INTELLIGENCE MARCHÉ — AFRIQUE CENTRALE & MARCHÉS ÉMERGENTS

> **Module :** `san_brainstorming` (Framework Antigravity `san_*`)  
> **Fichier de Référence :** `references/congo_market_signals.md`  
> **Zone Géographique Pivot :** Congo-Brazzaville, RDC (Kinshasa), Cameroun, Côte d'Ivoire, Sénégal  
> **Auteur :** Alexsan.pro  
> **Règle Cardinale :** Toute hypothèse produit formulée par un agent ou un développeur doit être passée au crible des réalités physiques et sociologiques consignées ci-dessous. Zéro complaisance pour les modèles occidentaux inapplicables.

---

## 1. INFRASTRUCTURES TÉLÉCOMS ET CONNECTIVITÉ RÉSEAU

### 1.1 Dominance 3G / EDGE et Instabilité Chronique
- **Répartition Réseau Réelle :** Si la 4G est affichée sur les supports publicitaires des opérateurs (MTN Congo, Airtel Congo, Orange RDC, Vodacom), la couverture effective en dehors des centres d'affaires de Brazzaville, Pointe-Noire ou Kinshasa bascule constamment en **3G HSPA+ voire en EDGE (2.75G)**.
- **Perte de Paquets et Gigue :** Les taux de perte de paquets (*packet loss*) oscillent fréquemment entre **5 % et 25 %**, et le ping vers des serveurs européens (Francfort, Paris) dépasse régulièrement **180 ms à 350 ms**.
- **Coupures de Faisceau Sous-Marin & Flottements :** Les incidents sur les câbles sous-marins (WACS, 2Africa) ou coupures de fibre optique terrestre créent des phases de blackout partiel ou de débit bridé pendant plusieurs jours.

### 1.2 Économie du Mégaoctet et Forfaits Journaliers Prépayés
- **Facturation au Mégaoctet :** Moins de 2 % de la population dispose d'une connexion internet fixe illimitée (Fibre/ADSL à domicile). Plus de 95 % des connexions s'effectuent via des forfaits mobiles prépayés (pass jour de 200 FCFA à 500 FCFA pour 200 Mo à 1 Go, ou pass semaine).
- **Épuisement Imprévu du Solde en Cours de Session :** Un utilisateur peut voir son solde internet tomber à 0 Ko au milieu d'un tunnel d'achat ou lors de la saisie d'un formulaire. Si l'état de l'application n'est pas persisté localement en cache (`LocalStorage`, `MMKV`, `SQLite`), toutes les données saisies sont irrémédiablement perdues.
- **Répulsion Vis-à-Vis des Fichiers Lourds :** Tout téléchargement supérieur à 15 Mo est perçu comme une dépense financière directe. Les applications de 50 Mo sur le Play Store subissent un taux d'abandon supérieur à 80 % au moment du clic sur « Télécharger ».

### 1.3 Instabilité Énergétique et Coupures d'Électricité (Délestages)
- **Délestages Récurrents :** Les réseaux de distribution électrique (E2C au Congo, SNEL en RDC) subissent des coupures d'électricité intermittentes (« délestages ») quotidiennes pouvant durer de 3 à 18 heures consécutives.
- **Impact sur les Équipements Réseau :** Pendant les coupures, les antennes-relais télécoms fonctionnent sur groupes électrogènes ou batteries de secours dont le carburant ou la capacité sont parfois déficients, dégradant instantanément le signal mobile du quartier.
- **Gestion de Batterie Critique :** Les usagers économisent drastiquement leur batterie de smartphone. Les applications qui consomment du CPU en arrière-plan, maintiennent des `wake locks` ou abusent du polling GPS sont immédiatement désinstallées.

---

## 2. PAIEMENTS ET ÉCOSYSTÈME MOBILE MONEY

### 2.1 Les Piliers Opérateurs (Airtel Money, MTN MoMo, Orange Money, M-Pesa)
- **Taux de Bancarisation Classique :** Moins de 10 % à 15 % de la population détient un compte bancaire traditionnel ou une carte de débit Visa/Mastercard.
- **Hégémonie du Mobile Money :** Le Mobile Money (Airtel Money et MTN MoMo au Congo-Brazzaville ; Vodacom M-Pesa, Airtel Money et Orange Money en RDC) constitue la monnaie numérique quasi-exclusive. Le numéro de téléphone mobile sert de compte bancaire.
- **Agents de Retrait / Kiosques Physiques :** Le cash reste roi en amont et en aval. Les utilisateurs rechargent leur compte MoMo ou retirent des espèces auprès de milliers de cabines et kiosques physiques de rue.

### 2.2 Modalités Techniques : Push USSD (STK) vs Menus Interactifs
- **Le Graal Ergonomique : STK Push (Sim ToolKit) :** L'API déclenche un pop-up système direct sur l'écran du client : *« Paiement de X FCFA à [Marchand]. Entrez votre code PIN secret »*. L'utilisateur n'a qu'à taper son PIN à 4 chiffres.
- **Latence et Délais de Confirmation :** La fenêtre de réponse USSD expire souvent au bout de 60 à 90 secondes. Si l'utilisateur tarde ou si le réseau de l'opérateur sature, la requête échoue sans débit.
- **Asynchronisme Radical des Webhooks Opérateurs :** Les passerelles Mobile Money (agrégateurs ou APIs directes MTN/Airtel) ne renvoient PAS la confirmation de paiement de manière synchrone dans la requête HTTP d'initiation. Le résultat arrive par webhook asynchrone avec un délai pouvant varier de 2 secondes à... 15 minutes.
- **Conséquence d'Ingénierie :** L'architecture logicielle doit impérativement utiliser une clé d'idempotence (`Idempotency-Key`), une machine à états côté serveur (`PENDING` -> `SUCCESS` / `FAILED`), et une vérification par polling sécurisé ou écoute WebSocket côté client, assortie d'un cron de réconciliation en tâche de fond.

### 2.3 Défaillances Fréquentes des SMS OTP (One-Time Password)
- **Le Fléau du Code SMS Retardé :** Compter sur un SMS pour envoyer un code OTP de validation à 6 chiffres est la première cause de mortalité des applications en Afrique centrale. Les agrégateurs SMS (SMPP) ou routes opérateurs subissent des encombrements provoquant des retards de réception de 5 à 45 minutes, bien après l'expiration du token (souvent 5 min).
- **Solutions Validées sur le Terrain :**
  1. Authentification par WhatsApp OTP (Cloud API officielle Meta).
  2. Authentification par appel manqué (*Flash Call*).
  3. Maintien de sessions longues persistantes (refresh tokens à 90 jours avec rotation).

---

## 3. COMPORTEMENT UTILISATEUR, PSYCHOLOGIE & USAGES LOCAUX

### 3.1 WhatsApp comme Système d'Exploitation Parallèle
- **Omniprésence Absolue :** WhatsApp n'est pas une simple messagerie ; c'est le navigateur web, la place de marché, l'outil de collaboration professionnelle et le réseau social numéro 1.
- **Statuts WhatsApp comme Vitrines Commerciales :** Plus de 70 % du commerce social informel s'effectue via la publication de photos et vidéos dans les statuts WhatsApp.
- **Notes Vocales (*Voice Notes*) :** L'usage de la voix surpasse largement le texte écrit. Pour négocier, demander un prix ou confirmer une commande, l'usager local privilégie spontanément une note vocale de 15 secondes plutôt que la lecture ou la saisie d'un texte long.
- **Aversion Aiguë aux Formulaires à Rallonge :** Tout formulaire demandant plus de 3 champs (Nom, Prénom, Téléphone, Adresse postale, Code postal, etc.) entraîne un taux d'abandon massif. Les notions occidentales de "Code Postal" ou de "Ligne d'adresse 2" n'ont aucun sens sur le terrain local.

### 3.2 Toponymie Informelle et Absence d'Adresses Postales
- **Navigation par Repères Visuels :** Dans la quasi-totalité des quartiers de Brazzaville, Kinshasa, Pointe-Noire ou Douala, il n'existe pas de numérotation séquentielle des habitations dans les rues.
- **Structure Réelle d'une Adresse :**
  - Nom du quartier / Arrondissement (ex: *Moungali*, *Ouenzé*, *Bacongo*, *Matonge*).
  - Point de repère remarquable : *« En face de la pharmacie de la Paix »*, *« 2e ruelle après l'arrêt Total »*, *« Derrière l'école Mabiala »*, *« Maison au portail bleu avant le bar »*.
- **Impact sur l'UI/UX :** Un champ de livraison doit proposer un champ texte libre `Repères visuels & Quartier` plutôt qu'une adresse normalisée avec numéro de voie, complété idéalement par le partage de position GPS WhatsApp ou un pin sur une carte interactive légère.

### 3.3 Psychologie de la Confiance et de la Fraude
- **Besoin d'Assurance Humaine Directe :** Face à un paiement dématérialisé, l'acheteur craint viscéralement l'arnaque (*« On va couper mon argent et rien livrer »*). Un bouton direct *« Parler à un conseiller sur WhatsApp »* ou un appel téléphonique de confirmation augmente le taux de conversion de plus de 40 %.
- **La Capture d'Écran SMS comme Preuve Incontestable :** Lors d'un virement Mobile Money, l'usager a le réflexe immédiat de faire une capture d'écran du SMS de notification de l'opérateur et de l'envoyer comme preuve irréfutable du paiement.
- **Fraude aux Faux SMS MoMo :** De faux SMS imitant les notifications d'Airtel ou de MTN circulent. Tout système d'information marchand doit valider les encaissements via l'API officielle ou le relevé marchand, JAMAIS sur simple présentation visuelle d'un SMS ou d'une capture non vérifiée.

---

## 4. PARC MATÉRIEL ET TERMINAUX MOBILES

### 4.1 Dominance des Smartphones Android d'Entrée de Gamme
- **Marques Prédominantes :** Transsion Holdings (marques **Tecno**, **Infinix**, **Itel**) équipe plus de 70 % des utilisateurs mobiles, suivi de Samsung (série Galaxy A entrée de gamme) et Xiaomi (Redmi). Apple (iPhone) représente moins de 5 % du parc, concentré sur une frange aisée ou utilisant des modèles reconditionnés anciens (iPhone 8 à 11).
- **Spécifications Techniques Moyennes des Terminaux :**
  - **Mémoire RAM :** 1 Go à 3 Go de RAM (forte présence d'Android Go Edition).
  - **Stockage Interne :** 16 Go à 64 Go, dont 80 % est chroniquement saturé par les vidéos et photos transférées sur les groupes WhatsApp.
  - **Processeur :** SoCs d'entrée de gamme (MediaTek Helio A22/G25, Unisoc SC9863A). Faible puissance de calcul monocœur.

### 4.2 Les Tueurs Agressifs de Processus d'Arrière-Plan (RAM Killers)
- **Surcouches Constructeurs Agressives :** Les surcouches HiOS (Tecno) et XOS (Infinix) intègrent des gestionnaires d'énergie extrêmes qui tuent sans préavis les processus d'arrière-plan dès que l'écran s'éteint ou que l'utilisateur bascule brièvement sur une autre application.
- **Règle d'Ingénierie Impérative :** Ne jamais compter sur des tâches de fond prolongées sur le terminal. Si l'utilisateur bascule sur l'application MTN MoMo pour valider son PIN, le navigateur ou l'application appelante risque d'être déchargé de la mémoire vive. La session et l'état d'attente doivent être sauvegardés de façon persistante et restaurés immédiatement au retour au premier plan.

### 4.3 Visibilité et Ergonomie en Plein Soleil
- **Conditions Lumineuses Extérieures :** Les usagers consultent très souvent leur écran en extérieur sous une forte luminosité tropicale (plus de 80 000 lux). Les dalles LCD des smartphones à bas coût manquent de contraste et de luminosité de crête.
- **Conséquence UI/UX :** Le contraste des textes et éléments interactifs doit impérativement respecter ou dépasser la norme **WCAG AA (ratio minimal 4.5:1, idéalement 7:1)**. Les textes en gris clair `#9ca3af` sur fond blanc sont totalement invisibles en extérieur et strictement interdits.

---

## 5. TABLEAU DE CORRESPONDANCE STRATÉGIQUE (SIGNAUX VS DÉCISIONS)

| Signal Terrain Observé | Mauvaise Décision Produit (Échec Garanti) | Bonne Décision Antigravity (Succès Éprouvé) |
| :--- | :--- | :--- |
| **Forfaits data payés au Mo** | Application mobile de 40 Mo à télécharger sur le Play Store. | **Micro-PWA web optimisée (< 300 Ko gzip)** ou bot conversationnel WhatsApp. |
| **Latence 3G et coupures** | Requêtes HTTP synchrones dépendantes d'un réseau parfait sans cache. | **Cache agressif, persistance locale (LocalStorage/MMKV), retries automatiques.** |
| **Paiement 90 % Mobile Money** | Paiement par carte bancaire Stripe / Paypal obligatoire. | **Intégration push USSD Mobile Money (Airtel / MTN) avec webhook asynchrone.** |
| **SMS OTP non reçus** | Blocage de l'inscription derrière un code SMS à 6 chiffres. | **Vérification WhatsApp Cloud API, Magic Link ou session persistante longue.** |
| **Pas de numéro de rue** | Champs d'adresse classiques (N°, Rue, Code Postal, Ville). | **Sélection par Ville / Arrondissement + Champ libre repères visuels + Vocal.** |
| **RAM limitée (1-2 Go)** | Frameworks JavaScript obèses, animations CSS complexes non matérielles. | **HTML sobre, CSS épuré, zéro fuite mémoire, DOM compact.** |
| **Délestages électriques** | Nécessité d'une connexion permanente pour consulter un reçu. | **Génération de tickets/reçus légers consultables 100 % hors ligne.** |
