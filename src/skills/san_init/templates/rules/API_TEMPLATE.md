# CONVENTIONS D'API REST & PROTOCOLE CLIENT-SERVEUR (`API.md`)

> **Contrat d'échange souverain :** Toute interface de programmation (REST ou WebSockets) exposée ou consommée par ce projet doit respecter sans dérogation les formats et protocoles décrits dans ce document.

---

## 1. FORMAT NORMALISÉ DES RÉPONSES JSON (ENVELOPPE CANONIQUE)

Toutes les réponses de l'API respectent une structure invariante composée de 4 clés potentielles : `success`, `data`, `error` et `meta`.

### A. Réponse de Succès (`200 OK`, `201 Created`, `202 Accepted`)
```json
{
  "success": true,
  "data": {
    "id": "usr_01j98ab76cd5efgh",
    "phone": "+242061234567",
    "name": "Jean Makaya",
    "status": "active"
  },
  "meta": {
    "timestamp": "2026-10-23T12:00:00Z",
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
    { "id": "tx_01", "amount": 15000, "currency": "XAF", "status": "completed" }
  ],
  "meta": {
    "timestamp": "2026-10-23T12:00:00Z",
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
En cas d'échec ou d'erreur de validation, `data` est absent ou nul, et l'objet `error` est systématiquement renseigné :
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_FAILED",
    "message": "Les données soumises comportent des erreurs de validation.",
    "details": {
      "phone": [
        "Le numéro de téléphone Mobile Money est obligatoire.",
        "Le format doit respecter la norme E.164 (ex: +242061234567)."
      ],
      "amount": [
        "Le montant minimum de transfert est de 500 XAF."
      ]
    }
  },
  "meta": {
    "timestamp": "2026-10-23T12:00:00Z",
    "request_id": "req_01j98ab91err"
  }
}
```

### Nomenclature des Codes d'Erreur Métier
L'attribut `error.code` est une chaîne de caractères majuscule normalisée permettant au client mobile/web d'adapter son interface sans parser le message textuel :
* `UNAUTHORIZED` : Jeton d'authentification absent, invalide ou expiré (HTTP 401).
* `FORBIDDEN` : Droits insuffisants pour accéder à cette ressource (HTTP 403).
* `RESOURCE_NOT_FOUND` : Identifiant ou enregistrement introuvable (HTTP 404).
* `VALIDATION_FAILED` : Échec des contraintes de champs (HTTP 422).
* `OPERATION_IN_PROGRESS` : Requête concurrente en cours de traitement pour cette clé d'idempotence (HTTP 409).
* `INSUFFICIENT_FUNDS` : Solde insuffisant pour exécuter la transaction (HTTP 422).
* `RATE_LIMIT_EXCEEDED` : Seuil maximal d'appels par minute franchi (HTTP 429).
* `INTERNAL_SERVER_ERROR` : Erreur serveur inattendue (HTTP 500).

---

## 2. GESTION STRICTE DE L'IDEMPOTENCE (`Idempotency-Key`)

Pour prévenir les doubles débits et les créations de doublons en présence de réseaux instables (3G / micro-coupures), toute requête mutante à enjeu financier ou de création exige un en-tête d'idempotence :

```http
POST /api/v1/payments/transfers HTTP/1.1
Host: api.example.com
Authorization: Bearer <token>
Content-Type: application/json
Idempotency-Key: a5f2b841-8c43-4e89-b1d3-35f9227c819a
```

### Mécanisme de Verrouillage & Rejeu Déterministe (Redis)
1. **Émission initiale :** Le client génère un UUIDv4 unique avant l'émission de la requête.
2. **Phase de verrouillage (Lock) :** Le backend tente un `SETNX idempotency:<UUID> "IN_PROGRESS" EX 60`.
3. **Collision en cours de traitement :** Si la clé existe déjà avec le statut `IN_PROGRESS`, le serveur renvoie immédiatement HTTP `409 Conflict` avec le code `OPERATION_IN_PROGRESS`.
4. **Mémorisation du résultat (Cache 24h) :** Dès que le traitement métier est complété, le backend enregistre le code de statut HTTP et le corps de réponse JSON dans Redis avec un TTL de 24 heures (`EX 86400`).
5. **Rejeu transparent (Cached Replay) :** Si une requête ultérieure présente la même clé d'idempotence, le serveur renvoie instantanément la réponse mémorisée avec l'en-tête `X-Cache-Lookup: HIT`, sans réexécuter l'action métier.

---

## 3. PROTOCOLE WEBSOCKETS & ÉVÉNEMENTS TEMPS RÉEL

Lorsqu'un canal bidirectionnel WebSockets est employé (mise à jour de soldes, statut de livraison, géolocalisation de véhicules) :

### Format Canonique de Trame WebSocket
```json
{
  "event": "transaction.completed",
  "channel": "user.usr_01j98ab76cd5efgh",
  "data": {
    "transaction_id": "tx_01j98ac",
    "amount": 25000,
    "currency": "XAF",
    "status": "completed",
    "balance_after": 142500
  },
  "timestamp": "2026-10-23T12:05:30Z"
}
```

### Règles de Résilience Réseau
* **Heartbeat / Ping-Pong :** Émission d'un ping toutes les 30 secondes pour maintenir les sockets ouverts à travers les passerelles des opérateurs télécoms mobiles.
* **Reconnexion avec Backoff Exponentiel :** En cas de déconnexion inopinée, les tentatives de reconnexion s'échelonnent selon la progression : `1s`, `2s`, `4s`, `8s`, `16s`, `30s max`.
* **Reprise d'Événements Manqués :** Lors de la reconnexion, le client transmet l'en-tête `Last-Event-Id` pour recevoir les notifications manquées pendant la coupure.

---

## 4. SUITE DE TESTS D'API BRUNO (`bruno/`)

Toutes les requêtes de l'API sont modélisées et testées sous forme de fichiers `.bru` dans le répertoire versionné `bruno/` :

### Structure du Répertoire Bruno
```
bruno/
├── bruno.json
├── environments/
│   ├── local.bru
│   └── staging.bru
├── auth/
│   ├── login.bru
│   └── verify_otp.bru
├── payments/
│   ├── initiate_momo_transfer.bru
│   └── check_transaction_status.bru
└── users/
    └── get_profile.bru
```

### Exemple de Spécification de Test Bruno (`initiate_momo_transfer.bru`)
```bru
meta {
  name: Initier un Transfert Mobile Money
  type: http
  seq: 1
}

post {
  url: {{baseUrl}}/api/v1/payments/transfers
  body: json
  auth: bearer
}

headers {
  Idempotency-Key: {{guid}}
}

body:json {
  {
    "recipient_phone": "+242061234567",
    "amount": 5000,
    "currency": "XAF",
    "provider": "AIRTEL_MONEY"
  }
}

assert {
  res.status: eq 201
  res.body.success: eq true
  res.body.data.status: eq "pending"
  res.body.meta.request_id: isDefined
}
```
