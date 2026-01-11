import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Bar Sports Triathlon',
  description: 'Bowling, pool, darts (and beer).'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body style={{ margin: 0, fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif' }}>
        {children}
      </body>
    </html>
  );
}
