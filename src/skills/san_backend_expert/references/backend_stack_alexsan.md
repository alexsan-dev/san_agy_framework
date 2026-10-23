# Normes & Standards Backend Souverains alexsan.pro

> Ce document établit le référentiel d'ingénierie logicielle pour tous les composants serveur du framework Antigravity (`san_*`). Chaque ligne de code backend doit impérativement respecter les règles de typage, de découplage et de sûreté transactionnelle détaillées ci-après.

---

## 1. PILE 1 : PHP 8.2+ & LARAVEL MODERNE

### 1.1 Typage Strict & Déclaration de Fichier
Chaque fichier PHP (.php) du projet doit comporter sans exception la directive de typage strict dès la première ligne après l'ouverture de balise :

```php
<?php

declare(strict_types=1);
```

Tous les paramètres de méthode, retours de fonction et propriétés de classe doivent être explicitement typés (types scalaires, objets, unions, retours `void` ou `never`). L'usage du pseudo-type `mixed` est formellement restreint aux seuls cas où une valeur arbitraire non déterministe est expressément requise (ex: payloads d'événements polymorphes).

---

### 1.2 Le Modèle d'Architecture : Action-Domain Pattern
Pour bannir définitivement les contrôleurs obèses (*Fat Controllers*) et les modèles surchargés de logique métier (*Fat Models*), le code applicatif est structuré selon le patron **Action-Domain** :

```txt
app/
├── Actions/
│   └── [Domaine]/
│       ├── CreateOrderAction.php          # Classe à responsabilité unique (SRP)
│       └── CancelOrderAction.php
├── DTOs/
│   └── [Domaine]/
│       └── CreateOrderDTO.php             # Objet de transfert immuable typé
├── Http/
│   ├── Controllers/Api/V1/[Domaine]/
│   │   └── OrderController.php            # Contrôleur ultra-fin (< 30 lignes par méthode)
│   └── Requests/[Domaine]/
│       └── CreateOrderRequest.php         # Validation et autorisation déclaratives
```

#### Règle du Contrôleur Fin (*Thin Controller*)
Le contrôleur a pour unique mission :
1. Réceptionner la requête validée (`FormRequest`).
2. Mapper la requête vers un DTO immutable.
3. Déléguer l'exécution à l'Action appropriée.
4. Renvoyer une réponse HTTP normalisée.

```php
<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Wallet;

use App\Actions\Wallet\InitiateMoMoChargeAction;
use App\DTOs\Wallet\InitiateChargeDTO;
use App\Http\Requests\Wallet\InitiateChargeRequest;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

final class ChargeController
{
    public function store(InitiateChargeRequest $request, InitiateMoMoChargeAction $action): JsonResponse
    {
        $dto = InitiateChargeDTO::fromRequest($request);
        $transaction = $action->execute($dto);

        return response()->json([
            'success' => true,
            'data' => [
                'transaction_id' => $transaction->id,
                'reference' => $transaction->reference,
                'status' => $transaction->status,
                'amount' => $transaction->amount,
                'currency' => $transaction->currency,
            ],
        ], Response::HTTP_CREATED);
    }
}
```

---

### 1.3 DTO Immuable (Data Transfer Object)
Les DTOs encapsulent les données échangées entre le contrôleur et les couches métier. Ils utilisent les classes `readonly` de PHP 8.2 pour garantir l'immutabilité :

```php
<?php

declare(strict_types=1);

namespace App\DTOs\Wallet;

use App\Http\Requests\Wallet\InitiateChargeRequest;

final readonly class InitiateChargeDTO
{
    public function __construct(
        public string $walletId,
        public int $amountInCents,
        public string $currency,
        public string $provider,
        public string $phoneNumber,
        public string $reference,
        /** @var array<string, mixed> */
        public array $metadata = [],
    ) {}

    public static function fromRequest(InitiateChargeRequest $request): self
    {
        /** @var array{wallet_id: string, amount: int, currency: string, provider: string, phone_number: string, reference: string, metadata?: array<string, mixed>} $validated */
        $validated = $request->validated();

        return new self(
            walletId: $validated['wallet_id'],
            amountInCents: (int) $validated['amount'],
            currency: strtoupper($validated['currency']),
            provider: strtoupper($validated['provider']),
            phoneNumber: $validated['phone_number'],
            reference: $validated['reference'],
            metadata: $validated['metadata'] ?? [],
        );
    }
}
```

---

### 1.4 FormRequests Stricts & Politiques d'Autorisation
Toute requête mutatrice passe impérativement par une `FormRequest`. L'usage direct de `$request->all()` ou `$request->input()` au sein des contrôleurs est proscrit.

```php
<?php

declare(strict_types=1);

namespace App\Http\Requests\Wallet;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

final class InitiateChargeRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Autorisation liée à la Policy de portefeuille (anti-BOLA/IDOR)
        $walletId = (string) $this->input('wallet_id');
        $wallet = \App\Models\Wallet::find($walletId);

        return $wallet !== null && $this->user()?->can('charge', $wallet);
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'wallet_id' => ['required', 'uuid', 'exists:wallets,id'],
            'amount' => ['required', 'integer', 'min:100', 'max:5000000'],
            'currency' => ['required', 'string', Rule::in(['XAF', 'XOF', 'EUR', 'USD'])],
            'provider' => ['required', 'string', Rule::in(['MTN_MOMO', 'AIRTEL_MONEY', 'ORANGE_MONEY', 'WAVE'])],
            'phone_number' => ['required', 'string', 'regex:/^\+[1-9]\d{1,14}$/'],
            'reference' => ['required', 'string', 'max:64', 'unique:transactions,reference'],
            'metadata' => ['sometimes', 'array'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'phone_number.regex' => 'Le numéro de téléphone doit respecter le format international E.164 (ex: +242069123456).',
            'amount.min' => 'Le montant minimum par transaction est de 100 unités.',
        ];
    }
}
```

---

### 1.5 Mode Strict Eloquent & Prévention Active du N+1
Dans `AppServiceProvider::boot()`, le mode strict d'Eloquent doit obligatoirement être activé pour tous les environnements hors production :

```php
<?php

declare(strict_types=1);

namespace App\Providers;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\ServiceProvider;

final class AppServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        // Active le mode strict en local et staging :
        // 1. Déclenche une exception si lazy loading non désiré (N+1)
        // 2. Déclenche une exception si assignation d'un attribut non fillable
        // 3. Déclenche une exception en cas d'accès à un attribut non hydraté
        Model::shouldBeStrict(! $this->app->isProduction());

        // Garde-fou explicite redondant pour la prévention du N+1
        Model::preventLazyLoading(! $this->app->isProduction());
        Model::preventSilentlyDiscardingAttributes(! $this->app->isProduction());
        Model::preventAccessingMissingAttributes(! $this->app->isProduction());
    }
}
```

---

### 1.6 File d'Attente Redis & Stratégie de Résilience des Jobs
Tout traitement asynchrone (envoi d'e-mails transactionnels, push notifications, notifications webhook) est confié à un Job Laravel implémentant `ShouldQueue` avec un profil de reprise déterministe :

```php
<?php

declare(strict_types=1);

namespace App\Jobs\Payments;

use App\Models\Payment;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

final class ProcessPaymentWebhookJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    /** Nombre maximal de tentatives */
    public int $tries = 5;

    /** Délai maximal d'exécution en secondes avant timeout */
    public int $timeout = 60;

    /** Paliers d'attente exponentiels en secondes entre chaque retry */
    public array $backoff = [10, 30, 120, 600];

    /**
     * @param array<string, mixed> $webhookPayload
     */
    public function __construct(
        public readonly array $webhookPayload
    ) {}

    public function handle(): void
    {
        // Traitement déterministe et idempotent
    }

    public function failed(\Throwable $exception): void
    {
        Log::critical('Échec définitif du job de webhook de paiement après 5 tentatives.', [
            'payload' => $this->webhookPayload,
            'exception' => $exception->getMessage(),
            'trace' => $exception->getTraceAsString(),
        ]);

        // Acheminement vers table dédiée d'incidents / notification DevOps
    }
}
```

---

## 2. PILE 2 : ADONISJS V6 SOUS TYPESCRIPT STRICT

### 2.1 Configuration TypeScript Strict
Le fichier `tsconfig.json` d'AdonisJS v6 doit activer tous les indicateurs stricts du compilateur TypeScript :

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true
  }
}
```

---

### 2.2 Validation des Entrées avec VineJS
VineJS est le moteur de validation officiel et performant d'AdonisJS v6. Tous les validateurs doivent être compilés statiquement et inférer leurs types TypeScript automatiques :

```typescript
// app/validators/wallet_validator.ts
import vine from '@vinejs/vine'
import { Infer } from '@vinejs/vine/types'

export const initiateChargeValidator = vine.compile(
  vine.object({
    walletId: vine.string().uuid(),
    amount: vine.number().min(100).max(5_000_000),
    currency: vine.enum(['XAF', 'XOF', 'EUR', 'USD'] as const),
    provider: vine.enum(['MTN_MOMO', 'AIRTEL_MONEY', 'ORANGE_MONEY', 'WAVE'] as const),
    phoneNumber: vine.string().regex(/^\+[1-9]\d{1,14}$/),
    reference: vine.string().maxLength(64),
    metadata: vine.record(vine.any()).optional(),
  })
)

export type InitiateChargeInput = Infer<typeof initiateChargeValidator>
```

---

### 2.3 Contrôleur AdonisJS v6 Découplé
Le contrôleur valide le payload avec VineJS, délègue le traitement transactionnel au service métier et retourne une réponse structurée :

```typescript
// app/controllers/charges_controller.ts
import type { HttpContext } from '@adonisjs/core/http'
import { initiateChargeValidator } from '#validators/wallet_validator'
import { inject } from '@adonisjs/core'
import { WalletService } from '#services/wallet_service'

@inject()
export default class ChargesController {
  constructor(private walletService: WalletService) {}

  async store({ request, response, bouncer }: HttpContext) {
    const payload = await request.validateUsing(initiateChargeValidator)

    // Contrôle d'autorisation Bouncer
    const wallet = await this.walletService.findWallet(payload.walletId)
    await bouncer.authorize('chargeWallet', wallet)

    const transaction = await this.walletService.initiateCharge(payload)

    return response.status(201).json({
      success: true,
      data: transaction,
    })
  }
}
```

---

### 2.4 Lucid ORM & Transactions Déterministes
Les opérations critiques sous AdonisJS exploitent les transactions du gestionnaire de base de données Lucid avec gestion d'erreurs automatique :

```typescript
// app/services/wallet_service.ts
import db from '@adonisjs/lucid/services/db'
import Wallet from '#models/wallet'
import WalletTransaction from '#models/wallet_transaction'
import { InitiateChargeInput } from '#validators/wallet_validator'

export class WalletService {
  async debitWallet(walletId: string, amount: number, reference: string) {
    return await db.transaction(async (trx) => {
      // Verrouillage pessimiste de la ligne SQL
      const wallet = await Wallet.query({ client: trx })
        .where('id', walletId)
        .forUpdate()
        .firstOrFail()

      if (wallet.balance < amount) {
        throw new Error('SOLDE_INSUFFISANT')
      }

      wallet.balance -= amount
      wallet.useTransaction(trx)
      await wallet.save()

      const transaction = new WalletTransaction()
      transaction.walletId = wallet.id
      transaction.amount = -amount
      transaction.reference = reference
      transaction.status = 'COMPLETED'
      transaction.useTransaction(trx)
      await transaction.save()

      return transaction
    })
  }
}
```

---

## 3. FORMAT STANDARDISÉ DES RÉPONSES D'API

Tous les endpoints, qu'ils soient propulsés par Laravel ou AdonisJS v6, doivent adhérer sans concession à cette enveloppe JSON normalisée :

### 3.1 Réponse avec Succès (`200 OK`, `201 Created`)
```json
{
  "success": true,
  "data": {
    "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
    "type": "charges",
    "attributes": {
      "amount": 25000,
      "currency": "XAF",
      "status": "COMPLETED"
    }
  },
  "meta": {
    "correlation_id": "req-9883bca2-11ef",
    "timestamp": "2026-10-23T14:30:00Z"
  }
}
```

### 3.2 Réponse en Cas d'Erreur (`4xx`, `5xx`)
```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Le solde du portefeuille est insuffisant pour exécuter cette opération.",
    "details": {
      "required_amount": 25000,
      "current_balance": 12500,
      "currency": "XAF"
    }
  },
  "meta": {
    "correlation_id": "req-9883bca2-11ef",
    "timestamp": "2026-10-23T14:30:00Z"
  }
}
```
