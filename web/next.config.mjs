import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const runtimeCaching = [
  {
    urlPattern: ({ request, url }) =>
      request.mode === 'navigate' && (url.pathname.startsWith('/scoring') || url.pathname.startsWith('/admin/scoring')),
    handler: 'NetworkFirst',
    method: 'GET',
    options: {
      cacheName: 'scoring-pages',
      networkTimeoutSeconds: 5,
      expiration: {
        maxEntries: 16,
        maxAgeSeconds: 2 * 60
      }
    }
  },
  {
    urlPattern: ({ request, url }) =>
      request.method === 'GET' &&
      request.destination === '' &&
      /\/scoring(?:\/|$)/.test(url.pathname) &&
      !url.pathname.startsWith('/admin/scoring'),
    handler: 'NetworkFirst',
    method: 'GET',
    options: {
      cacheName: 'scoring-api',
      networkTimeoutSeconds: 10,
      expiration: {
        maxEntries: 32,
        maxAgeSeconds: 2 * 60
      }
    }
  },
  {
    urlPattern: ({ request, url }) =>
      request.mode === 'navigate' && !url.pathname.startsWith('/scoring') && !url.pathname.startsWith('/admin/scoring'),
    handler: 'StaleWhileRevalidate',
    method: 'GET',
    options: {
      cacheName: 'content-pages',
      expiration: {
        maxEntries: 48,
        maxAgeSeconds: 24 * 60 * 60
      }
    }
  },
  {
    urlPattern: ({ request, url }) =>
      request.method === 'GET' &&
      (url.pathname.startsWith('/_next/static/') ||
        (url.origin === self.origin &&
          /\.(?:js|css|woff2?|ttf|eot|otf|png|jpg|jpeg|gif|svg|ico|webp)$/i.test(url.pathname))),
    handler: 'CacheFirst',
    method: 'GET',
    options: {
      cacheName: 'static-assets',
      cacheableResponse: {
        statuses: [0, 200]
      },
      expiration: {
        maxEntries: 128,
        maxAgeSeconds: 30 * 24 * 60 * 60
      }
    }
  },
  {
    urlPattern: /^https:\/\/fonts\.(?:gstatic)\.com\/.*/i,
    handler: 'CacheFirst',
    method: 'GET',
    options: {
      cacheName: 'google-fonts-webfonts',
      expiration: {
        maxEntries: 8,
        maxAgeSeconds: 365 * 24 * 60 * 60
      }
    }
  },
  {
    urlPattern: /^https:\/\/fonts\.(?:googleapis)\.com\/.*/i,
    handler: 'StaleWhileRevalidate',
    method: 'GET',
    options: {
      cacheName: 'google-fonts-stylesheets',
      expiration: {
        maxEntries: 8,
        maxAgeSeconds: 7 * 24 * 60 * 60
      }
    }
  }
];

const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development',
  register: false,
  skipWaiting: true,
  buildExcludes: [/app-build-manifest\.json$/],
  runtimeCaching,
  fallbacks: {
    document: '/offline'
  }
});

/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: { unoptimized: true },
};

// Apply withPWA first, then layer SVGR on top — next-pwa v5 swallows webpack
// functions defined in nextConfig, so we patch the resulting config instead.
const pwaConfig = withPWA(nextConfig);
const pwaWebpack = pwaConfig.webpack;
pwaConfig.webpack = (config, options) => {
  const result = pwaWebpack ? pwaWebpack(config, options) : config;

  // Exclude .svg from Next.js's default file-loader rule
  const fileLoaderRule = result.module.rules.find(rule =>
    rule.test?.test?.('.svg')
  );
  if (fileLoaderRule) {
    fileLoaderRule.exclude = /\.svg$/i;
  }

  // Handle .svg imports as React components via SVGR.
  // type: 'javascript/auto' overrides Next.js's asset/resource rule for SVGs.
  result.module.rules.push({
    test: /\.svg$/i,
    type: 'javascript/auto',
    use: ['@svgr/webpack'],
  });

  return result;
};

export default pwaConfig;
