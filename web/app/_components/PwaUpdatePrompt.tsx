'use client';

import { useEffect, useState } from 'react';

function canRegisterServiceWorker() {
  if (typeof window === 'undefined') return false;
  if (!('serviceWorker' in navigator)) return false;
  if (window.location.protocol === 'https:') return true;
  return window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
}

export function PwaUpdatePrompt() {
  const [registration, setRegistration] = useState<ServiceWorkerRegistration | null>(null);
  const [isUpdateReady, setIsUpdateReady] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    if (process.env.NODE_ENV !== 'production') return;
    if (!canRegisterServiceWorker()) return;

    let didRefresh = false;

    const showUpdate = (reg: ServiceWorkerRegistration) => {
      setRegistration(reg);
      setDismissed(false);
      setIsUpdateReady(Boolean(reg.waiting));
    };

    navigator.serviceWorker.addEventListener('controllerchange', () => {
      if (didRefresh) return;
      didRefresh = true;
      window.location.reload();
    });

    void navigator.serviceWorker.register('/sw.js').then((reg) => {
      if (reg.waiting) showUpdate(reg);

      reg.addEventListener('updatefound', () => {
        const installing = reg.installing;
        if (!installing) return;
        installing.addEventListener('statechange', () => {
          if (installing.state === 'installed' && navigator.serviceWorker.controller) showUpdate(reg);
        });
      });
    });
  }, []);

  if (!isUpdateReady || dismissed) return null;

  return (
    <div style={{ position: 'fixed', left: 12, right: 12, bottom: 12, zIndex: 9500 }}>
      <div
        className="card"
        role="status"
        style={{
          maxWidth: 680,
          margin: '0 auto',
          display: 'flex',
          alignItems: 'center',
          gap: 10,
          background: 'rgba(0, 0, 0, 0.82)',
          borderColor: 'rgba(255, 255, 255, 0.22)'
        }}
      >
        <span style={{ opacity: 0.95, flex: 1 }}>A new version is available.</span>
        <button
          type="button"
          onClick={() => registration?.waiting?.postMessage({ type: 'SKIP_WAITING' })}
          style={{ fontWeight: 700 }}
        >
          Refresh
        </button>
        <button type="button" aria-label="Dismiss update prompt" onClick={() => setDismissed(true)}>
          Dismiss
        </button>
      </div>
    </div>
  );
}
