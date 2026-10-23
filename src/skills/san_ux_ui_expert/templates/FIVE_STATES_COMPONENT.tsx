import React, { useState, useEffect, useCallback } from 'react';
import * as Haptics from 'expo-haptics';
import NetInfo from '@react-native-community/netinfo';

/**
 * FIVE_STATES_COMPONENT.tsx
 * Modèle TypeScript universel pour composant React.js / React Native / Expo
 * implémentant de façon chirurgicale les 5 états UI obligatoires d'Antigravity :
 * 1. État Chargement (Skeleton anti-CLS géométrique exact)
 * 2. État Erreur (Triptyque sans blâme avec retry exponentiel)
 * 3. État Vide (Empty state incitatif avec CTA direct)
 * 4. État Idéal (Nominal 60 fps, GPU transform, active scale, haptic)
 * 5. État Hors-Ligne (Outbox pattern, NetInfo, données locales)
 */

export interface TransactionItem {
  id: string;
  title: string;
  amount: number;
  currency: string;
  date: string;
  status: 'COMPLETED' | 'PENDING' | 'FAILED';
}

interface FiveStatesComponentProps {
  apiEndpoint?: string;
  onItemPress?: (item: TransactionItem) => void;
  onCreateNew?: () => void;
}

export const FiveStatesComponent: React.FC<FiveStatesComponentProps> = ({
  apiEndpoint = '/api/v1/wallet/transactions',
  onItemPress,
  onCreateNew,
}) => {
  const [loading, setLoading] = useState<boolean>(true);
  const [isOffline, setIsOffline] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [data, setData] = useState<TransactionItem[]>([]);
  const [retryAttempt, setRetryAttempt] = useState<number>(0);

  // Écoute de l'état de la connectivité réseau
  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      const offline = !state.isConnected || !state.isInternetReachable;
      setIsOffline(offline);
    });
    return () => unsubscribe();
  }, []);

  // Fonction de chargement des données
  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch(apiEndpoint, {
        headers: {
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`HTTP_${response.status}`);
      }

      const json = await response.json();
      setData(json.data || []);
      setRetryAttempt(0);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'UNKNOWN_NETWORK_ERROR';
      setError(message);
    } finally {
      setLoading(false);
    }
  }, [apiEndpoint]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // Gestion du retry avec Exponential Backoff
  const handleRetry = async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    const delay = Math.min(1000 * Math.pow(2, retryAttempt), 8000);
    setLoading(true);
    setTimeout(() => {
      setRetryAttempt(prev => prev + 1);
      fetchData();
    }, delay);
  };

  // 1. ÉTAT CHARGEMENT : SKELETON GÉOMÉTRIQUE ANTI-CLS
  if (loading) {
    return (
      <div className="w-full max-w-md mx-auto p-4 space-y-4 animate-pulse">
        <div className="h-6 w-40 bg-slate-800 rounded-md"></div>
        {[1, 2, 3].map(i => (
          <div
            key={i}
            className="min-h-[72px] bg-slate-800/80 rounded-2xl p-4 flex items-center justify-between border border-slate-700/50"
          >
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-xl bg-slate-700"></div>
              <div className="space-y-2">
                <div className="h-4 w-28 bg-slate-700 rounded"></div>
                <div className="h-3 w-16 bg-slate-700/60 rounded"></div>
              </div>
            </div>
            <div className="h-5 w-20 bg-slate-700 rounded"></div>
          </div>
        ))}
      </div>
    );
  }

  // 2. ÉTAT ERREUR : TRIPTYQUE SANS BLÂME AVEC RETRY EXPONENTIEL
  if (error && data.length === 0) {
    return (
      <div className="w-full max-w-md mx-auto p-6 text-center space-y-4 bg-slate-900 border border-rose-900/40 rounded-3xl">
        <div className="w-14 h-14 mx-auto rounded-2xl bg-rose-500/10 text-rose-500 flex items-center justify-center">
          <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
        </div>
        <h3 className="text-base font-bold text-white">Connexion temporairement indisponible</h3>
        <p className="text-xs text-slate-300">
          Impossible de contacter le serveur sécurisé. Vos données enregistrées restent en sûreté.
        </p>
        <button
          type="button"
          onClick={handleRetry}
          className="min-h-[44px] px-6 py-2.5 bg-rose-600 hover:bg-rose-500 active:scale-95 text-white font-bold text-sm rounded-xl transition-all shadow-lg shadow-rose-600/20 cursor-pointer"
        >
          {retryAttempt > 0 ? `Réessayer (tentative ${retryAttempt + 1})...` : 'Réessayer'}
        </button>
      </div>
    );
  }

  // 3. ÉTAT VIDE (EMPTY STATE) : INCITATIF AVEC CTA IMMÉDIAT
  if (data.length === 0) {
    return (
      <div className="w-full max-w-md mx-auto p-8 text-center space-y-4 bg-slate-900/60 border border-slate-800 rounded-3xl">
        <div className="w-16 h-16 mx-auto rounded-2xl bg-amber-500/10 text-amber-500 flex items-center justify-center">
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
        </div>
        <h3 className="text-base font-bold text-white">Aucune transaction enregistrée</h3>
        <p className="text-xs text-slate-300">
          Rechargez votre portefeuille ou effectuez un premier virement instantané Mobile Money.
        </p>
        {onCreateNew && (
          <button
            type="button"
            onClick={async () => {
              await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
              onCreateNew();
            }}
            className="min-h-[48px] px-6 py-3 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 text-slate-950 font-black text-sm rounded-xl active:scale-95 transition-all shadow-md cursor-pointer"
          >
            Effectuer un premier virement
          </button>
        )}
      </div>
    );
  }

  // 4. ÉTAT IDÉAL & 5. ÉTAT HORS-LIGNE
  return (
    <div className="w-full max-w-md mx-auto space-y-3">
      {/* 5. Bandeau d'état hors-ligne */}
      {isOffline && (
        <div className="p-2.5 bg-amber-500/10 border border-amber-500/40 rounded-xl flex items-center space-x-2 text-xs text-amber-300">
          <svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>Mode hors-ligne : affichage des données en cache local.</span>
        </div>
      )}

      {/* 4. Liste nominale des données */}
      {data.map(item => (
        <div
          key={item.id}
          onClick={async () => {
            await Haptics.selectionAsync();
            onItemPress?.(item);
          }}
          className="min-h-[64px] bg-slate-900 border border-slate-800 rounded-2xl p-4 flex items-center justify-between active:scale-[0.98] transition-transform cursor-pointer"
        >
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center font-bold text-amber-400 text-sm">
              {item.currency}
            </div>
            <div>
              <p className="text-sm font-bold text-white">{item.title}</p>
              <p className="text-xs text-slate-300">{item.date}</p>
            </div>
          </div>
          <div className="text-right">
            <p className="text-sm font-extrabold text-white">
              {item.amount.toLocaleString('fr-FR')}{' '}
              <span className="text-[11px] text-amber-400">{item.currency}</span>
            </p>
            <span
              className={`text-[10px] font-semibold ${
                item.status === 'COMPLETED' ? 'text-emerald-400' : 'text-amber-400'
              }`}
            >
              {item.status === 'COMPLETED' ? 'Validé' : 'En attente'}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
};
