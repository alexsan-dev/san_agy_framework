# Référentiel SEO Local Afrique & Bassin Congo (Brazzaville, Pointe-Noire, Kinshasa)

> **Framework :** Google Antigravity (`san_*`) — Stratégie de visibilité locale souveraine (`alexsan.pro`).  
> **Auteur Référent :** `san_growth_expert`  
> **Marché Cible :** Congo-Brazzaville (CG - Zone CEMAC) & RDC (CD - Kinshasa).

---

## 1. COMPRÉHENSION DE LA GÉOLOCALISATION URBAINE EN AFRIQUE CENTRALE

Contrairement aux villes occidentales où l'adressage postal est numéroté et standardisé (ex: *12 rue de la Paix*), la recherche locale et la livraison au Congo et en RDC s'articulent autour de trois piliers fondamentaux :
1. **Les Quartiers Historiques et Arrondissements :** Les utilisateurs recherchent systématiquement par quartier (ex: *Bacongo*, *Poto-Poto*, *Tié-Tié*, *Gombe*).
2. **Les Repères Urbains (*Landmarks*) :** Les ronds-points célèbres, grands marchés, avenues structurantes, stations-service ou édifices religieux servent d'adresses physiques concrètes.
3. **Les Moyens de Paiement et Devises Locales :** La mention explicite de **MTN MoMo**, **Airtel Money** et du **Franc CFA (XAF)** dans les balises de contenu génère un taux de clic (*CTR*) et une intention de conversion largement supérieurs.

---

## 2. CARTOGRAPHIE GÉOGRAPHIQUE DES MOTS-CLÉS PAR VILLE

### A. Brazzaville (République du Congo — Code Pays : CG / Zone CEMAC : XAF)

#### Arrondissements et Quartiers Clés :
* **Arrondissement 1 Makélékélé :** Makélékélé, Château d'Eau, Diata.
* **Arrondissement 2 Bacongo :** Bacongo, Marché Total, Case de Gaulle, Dahomey.
* **Arrondissement 3 Poto-Poto :** Poto-Poto, Rond-point Poto-Poto, Avenue de la Paix, Grand Marché.
* **Arrondissement 4 Moungali :** Moungali, Dix-Maisons, Marché Moungali.
* **Arrondissement 5 Ouenzé :** Ouenzé, Texaco, Cinq-Chemins, Marché Ouenzé.
* **Arrondissement 6 Talangaï :** Talangaï, Petit-Chose, Intendance, Kintélé.
* **Arrondissement 7 Mfilou :** Mfilou, PK Rouge, Ngoyo.
* **Arrondissement 8 Madibou & 9 Djiri.**

#### Repères Urbains Majeurs (*Landmarks*) :
* *Avenue des Trois Martyrs*, *Avenue de la Paix*, *Boulevard Denis Sassou Nguesso*, *La Corniche de Brazzaville*, *Marché Total*, *Gare Centrale de Brazzaville*, *Aéroport International Maya-Maya*, *Tours Jumelles de Mpila*.

---

### B. Pointe-Noire (Capitale Économique du Congo — Code Pays : CG)

#### Arrondissements et Quartiers Clés :
* **Arrondissement 1 Émery Patrice Lumumba :** Centre-ville, Côte Sauvage, Port Autonome, Plateau.
* **Arrondissement 2 Mvou-Mvou :** Mvou-Mvou, Rond-point Thystère.
* **Arrondissement 3 Tié-Tié :** Tié-Tié, Grand Marché de Tié-Tié, Fond Tié-Tié.
* **Arrondissement 4 Loandjili :** Loandjili, Hôpital Général, Ngoyo.
* **Arrondissement 5 Mongo-Poukou & 6 Ngoyo.**

#### Repères Urbains Majeurs (*Landmarks*) :
* *Gare CFCO de Pointe-Noire*, *Rond-point Lumumba*, *Aéroport International Agostinho-Neto*, *Grand Marché*, *Avenue Charles de Gaulle*, *Base Industrielle pétrolière*.

---

### C. Kinshasa (République Démocratique du Congo — Code Pays : CD / Devises : USD / CDF)

#### Communes Clés :
* **Gombe :** Centre d'affaires, Boulevard du 30 Juin, Ambassades.
* **Limete :** Échangeur de Limete, 1ère à 18ème Rue.
* **Ngaliema & Kintambo :** Binza, Macampagne, UPN.
* **Bandalungwa & Kasa-Vubu :** Place Victoire, Avenue Kasa-Vubu.

---

## 3. INTENTIONS DE RECHERCHE LOCALES CONGOLAISES & STRUCTURE DE TITRES

### Typologie d'Intentions Réelles :
1. **Transactionnelle Immédiate :**
   * *« Vente iPhone neuf Brazzaville paiement MTN MoMo »*
   * *« Commander courses en ligne livraison Pointe-Noire Tié-Tié »*
   * *« Boutique vêtements homme Bacongo Marché Total »*
2. **Recherche de Service de Proximité :**
   * *« Point de retrait Mobile Money ouvert dimanche Brazzaville »*
   * *« Agence de transfert d'argent Airtel Money Pointe-Noire »*
3. **Requête Marque + Localisation :**
   * *« alexsan pro Brazzaville avis et téléphone »*
   * *« application de paiement Congo XAF »*

### Gabarit de Titre Optimisé (<title>) :
```html
<title>[Bénéfice Clé / Produit] à [Quartier], [Ville] | [Moyen de Paiement / Marque]</title>
<!-- Exemple concret conforme : -->
<title>Livraison Express Courses à Bacongo, Brazzaville | Payez par MTN MoMo & Airtel</title>
```

---

## 4. BALISAGE SCHEMA.ORG JSON-LD LOCALISÉ CONGO

### Gabarit Certifié : `LocalBusiness` Ancré à Brazzaville
```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Boutique alexsan.pro Brazzaville Bacongo",
  "image": "https://alexsan.pro/images/store-bacongo.webp",
  "telephone": "+242060000000",
  "url": "https://alexsan.pro",
  "priceRange": "FCFA",
  "currenciesAccepted": "XAF",
  "paymentAccepted": "Cash, MTN Mobile Money, Airtel Money",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "Avenue de l'Auberge Gascogne, Face Marché Total Bacongo",
    "addressLocality": "Brazzaville",
    "addressRegion": "Pool",
    "postalCode": "00242",
    "addressCountry": "CG"
  },
  "geo": {
    "@type": "GeoCoordinates",
    "latitude": -4.2755,
    "longitude": 15.2638
  },
  "openingHoursSpecification": [
    {
      "@type": "OpeningHoursSpecification",
      "dayOfWeek": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"],
      "opens": "07:30",
      "closes": "19:00"
    }
  ]
}
</script>
```

---

## 5. RÈGLES DE RÉDACTION SÉMANTIQUE LOCALE

* **Devises Systématiques :** Toujours spécifier explicitement **FCFA** ou **XAF**. Ne jamais utiliser de symboles ambigus comme `$` ou `€` sauf pour des cotations internationales expressément libellées en devises étrangères.
* **Repères dans le Balisage :** Toujours préciser dans la propriété `streetAddress` le repère urbain reconnu (ex: *« Face Station Total »*, *« À côté du Rond-Point »*, *« Près du Grand Marché »*).
* **Numéros de Téléphone :** Format international standard `+242` obligatoire pour permettre le déclenchement immédiat de l'appel ou de la discussion WhatsApp au clic mobile.
