# Contrat d'Endpoint : [DOMAINE] / [ACTION]

## 1. MÉTADONNÉES TECHNIQUES
- **Identifiant Unique :** `[DOMAINE]_[ACTION]` (ex: `payments_momo_charge`)
- **Méthode HTTP :** `POST` | `GET` | `PUT` | `PATCH` | `DELETE`
- **URI Définitive :** `/api/v1/[ressource]`
- **Authentification :** `Bearer <Token>` (Sanctum/JWT) | `Public`
- **Idempotence :** `Obligatoire (Idempotency-Key UUIDv4)` | `Non applicable`
- **Rate-Limiting :** `60 requêtes/minute par IP/Utilisateur`

## 2. EN-TÊTES HTTP REQUIS
| En-tête | Obligatoire | Valeur attendue | Description |
| :--- | :---: | :--- | :--- |
| `Content-Type` | OUI | `application/json` | Encodage du payload d'entrée |
| `Accept` | OUI | `application/json` | Format de réponse attendu |
| `Idempotency-Key` | Conditionnel | `UUIDv4` | Verrou d'idempotence 24h pour mutations |
| `Authorization` | Conditionnel | `Bearer <token>` | Session sécurisée |

## 3. SCHÉMA DU PAYLOAD DE REQUÊTE (ZOD & TYPESCRIPT)
```typescript
import { z } from "zod";

export const [Action]PayloadSchema = z.object({
  // Définir les champs typés et validés
});

export type [Action]Payload = z.infer<typeof [Action]PayloadSchema>;
```

## 4. SCHÉMAS DES RÉPONSES NORMALISÉES

### Succès (HTTP 200 / 201) :
```json
{
  "success": true,
  "data": {
    "id": "res_001",
    "status": "COMPLETED",
    "created_at": "2026-10-23T12:00:00Z"
  },
  "meta": {
    "timestamp": 1792756800,
    "idempotency_replayed": false
  }
}
```

### Conflit d'Idempotence (HTTP 409) :
```json
{
  "success": false,
  "error": {
    "code": "OPERATION_IN_PROGRESS",
    "message": "Une opération avec cette clé d'idempotence est déjà en cours de traitement.",
    "details": {
      "retry_after_ms": 2000
    }
  }
}
```

### Erreur de Validation (HTTP 422) :
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Les données soumises sont invalides.",
    "details": {
      "field_name": ["Le champ est requis."]
    }
  }
}
```

## 5. REQUÊTE BRUNO ASSOCIÉE
Fichier localisé dans : `bruno/[domaine]/[action].bru`.
