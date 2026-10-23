<?php

declare(strict_types=1);

namespace App\Actions\Wallet;

use App\DTOs\Wallet\InitiateChargeDTO;
use App\Exceptions\InsufficientFundsException;
use App\Exceptions\WalletLockException;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

/**
 * Action unitaire conforme SOLID / SRP : Initiation d'une charge Mobile Money sous triple verrou.
 */
final class InitiateMoMoChargeAction
{
    /**
     * Durée maximale de rétention du verrou distribué Redis en secondes.
     */
    private const LOCK_TTL_SECONDS = 10;

    /**
     * Délai maximal d'attente pour acquérir le verrou en secondes.
     */
    private const LOCK_WAIT_SECONDS = 5;

    /**
     * Exécute l'action de débit / charge de manière atomique et résiliente.
     *
     * @param InitiateChargeDTO $dto Objet de transfert de données typé et immuable
     * @return WalletTransaction
     *
     * @throws InsufficientFundsException Si le solde disponible est inférieur au montant
     * @throws WalletLockException En cas d'impossibilité d'acquérir le verrou distribué
     */
    public function execute(InitiateChargeDTO $dto): WalletTransaction
    {
        $lockKey = "lock:wallet:{$dto->walletId}";
        $lock = Cache::lock($lockKey, self::LOCK_TTL_SECONDS);

        // Strate 1 : Verrou distribué Redis
        $result = $lock->block(self::LOCK_WAIT_SECONDS, function () use ($dto): WalletTransaction {
            // Strate 2 : Transaction SQL ACID avec Verrouillage Pessimiste
            return DB::transaction(function () use ($dto): WalletTransaction {
                /** @var Wallet|null $wallet */
                $wallet = Wallet::query()
                    ->where('id', $dto->walletId)
                    ->lockForUpdate()
                    ->first();

                if (!$wallet) {
                    throw new \DomainException("Le portefeuille [{$dto->walletId}] est introuvable.");
                }

                // Strate 3 : Contrôle mathématique strict du solde
                if ($wallet->balance < $dto->amountInCents) {
                    throw new InsufficientFundsException(
                        "Solde insuffisant : requis={$dto->amountInCents}, disponible={$wallet->balance} {$wallet->currency}."
                    );
                }

                // Décrémentation atomique
                $wallet->decrement('balance', $dto->amountInCents);

                // Enregistrement de l'écriture comptable immuable
                $transaction = WalletTransaction::create([
                    'wallet_id' => $wallet->id,
                    'reference' => $dto->reference,
                    'amount' => -$dto->amountInCents,
                    'balance_after' => $wallet->balance,
                    'currency' => $dto->currency,
                    'provider' => $dto->provider,
                    'phone_number' => $dto->phoneNumber,
                    'type' => 'DEBIT',
                    'status' => 'PENDING',
                    'metadata' => $dto->metadata,
                ]);

                Log::info('Transaction de débit initiée avec succès.', [
                    'transaction_id' => $transaction->id,
                    'wallet_id' => $wallet->id,
                    'amount' => $dto->amountInCents,
                    'reference' => $dto->reference,
                ]);

                return $transaction;
            });
        });

        if ($result instanceof WalletTransaction) {
            return $result;
        }

        throw new WalletLockException("Impossible d'acquérir le verrou sur le portefeuille [{$dto->walletId}].");
    }
}
