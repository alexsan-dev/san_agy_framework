---
trigger: glob
globs: "*controller*, *Controller*, *route*, *api*, *.bru, *openapi*, *schema*, *dto*, *migration*"
description: "API contract standards (OpenAPI/Zod/Bruno), JSON envelope, DB transactions, and idempotency."
---
# CONVENTIONS D'API REST & PROTOCOLE CLIENT-SERVEUR (`API.md`)

> **Contrat d'échange souverain :** Toute interface de programmation (REST ou WebSockets) exposée ou consommée par ce projet doit respecter sans dérogation les formats et protocoles décrits dans ce document.

---

## 1. FORMAT NORMALISÉ DES RÉPONSES JSON (ENVELOPPE CANONIQUE)

Toutes les réponses de l'API respectent une structure invariante composée de 4 clés : `success`, `data`, `error` et `meta`.

### A. Réponse de Succès (`200 OK`, `201 Created`, `202 Accepted`)
```json
{
  "success": true,
  "data": {
    "id": "res_01j98ab76cd5efgh",
    "name": "Exemple Ressource",
    "status": "active"
  },
  "meta": {
    "timestamp": "2026-10-31T12:00:00Z",
    "version": "v1",
    "request_id": "req_01j98ab89xyz"
  }
}
```

### B. Réponse de Succès avec Pagination
Pour toute liste de ressources paginée, l'objet `meta.pagination` est obligatoire :
```json
{
  "success": true,
  "data": [
    { "id": "item_01", "name": "Élément 1", "status": "active" },
    { "id": "item_02", "name": "Élément 2", "status": "completed" }
  ],
  "meta": {
    "timestamp": "2026-10-31T12:00:00Z",
    "version": "v1",
    "request_id": "req_01j98ab90abc",
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 142,
      "last_page": 8,
      "has_more": true
    }
  }
}
```

### C. Réponse d'Erreur (`400`, `401`, `403`, `404`, `409`, `422`, `429`, `500`)
En cas d'échec ou d'erreur de validation, `data` est absent ou `null`, et l'objet `error` est systématiquement renseigné :
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Les données soumises comportent des erreurs de validation.",
    "details": {
      "field_name": [
        "Ce champ est obligatoire.",
        "Le format doit respecter la règle spécifiée."
      ]
    }
  },
  "meta": {
    "timestamp": "2026-10-31T12:00:00Z",
    "request_id": "req_01j98ab91err"
  }
}
```

### Nomenclature Standard des Codes d'Erreur Métier
L'attribut `error.code` est une chaîne normalisée en majuscules :
* `UNAUTHORIZED` : Jeton d'authentification absent, invalide ou expiré (HTTP 401).
* `FORBIDDEN` : Droits insuffisants pour accéder à cette ressource (HTTP 403).
* `RESOURCE_NOT_FOUND` : Identifiant ou enregistrement introuvable (HTTP 404).
* `VALIDATION_FAILED` : Échec des contraintes de champs (HTTP 422).
* `OPERATION_IN_PROGRESS` : Requête concurrente en cours pour cette clé d'idempotence (HTTP 409).
* `CONFLICT` : Conflit d'état ou violation d'unicité (HTTP 409).
* `RATE_LIMIT_EXCEEDED` : Seuil maximal d'appels par minute franchi (HTTP 429).
* `INTERNAL_SERVER_ERROR` : Erreur serveur inattendue (HTTP 500).

---

## 2. TRANSACTIONS DE BASE DE DONNÉES OBLIGATOIRES

Toute opération impliquant des écritures sur plusieurs tables ou entités liées **DOIT ÊTRE ENCAPSULÉE DANS UNE TRANSACTION ACID** :

```typescript
// Exemple TypeScript / Prisma / TypeORM / Kysely
await db.transaction(async (trx) => {
  const order = await trx.orders.create({ data: orderData });
  await trx.inventory.decrement({ itemId, quantity });
  await trx.auditLog.create({ action: 'ORDER_CREATED', targetId: order.id });
  return order;
});
```

* Interdiction formelle des écritures partielles en base de données.
* En cas d'erreur ou d'exception, rollback automatique sans laisser d'orphelins.

---

## 3. GESTION STRICTE DE L'IDEMPOTENCE (`Idempotency-Key`)

Pour prévenir les créations en double lors d'instabilités réseau, toute requête mutante (`POST`, `PATCH`, `PUT`) à enjeu financier ou de création d'entité exige un en-tête d'idempotence :

```http
POST /api/v1/orders HTTP/1.1
Host: api.example.com
Authorization: Bearer <token>
Content-Type: application/json
Idempotency-Key: a5f2b841-8c43-4e89-b1d3-35f9227c819a
```

### Protocole de Verrouillage Déterministe (Redis)
1. **Émission initiale :** Le client génère un UUIDv4 unique avant l'émission.
2. **Phase de verrouillage (Lock) :** Le backend exécute `SETNX idempotency:<UUID> "IN_PROGRESS" EX 60`.
3. **Collision concurrente :** Si la clé existe avec `IN_PROGRESS`, renvoi immédiat de HTTP `409 Conflict` (`OPERATION_IN_PROGRESS`).
4. **Mémorisation du résultat (Cache 24h) :** Traitement terminé $\rightarrow$ sauvegarde du code HTTP et du JSON de réponse avec TTL de 24h (`EX 86400`).
5. **Rejeu transparent (Cached Replay) :** En cas de rejeu avec la même clé, renvoi instantané de la réponse mémorisée (`X-Cache-Lookup: HIT`) sans réexécuter l'action métier.

---

## 4. SUITE DE CONTRATS & TESTS D'API BRUNO (`bruno/`)

Toutes les requêtes de l'API sont modélisées et testées sous forme de fichiers `.bru` dans le répertoire versionné `bruno/` :

### Exemple de Spécification de Test Bruno (`create_item.bru`)
```bru
meta {
  name: Créer un Élément
  type: http
  seq: 1
}

post {
  url: {{baseUrl}}/api/v1/items
  body: json
  auth: bearer
}

headers {
  Idempotency-Key: {{guid}}
}

body:json {
  {
    "title": "Nouvel Élément",
    "quantity": 1,
    "category": "standard"
  }
}

assert {
  res.status: eq 201
  res.body.success: eq true
  res.body.data.id: isDefined
  res.body.meta.request_id: isDefined
}
```
