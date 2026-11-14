# 🧭 REPO RADAR (v2.0)
- **Fichiers**: 42 | **Symboles**: 215 | **Horodatage**: 2026-11-07T03:00:00.000Z
- **Langages**: typescript (70%), php (20%), sql (10%)
- **Points d'Entrée**: `src/index.ts`, `routes/api.php`
- **Domaines Métier**:
  - `src/auth`: Authentification JWT, gestion des sessions Redis et RBAC.
  - `src/services/billing`: Intégration passerelles de paiement (MoMo, Cartes) et facturation.
  - `src/legacy`: ⚠️ _[Non résumé — hydrater via san_researcher]_
- **Accès Rapide**: `.agents/cache/REPO_MAP.md` (Cartographie détaillée)

---

# 🗺️ CARTOGRAPHIE DÉTAILLÉE DU RÉPERTOIRE

## 📁 `src/auth`
> **Résumé Métier :** Authentification JWT, gestion des sessions Redis et RBAC.

### `src/auth/jwt_service.ts` (85 lignes)
- **Imports :** `jsonwebtoken`, `../config/security`
- **Symboles :**
  - `export class JwtService` [#L12-L75](#L12-L75)
  - `export function verifyToken(token: string)` [#L77-L84](#L77-L84)

## 📁 `src/services/billing`
> **Résumé Métier :** Intégration passerelles de paiement (MoMo, Cartes) et facturation.

### `src/services/billing/momo_client.ts` (112 lignes)
- **Imports :** `axios`, `crypto`, `./types`
- **Symboles :**
  - `interface PaymentRequest` [#L8-L22](#L8-L22)
  - `export class MomoClient` [#L24-L95](#L24-L95)
  - `export async function initiatePayment(req: PaymentRequest)` [#L97-L110](#L97-L110)

## 📁 `src/legacy`
> **Résumé Métier :** _[Résumé métier en attente — hydrater via san-researcher]_

### `src/legacy/old_utils.ts` (45 lignes)
- **Imports :** `lodash`
- **Symboles :**
  - `export function sanitize(input: string)` [#L5-L25](#L5-L25)
