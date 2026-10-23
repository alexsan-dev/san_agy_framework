# Contrat d'Interface Technique : `[DOMAINE]_[ACTION]`

> **Statut Contract-First :** Ce document fige la spécification formelle de l'endpoint avant toute écriture de code client ou serveur. Il est lié à la collection Bruno correspondante dans `bruno/[domaine]/[action].bru`.

---

## 1. MÉTADONNÉES DE L'ENDPOINT

| Propriété | Spécification Contractuelle |
| :--- | :--- |
| **Méthode HTTP :** | `POST` / `GET` / `PUT` / `PATCH` / `DELETE` |
| **Route / URI :** | `/api/v1/[domaine]/[ressource]` |
| **Nom de l'Action :** | `[Domaine]\[NomAction]Action` |
| **Authentification :** | `Bearer Token (Sanctum / JWT RS256)` ou `Public` |
| **Rate Limit (Throttle) :** | `throttle:60,1` (60 requêtes par minute par IP/User) |
| **Idempotence :** | `Obligatoire (En-tête Idempotency-Key UUIDv4)` / `Non applicable (GET)` |

---

## 2. EN-TÊTES HTTP REQUIS

```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer <auth_token>
Idempotency-Key: <UUIDv4>
```

---

## 3. SCHÉMA DU CORPS DE REQUÊTE (REQUEST BODY JSON)

```json
{
  "wallet_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "amount": 25000,
  "currency": "XAF",
  "provider": "MTN_MOMO",
  "phone_number": "+242069123456",
  "reference": "CMD-2026-10-8842",
  "metadata": {
    "order_id": "ORD-9912",
    "customer_name": "M. Ngoma"
  }
}
```

### Règles de Validation Associées :
- `wallet_id` : string, uuid, obligatoire, existe dans `wallets.id`.
- `amount` : integer, obligatoire, >= 100, <= 5000000 (exprimé en sous-unités / centimes).
- `currency` : string, obligatoire, enum (`XAF`, `XOF`, `EUR`, `USD`).
- `provider` : string, obligatoire, enum (`MTN_MOMO`, `AIRTEL_MONEY`, `ORANGE_MONEY`, `WAVE`).
- `phone_number` : string, obligatoire, format E.164 (`^\+[1-9]\d{1,14}$`).
- `reference` : string, obligatoire, unique dans `transactions.reference`, max 64 caractères.
- `metadata` : object, optionnel.

---

## 4. RÉPONSES HTTP NORMALISÉES

### 4.1 Succès : `201 Created` / `200 OK`
```json
{
  "success": true,
  "data": {
    "transaction_id": "7f3e2a1b-4c5d-6e7f-8a9b-0c1d2e3f4a5b",
    "reference": "CMD-2026-10-8842",
    "status": "PENDING",
    "amount": 25000,
    "currency": "XAF",
    "created_at": "2026-10-23T14:35:00Z"
  },
  "meta": {
    "correlation_id": "req-9883bca2-11ef",
    "timestamp": "2026-10-23T14:35:00Z"
  }
}
```

### 4.2 Erreur Métier : `422 Unprocessable Entity`
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Solde insuffisant pour couvrir le montant et les frais de transfert.",
    "details": {
      "required": 25000,
      "available": 8400,
      "currency": "XAF"
    }
  },
  "meta": {
    "correlation_id": "req-9883bca2-11ef",
    "timestamp": "2026-10-23T14:35:00Z"
  }
}
```

### 4.3 Erreur d'Idempotence en Concurrence : `409 Conflict`
```json
{
  "success": false,
  "error": {
    "code": "TRANSACTION_IN_PROGRESS",
    "message": "Une transaction avec cette clé d'idempotence est actuellement en cours de traitement."
  },
  "meta": {
    "correlation_id": "req-9883bca2-11ef",
    "timestamp": "2026-10-23T14:35:00Z"
  }
}
```

---

## 5. TRAÇABILITÉ & TESTS AUTOMATISÉS BRUNO

- **Fichier Bruno associé :** `bruno/[domaine]/[action].bru`
- **Commande d'exécution CLI :**
  ```bash
  bru run bruno/[domaine]/[action].bru --env local
  ```
