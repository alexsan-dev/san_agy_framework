# Gabarits de Données Structurées Schema.org JSON-LD
# Framework Antigravity (`san_*`) — Moteur `san_growth_expert`

Ce document technique présente les gabarits Schema.org prêts à l'emploi pour le SEO local et les applications mobiles.

---

## 1. GABARIT `LocalBusiness` (Brazzaville / Pointe-Noire / Kinshasa)

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

## 2. GABARIT `MobileApplication`

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "MobileApplication",
  "name": "Alexsan Pay Mobile",
  "operatingSystem": "Android, iOS",
  "applicationCategory": "FinanceApplication",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "XAF"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.8",
    "reviewCount": "1250"
  }
}
</script>
```
