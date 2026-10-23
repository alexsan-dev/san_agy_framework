# PLAN DE TAGGAGE ANALYTIQUE UNIFIÉ (*TRACKING PLAN*)

> **Application / Projet :** [Nom du Produit Mobile & Web]  
> **Auteur Responsable :** `san_growth_expert`  
> **Conventions Techniques :** `snake_case` strict, typage systématique, devise pivot `XAF`  
> **Outils Connectés :** Firebase Analytics (Mobile), GA4 (Web), Meta Pixel, Sentry  
> **Statut de Validation :** [En Cours / Validé Production]  

---

## 1. INVENTAIRE DES ÉVÉNEMENTS BUSINESS STANDARDS

| Nom de l'Événement | Description & Déclencheur UI | Paramètres Obligatoires | Typage Paramètres | Destinations Cibles |
| :--- | :--- | :--- | :--- | :--- |
| `screen_view` | Affichage d'un nouvel écran de l'application | `screen_name`<br>`screen_class` | `string`<br>`string` | Firebase, GA4 |
| `sign_up` | Validation finale de l'inscription utilisateur | `method`<br>`user_role` | `"phone_otp" \| "email"`<br>`"customer" \| "merchant"` | Firebase, GA4, Meta |
| `login` | Connexion réussie à l'application | `method` | `"phone_otp" \| "password"` | Firebase, GA4 |
| `search_executed` | Soumission d'une requête dans la barre de recherche | `search_term`<br>`results_count` | `string`<br>`integer` | Firebase, GA4 |
| `view_item` | Consultation de la page détaillée d'un article | `item_id`<br>`item_name`<br>`price`<br>`currency` | `string`<br>`string`<br>`number`<br>`"XAF"` | Firebase, GA4, Meta |
| `add_to_cart` | Clic sur le bouton « Ajouter au panier » | `item_id`<br>`quantity`<br>`price`<br>`currency` | `string`<br>`integer`<br>`number`<br>`"XAF"` | Firebase, GA4, Meta |
| `begin_checkout` | Arrivée sur l'écran de sélection de livraison/paiement | `value`<br>`currency`<br>`items_count` | `number`<br>`"XAF"`<br>`integer` | Firebase, GA4, Meta |
| `select_payment` | Sélection du moyen de paiement | `payment_method` | `"mtn_momo" \| "airtel_money" \| "cash"` | Firebase, GA4 |
| `purchase_momo` | Validation finale du paiement Mobile Money | `transaction_id`<br>`value`<br>`currency`<br>`operator` | `string`<br>`number`<br>`"XAF"`<br>`"mtn" \| "airtel"` | Firebase, GA4, Meta |
| `account_deleted` | Suppression effective du compte utilisateur (Apple 5.1.1) | `method`<br>`reason` | `"in_app" \| "web_portal"`<br>`string` | Firebase, GA4 |

---

## 2. RÈGLES DE TYPAGE ET NORMALISATION DES PARAMÈTRES

1. **Devises Obligatoires :** Toujours spécifier `currency: "XAF"` pour toute transaction libellée en Franc CFA.
2. **Valeurs Numériques :** Les montants doivent impérativement être transmis sous forme numérique entière ou décimale (`value: 5000` et non `"5 000 FCFA"`).
3. **Identifiants Déterministes :** Les `transaction_id` et `item_id` doivent correspondre aux clés primaires réelles en base de données pour permettre la réconciliation comptable.

---

## 3. IMPLÉMENTATION TYPE DANS LE CODE CLIENT (REACT NATIVE / EXPO)

```typescript
// hooks/useAnalytics.ts
import analytics from '@react-native-firebase/analytics';

export const useAnalytics = () => {
  const trackEvent = async (eventName: string, params: Record<string, any> = {}) => {
    try {
      if (!__DEV__) {
        await analytics().logEvent(eventName, params);
      } else {
        console.log(`[ANALYTICS-DEV] Event: ${eventName}`, params);
      }
    } catch (error) {
      console.warn(`[ANALYTICS-ERROR] Failed to log ${eventName}:`, error);
    }
  };

  const trackPurchase = async (transactionId: string, amountXaf: number, operator: 'mtn' | 'airtel') => {
    await trackEvent('purchase_momo', {
      transaction_id: transactionId,
      value: amountXaf,
      currency: 'XAF',
      operator: operator,
    });
  };

  return { trackEvent, trackPurchase };
};
```

---

## 4. CHECKLIST D'ASSURANCE QUALITÉ & AUDIT DEBUGVIEW

- [ ] **Vérification Firebase DebugView :** Chaque clic sur un bouton d'action n'émet qu'un seul et unique événement (zéro doublon).
- [ ] **Sobriété Réseau :** Les requêtes d'analytics sont regroupées en batchs asynchrones et ne bloquent pas le rendu initial.
- [ ] **Respect RGPD & Privacy :** Aucun mot de passe ni coordonnée bancaire secrète n'est transmis dans les paramètres d'analytics.
- [ ] **Alignement Légal :** Tous les outils de tracking déclarés ci-dessus figurent fidèlement dans `docs/PRIVACY_POLICY.md` et `docs/DATA_MAP.md`.
