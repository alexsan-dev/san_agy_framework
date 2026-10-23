<?php

declare(strict_types=1);

namespace App\Http\Controllers\Api\V1\Webhooks;

use App\Jobs\Payments\ProcessMoMoWebhookJob;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

/**
 * Contrôleur modèle de Webhook Mobile Money hautement sécurisé :
 * - Validation cryptographique HMAC-SHA256 en temps constant (anti-Timing Attack).
 * - Réponse HTTP 200 immédiate pour satisfaire le SLA des passerelles télécoms.
 * - Enfilement asynchrone non-bloquant dans Redis.
 */
final class MoMoWebhookController
{
    /**
     * Traite un callback webhook entrant d'un opérateur Mobile Money.
     *
     * @param Request $request
     * @return JsonResponse
     */
    public function handle(Request $request): JsonResponse
    {
        $signature = $request->header('X-Callback-Signature');
        $secret = (string) config('services.momo.webhook_secret');

        // 1. Contrôle de présence de la signature et du secret
        if (empty($signature) || empty($secret)) {
            Log::warning('Webhook Mobile Money rejeté : Signature absente ou configuration serveur incomplète.', [
                'ip' => $request->ip(),
                'user_agent' => $request->userAgent(),
            ]);

            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'UNAUTHORIZED_WEBHOOK',
                    'message' => 'En-tête de signature manquant ou non configuré.',
                ],
            ], Response::HTTP_FORBIDDEN);
        }

        // 2. Calcul du hash HMAC-SHA256 sur le payload brut
        $rawPayload = (string) $request->getContent();
        $expectedSignature = hash_hmac('sha256', $rawPayload, $secret);

        // 3. Comparaison en temps constant anti-Timing Attack
        if (!hash_equals($expectedSignature, (string) $signature)) {
            Log::error('Alerte Sécurité Webhook : Signature HMAC-SHA256 invalide.', [
                'ip' => $request->ip(),
                'received_signature' => $signature,
            ]);

            return response()->json([
                'success' => false,
                'error' => [
                    'code' => 'INVALID_SIGNATURE',
                    'message' => 'La signature cryptographique fournie ne correspond pas au payload.',
                ],
            ], Response::HTTP_FORBIDDEN);
        }

        /** @var array<string, mixed> $payload */
        $payload = $request->json()->all();

        // 4. Enfilement asynchrone non-bloquant dans Redis
        ProcessMoMoWebhookJob::dispatch($payload)
            ->onQueue('webhooks');

        Log::info('Webhook Mobile Money reçu et enfilé avec succès.', [
            'reference' => $payload['reference'] ?? 'NON_FOURNIE',
            'status' => $payload['status'] ?? 'INCONNU',
        ]);

        // 5. Réponse HTTP 200 immédiate (< 100 ms)
        return response()->json([
            'success' => true,
            'message' => 'Événement webhook enregistré avec succès pour traitement asynchrone.',
            'timestamp' => now()->toIso8601String(),
        ], Response::HTTP_OK);
    }
}
