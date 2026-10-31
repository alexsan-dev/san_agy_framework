import React, { useState, useEffect, useCallback, useMemo } from 'react';

/**
 * FIVE_STATES_COMPONENT.tsx
 * Composant TypeScript / React de référence Antigravity (san_ux_ui_expert).
 * Architecture non-destructive Stale-While-Revalidate (SWR) avec accessibilité WCAG AAA.
 *
 * LES 5 ÉTATS UI CANONIQUES GÉRÉS :
 * 1. IDLE / LOADING INITIAL : Skeleton géométrique exact anti-CLS (uniquement si 0 donnée en mémoire).
 * 2. SUCCESS / IDÉAL        : Liste nominale haute densité, boutons natifs <button>, GPU transform.
 * 3. EMPTY STATE            : État vide incitatif avec CTA direct d'amorce immédiate.
 * 4. ERROR (ACTIONNABLE)    : Triptyque sans blâme + Exponential Backoff. Non-destructif si cache présent.
 * 5. REVALIDATING (SWR)     : Données conservées sans scintillement avec micro-indicateur discret.
 *    + ÉTAT HORS-LIGNE      : Détection réseau native (Navigator / NetInfo) et bandeau informatif rassurant.
 */

export interface TransactionItem {
  id: string;
  title: string;
  amount: number;
  currency: string;
  date: string;
  counterparty: string;
  status: 'COMPLETED' | 'PENDING' | 'FAILED';
}

export type UIState = 'idle' | 'loading' | 'success' | 'empty' | 'error' | 'revalidating';

interface FiveStatesComponentProps {
  apiEndpoint?: string;
  initialItems?: TransactionItem[];
  onItemPress?: (item: TransactionItem) => void;
  onCreateNew?: () => void;
}

// Helper haptique universel tolérant Web & Mobile (navigator.vibrate fallback)
const triggerHaptic = (durationMs = 15) => {
  if (typeof window !== 'undefined' && typeof navigator !== 'undefined' && 'vibrate' in navigator) {
    try {
      navigator.vibrate(durationMs);
    } catch {
      // Ignorer silencieusement si permissions restreintes
    }
  }
};

export const FiveStatesComponent: React.FC<FiveStatesComponentProps> = ({
  apiEndpoint = '/api/v1/wallet/transactions',
  initialItems = [],
  onItemPress,
  onCreateNew,
}) => {
  const [data, setData] = useState<TransactionItem[]>(initialItems);
  const [initialLoading, setInitialLoading] = useState<boolean>(initialItems.length === 0);
  const [isRevalidating, setIsRevalidating] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [isOffline, setIsOffline] = useState<boolean>(false);
  const [retryAttempt, setRetryAttempt] = useState<number>(0);
  const [lastSyncedAt, setLastSyncedAt] = useState<string | null>(null);

  // 1. Détection de connectivité universelle (Web Navigator Online + events)
  useEffect(() => {
    if (typeof window === 'undefined') return;

    const handleOnline = () => setIsOffline(false);
    const handleOffline = () => setIsOffline(true);

    setIsOffline(!navigator.onLine);
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  // 2. Récupération des données selon le pattern Stale-While-Revalidate
  const fetchData = useCallback(
    async (isBackgroundRevalidation = false) => {
      if (isBackgroundRevalidation) {
        setIsRevalidating(true);
      } else if (data.length === 0) {
        setInitialLoading(true);
      } else {
        setIsRevalidating(true);
      }
      setError(null);

      try {
        const response = await fetch(apiEndpoint, {
          headers: {
            Accept: 'application/json',
          },
        });

        if (!response.ok) {
          throw new Error(`HTTP_${response.status}`);
        }

        const json = await response.json();
        const incomingData: TransactionItem[] = json.data || [];
        setData(incomingData);
        setRetryAttempt(0);
        setLastSyncedAt(new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit', second: '2-digit' }));
      } catch (err: unknown) {
        const message = err instanceof Error ? err.message : 'ERR_NETWORK_UNREACHABLE';
        setError(message);
      } finally {
        setInitialLoading(false);
        setIsRevalidating(false);
      }
    },
    [apiEndpoint, data.length]
  );

  useEffect(() => {
    fetchData(data.length > 0);
  }, []);

  // 3. Retry exponentiel résilient
  const handleRetry = async () => {
    triggerHaptic(25);
    const delay = Math.min(1000 * Math.pow(2, retryAttempt), 8000);
    setRetryAttempt(prev => prev + 1);
    setTimeout(() => {
      fetchData(data.length > 0);
    }, delay);
  };

  // 4. Calcul de l'état UI effectif
  const currentState: UIState = useMemo(() => {
    if (initialLoading && data.length === 0) return 'loading';
    if (error && data.length === 0) return 'error';
    if (!initialLoading && data.length === 0) return 'empty';
    if (isRevalidating) return 'revalidating';
    return 'success';
  }, [initialLoading, data.length, error, isRevalidating]);

  // ============================================================================
  // RENDU 1 : ÉTAT CHARGEMENT INITIAL (SKELETON EXACT ANTI-CLS)
  // UNIQUEMENT affiché lors du tout premier fetch à froid (0 donnée en cache).
  // ============================================================================
  if (currentState === 'loading') {
    return (
      <section
        aria-busy="true"
        aria-live="polite"
        className="w-full max-w-lg mx-auto p-4 space-y-4 animate-pulse select-none"
      >
        <div className="flex items-center justify-between">
          <div className="h-6 w-36 bg-slate-800 rounded-md"></div>
          <div className="h-4 w-20 bg-slate-800 rounded-md"></div>
        </div>
        {[1, 2, 3, 4].map(idx => (
          <div
            key={idx}
            className="min-h-[72px] bg-slate-900/60 rounded-2xl p-4 flex items-center justify-between border border-slate-800"
          >
            <div className="flex items-center space-x-3">
              <div className="w-11 h-11 rounded-xl bg-slate-800"></div>
              <div className="space-y-2">
                <div className="h-4 w-32 bg-slate-800 rounded"></div>
                <div className="h-3 w-20 bg-slate-800/60 rounded"></div>
              </div>
            </div>
            <div className="space-y-2 text-right">
              <div className="h-4 w-24 bg-slate-800 rounded ml-auto"></div>
              <div className="h-3 w-16 bg-slate-800/60 rounded ml-auto"></div>
            </div>
          </div>
        ))}
      </section>
    );
  }

  // ============================================================================
  // RENDU 2 : ÉTAT ERREUR CRITIQUE À FROID (ZÉRO DONNÉE EN MÉMOIRE)
  // Triptyque sans blâme avec retry exponentiel accessible au clavier.
  // ============================================================================
  if (currentState === 'error') {
    return (
      <section
        role="alert"
        aria-live="assertive"
        className="w-full max-w-lg mx-auto p-6 text-center space-y-4 bg-slate-900 border border-rose-900/40 rounded-3xl"
      >
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
        <div className="space-y-1">
          <h2 className="text-base font-bold text-white tracking-tight">Connexion temporairement indisponible</h2>
          <p className="text-xs text-slate-300 max-w-sm mx-auto leading-relaxed">
            Impossible de contacter le serveur sécurisé. Vos soldes et données enregistrées restent en sûreté.
          </p>
        </div>
        <button
          type="button"
          onClick={handleRetry}
          className="min-h-[44px] min-w-[44px] px-6 py-2.5 bg-rose-600 hover:bg-rose-500 active:scale-95 text-white font-bold text-sm rounded-xl transition-all shadow-lg shadow-rose-600/20 cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rose-400 focus-visible:ring-offset-2 focus-visible:ring-offset-slate-950"
        >
          {retryAttempt > 0 ? `Réessayer (tentative ${retryAttempt + 1})...` : 'Réessayer maintenant'}
        </button>
      </section>
    );
  }

  // ============================================================================
  // RENDU 3 : ÉTAT VIDE (EMPTY STATE INCITATIF)
  // Message empathique orienté action avec bouton CTA direct d'amorce.
  // ============================================================================
  if (currentState === 'empty') {
    return (
      <section
        aria-live="polite"
        className="w-full max-w-lg mx-auto p-8 text-center space-y-4 bg-slate-900/60 border border-slate-800 rounded-3xl"
      >
        <div className="w-16 h-16 mx-auto rounded-2xl bg-blue-500/10 text-blue-400 flex items-center justify-center">
          <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9a2 2 0 00-2 2v6a2 2 0 002 2zm7-5a2 2 0 11-4 0 2 2 0 014 0z"
            />
          </svg>
        </div>
        <div className="space-y-1">
          <h2 className="text-base font-bold text-white tracking-tight">Aucune transaction enregistrée</h2>
          <p className="text-xs text-slate-300 max-w-sm mx-auto leading-relaxed">
            Rechargez votre portefeuille ou effectuez un premier virement instantané Mobile Money.
          </p>
        </div>
        {onCreateNew && (
          <button
            type="button"
            onClick={() => {
              triggerHaptic(20);
              onCreateNew();
            }}
            className="min-h-[48px] px-6 py-3 bg-blue-600 hover:bg-blue-500 active:scale-95 text-white font-bold text-sm rounded-xl transition-all shadow-md cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 focus-visible:ring-offset-2 focus-visible:ring-offset-slate-950"
          >
            Effectuer un premier virement
          </button>
        )}
      </section>
    );
  }

  // ============================================================================
  // RENDU 4 & 5 : ÉTAT NOMINAL, STALE-WHILE-REVALIDATE NON-DESTRUCTIF & HORS-LIGNE
  // En cas de rafraîchissement ou d'erreur réseau transitoire, les données
  // précédentes RESTENT TOUJOURS AFFICHÉES pour préserver le confort de lecture.
  // ============================================================================
  return (
    <section className="w-full max-w-lg mx-auto space-y-3" aria-live="polite">
      {/* Micro-indicateur discret de revalidation en arrière-plan (Pattern SWR non-destructif) */}
      {isRevalidating && (
        <div
          role="status"
          aria-live="polite"
          className="px-3 py-1.5 bg-blue-500/10 border border-blue-500/30 rounded-xl flex items-center justify-between text-xs text-blue-300 transition-opacity animate-in fade-in"
        >
          <div className="flex items-center space-x-2">
            <svg className="w-3.5 h-3.5 animate-spin" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
            </svg>
            <span className="font-medium">Actualisation des soldes...</span>
          </div>
          {lastSyncedAt && <span className="text-[10px] tabular-nums text-blue-400/80">Dernière synchro : {lastSyncedAt}</span>}
        </div>
      )}

      {/* Erreur transitoire non-destructive : alerte discrète au-dessus des données en cache */}
      {error && (
        <div
          role="alert"
          className="p-3 bg-rose-500/10 border border-rose-500/30 rounded-xl flex items-center justify-between text-xs text-rose-300"
        >
          <div className="flex items-center space-x-2">
            <svg className="w-4 h-4 flex-shrink-0 text-rose-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Échec du rafraîchissement (données en cache)</span>
          </div>
          <button
            type="button"
            onClick={handleRetry}
            className="px-2.5 py-1 bg-rose-600/30 hover:bg-rose-600/50 text-rose-200 font-semibold rounded-lg text-[11px] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-rose-400"
          >
            Réessayer
          </button>
        </div>
      )}

      {/* Bandeau d'état hors-ligne non-destructif */}
      {isOffline && (
        <div
          role="status"
          className="p-2.5 bg-amber-500/10 border border-amber-500/40 rounded-xl flex items-center justify-between text-xs text-amber-300"
        >
          <div className="flex items-center space-x-2">
            <svg className="w-4 h-4 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Mode hors-ligne : consultation du cache local.</span>
          </div>
          {lastSyncedAt && <span className="text-[10px] tabular-nums text-amber-400/80">Synchronisé à {lastSyncedAt}</span>}
        </div>
      )}

      {/* En-tête de liste avec bouton d'actualisation manuelle accessible */}
      <div className="flex items-center justify-between px-1 pt-1 pb-0.5">
        <h2 className="text-xs font-bold uppercase tracking-wider text-slate-300">
          Dernières Transactions ({data.length})
        </h2>
        <button
          type="button"
          onClick={() => fetchData(true)}
          disabled={isRevalidating}
          aria-label="Actualiser les transactions"
          className="min-h-[44px] min-w-[44px] inline-flex items-center justify-center text-xs text-blue-400 hover:text-blue-300 active:scale-95 transition-transform disabled:opacity-50 cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-400 rounded-lg"
        >
          <svg className={`w-4 h-4 ${isRevalidating ? 'animate-spin' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
        </button>
      </div>

      {/* Liste nominale des items interactifs (boutons accessibles natifs) */}
      <ul className="space-y-2 list-none p-0 m-0" role="list">
        {data.map(item => (
          <li key={item.id}>
            <button
              type="button"
              onClick={() => {
                triggerHaptic(15);
                onItemPress?.(item);
              }}
              className="w-full text-left min-h-[64px] bg-slate-900 hover:bg-slate-800/80 active:scale-[0.99] border border-slate-800 hover:border-slate-700 rounded-2xl p-4 flex items-center justify-between transition-all cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2 focus-visible:ring-offset-slate-950"
            >
              <div className="flex items-center space-x-3.5">
                <div className="w-10 h-10 rounded-xl bg-slate-800 border border-slate-700/60 flex items-center justify-center font-bold text-blue-400 text-xs tabular-nums">
                  {item.currency}
                </div>
                <div>
                  <p className="text-sm font-bold text-white tracking-tight">{item.title}</p>
                  <p className="text-xs text-slate-300 tabular-nums">
                    {item.date} • {item.counterparty}
                  </p>
                </div>
              </div>

              <div className="text-right">
                <p className="text-sm font-extrabold text-white tabular-nums">
                  {item.amount.toLocaleString('fr-FR', { minimumFractionDigits: 0 })}{' '}
                  <span className="text-[11px] font-semibold text-blue-400">{item.currency}</span>
                </p>
                <span
                  className={`inline-block text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-full ${
                    item.status === 'COMPLETED'
                      ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30'
                      : item.status === 'FAILED'
                      ? 'bg-rose-500/10 text-rose-400 border border-rose-500/30'
                      : 'bg-amber-500/10 text-amber-400 border border-amber-500/30'
                  }`}
                >
                  {item.status === 'COMPLETED' ? 'Validé' : item.status === 'FAILED' ? 'Échoué' : 'En cours'}
                </span>
              </div>
            </button>
          </li>
        ))}
      </ul>
    </section>
  );
};

export default FiveStatesComponent;
