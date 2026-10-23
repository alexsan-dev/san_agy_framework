import { useState, useCallback } from 'react';
import NetInfo from '@react-native-community/netinfo';
import * as Haptics from 'expo-haptics';

/**
 * USE_OFFLINE_MUTATION.ts
 * Hook de mutation avec mise à jour optimiste (Optimistic UI) et file d'attente Outbox
 * pour React.js, React Native et Expo Router.
 */

export interface MutationRequest<T> {
  endpoint: string;
  method: 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  payload: T;
  optimisticCallback: (payload: T) => void;
  rollbackCallback: () => void;
}

export interface UseOfflineMutationResult {
  executeMutation: <T>(request: MutationRequest<T>) => Promise<boolean>;
  isSubmitting: boolean;
  isOffline: boolean;
  lastError: string | null;
}

export function useOfflineMutation(): UseOfflineMutationResult {
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [isOffline, setIsOffline] = useState<boolean>(false);
  const [lastError, setLastError] = useState<string | null>(null);

  const executeMutation = useCallback(async <T>(request: MutationRequest<T>): Promise<boolean> => {
    setIsSubmitting(true);
    setLastError(null);

    // 1. Retour tactile immédiat
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    // 2. Application optimiste immédiate dans l'UI
    request.optimisticCallback(request.payload);

    // 3. Contrôle de la connectivité réseau
    const netState = await NetInfo.fetch();
    const online = Boolean(netState.isConnected && netState.isInternetReachable);
    setIsOffline(!online);

    if (!online) {
      // 4a. Sauvegarde locale dans l'Outbox (SQLite / MMKV)
      await queueMutationInOutbox(request);
      setIsSubmitting(false);
      return true;
    }

    // 4b. Envoi réseau nominal
    try {
      const response = await fetch(request.endpoint, {
        method: request.method,
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': crypto.randomUUID(),
        },
        body: JSON.stringify(request.payload),
      });

      if (!response.ok) {
        throw new Error(`HTTP_${response.status}`);
      }

      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      return true;
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'NETWORK_MUTATION_FAILED';
      console.warn('[useOfflineMutation] Bascule en file Outbox suite à erreur réseau :', msg);
      setLastError(msg);
      
      // Enregistrement dans l'Outbox pour retentative ultérieure
      await queueMutationInOutbox(request);
      return false;
    } finally {
      setIsSubmitting(false);
    }
  }, []);

  return { executeMutation, isSubmitting, isOffline, lastError };
}

async function queueMutationInOutbox<T>(request: MutationRequest<T>): Promise<void> {
  // Ici s'insère la sérialisation dans la table SQLite 'outbox_mutations'
  const record = {
    id: crypto.randomUUID(),
    endpoint: request.endpoint,
    method: request.method,
    payload: JSON.stringify(request.payload),
    createdAt: Date.now(),
    status: 'PENDING',
  };
  console.log('[Outbox] Mutation enregistrée localement :', record.id, record.endpoint);
}
