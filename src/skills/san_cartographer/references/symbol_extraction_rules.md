# Règles d'Extraction Déterministe des Symboles & Numérotation de Lignes

Ce guide détaille les expressions régulières, les critères de détection syntaxique et les algorithmes de calcul de plages de lignes `#Lstart-Lend` appliqués par `repo_mapper.mjs`.

---

## 1. Principes Généraux de Calcul des Plages

Pour chaque symbole recensé, `san_cartographer` associe deux coordonnées de lignes :
- **`start`** : Ligne d'amorce de la déclaration (inclut les décorateurs associés pour Python ou les signatures multi-lignes).
- **`end`** : Ligne où se termine l'entité syntaxique.

### Algorithme 1 : Équilibrage d'Accolades `{ ... }` (JS, TS, PHP, Go, Prisma, Bruno)
1. Repérer la première accolade ouvrante `{` sur la ligne d'amorce ou dans les 12 lignes suivantes (cas des signatures longues).
2. Parcourir les lignes consécutives en éliminant au vol :
   - Les commentaires mono-lignes (`//` en JS/PHP/Go, `#` en Bruno).
   - Les commentaires multi-lignes (`/* ... */`).
   - Les chaînes de caractères (`"..."`, `'...'`, `` `...` ``).
3. Incrémenter le compteur de profondeur sur `{` et décrémenter sur `}`.
4. Dès que la profondeur repasse à zéro, la ligne courante constitue l'ancre `end`.
5. Si aucune accolade n'est requise (ex: alias de type ou constante), la détection s'arrête au premier point-virgule `;` ou à la fin de la déclaration.

### Algorithme 2 : Suivi d'Indentation (Python)
1. Calculer l'indentation de référence (nombre d'espaces/tabulations précédant le mot-clé `def` ou `class`).
2. Conserver les lignes de corps tant que l'indentation demeure strictement supérieure à l'indentation de référence (en ignorant les lignes vides et les commentaires `#`).
3. Gérer les docstrings multi-lignes (`"""` ou `'''`).
4. La dernière ligne non vide indentée correspond à la valeur `end`.

### Algorithme 3 : Délimiteur de Requête SQL (SQL)
1. Repérer l'amorce de l'instruction DDL (`CREATE TABLE`, `CREATE VIEW`, etc.).
2. Balayer les lignes jusqu'au point-virgule `;` terminal.

---

## 2. Règles par Langage

### 2.1. JavaScript / TypeScript / React / Next.js (`.js`, `.mjs`, `.cjs`, `.ts`, `.tsx`, `.jsx`)

| Élément | Détection / Regex | Exemple |
| :--- | :--- | :--- |
| **Fonction exportée** | `^export\s+(?:default\s+)?(?:async\s+)?function\s*([a-zA-Z0-9_$]*)` | `export async function calculateTotal(items: CartItem[])` |
| **Classe exportée** | `^export\s+(?:default\s+)?class\s+([a-zA-Z0-9_$]+)` | `export class AuthService extends BaseService` |
| **Constante / Composant** | `^export\s+(?:const\|let)\s+([a-zA-Z0-9_$]+)` | `export const UserProfile = ({ user }: Props) => {` |
| **Interface TypeScript** | `^(?:export\s+)?interface\s+([a-zA-Z0-9_$]+)` | `export interface PaymentPayload` |
| **Type TypeScript** | `^(?:export\s+)?type\s+([a-zA-Z0-9_$]+)\s*=` | `export type TransactionStatus = 'pending' \| 'paid'` |
| **Route Express / Hono** | Méthodes HTTP `router.(get|post|put|delete)("path", ...)` | `router.post('/checkout', authenticate, handleCheckout)` |
| **Route Next.js (App)** | `^export\s+(?:async\s+)?function\s+(GET\|POST\|PUT\|DELETE\|PATCH)` | `export async function POST(request: Request)` |
| **Imports** | Import statique ES ou `require` dynamique | `import { db } from '@/lib/db'` |

---

### 2.2. PHP (`.php`)

| Élément | Détection / Regex | Exemple |
| :--- | :--- | :--- |
| **Classe / Interface / Trait** | `^(?:abstract\s+\|final\s+)?(class\|interface\|trait)\s+([a-zA-Z0-9_$]+)` | `class OrderController extends Controller` |
| **Méthode / Fonction** | `^(?:(public\|protected\|private)\s+)?(?:static\s+)?function\s+([a-zA-Z0-9_$]+)` | `public function processPayment(Request $request)` |
| **Route Laravel** | Méthodes de routage `Route::(get|post|put|delete|resource)("path", ...)` | `Route::post('/webhooks/momo', [MomoController::class, 'handle'])` |
| **Imports d'espaces de nom** | `^use\s+([^;]+);` | `use App\Models\Transaction;` |

---

### 2.3. Python (`.py`)

| Élément | Détection / Regex | Exemple |
| :--- | :--- | :--- |
| **Fonction / Coroutine** | `^(?:async\s+)?def\s+([a-zA-Z0-9_]+)\s*\(` | `async def process_event(event: Event) -> bool:` |
| **Classe** | `^class\s+([a-zA-Z0-9_]+)(?:\(([^)]*)\))?:` | `class TransactionService(BaseService):` |
| **Route API (Décorateur)** | `^@(app\|router\|bp)\.(get\|post\|put\|delete\|route)\(` | `@router.post("/items") async def create_item(...)` |
| **Imports** | `^from\s+([\w.]+)\s+import` et `^import\s+([\w.]+)` | `from app.core.config import settings` |

---

### 2.4. Go (`.go`)

| Élément | Détection / Regex | Exemple |
| :--- | :--- | :--- |
| **Structure / Interface** | `^type\s+([a-zA-Z0-9_]+)\s+(struct\|interface)` | `type PaymentGateway struct` |
| **Fonction autonome** | `^func\s+([a-zA-Z0-9_]+)\s*\(` | `func NewClient(apiKey string) *Client` |
| **Méthode avec récepteur** | `^func\s+\(([^)]+)\)\s+([a-zA-Z0-9_]+)\s*\(` | `func (c *Client) Execute(req *Request) error` |
| **Imports** | `import "..."` et `import ( ... )` | `import "net/http"` |

---

### 2.5. Bases de Données & APIs (`.prisma`, `.sql`, `.bru`)

| Format | Détection / Regex | Exemple |
| :--- | :--- | :--- |
| **Prisma (`.prisma`)** | `^(model\|enum\|type)\s+([a-zA-Z0-9_]+)` | `model User { id String @id }` |
| **SQL (`.sql`)** | `^CREATE\s+(?:OR\s+REPLACE\s+)?(TABLE\|VIEW\|FUNCTION)\s+...` | `CREATE TABLE IF NOT EXISTS orders (...)` |
| **Bruno API (`.bru`)** | Bloc `meta { name: ... }` et `(get\|post\|put\|delete) { url: ... }` | `post { url: https://api.momo.com/v1/pay }` |
