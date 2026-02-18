import type { Metadata } from 'next';
import Link from 'next/link';
import { Inter, Permanent_Marker } from 'next/font/google';

import './globals.css';
import { TopNav } from './_components/TopNav';

const bodyFont = Inter({ subsets: ['latin'], variable: '--font-body' });
const headingFont = Permanent_Marker({ subsets: ['latin'], weight: '400', variable: '--font-heading' });

export const metadata: Metadata = {
  title: 'Bar Sports Triathlon',
  description: 'Bowling, pool, darts (and beer).'
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${bodyFont.variable} ${headingFont.variable}`}>
        <TopNav />
        <div className="shell">
          <div className="frame">
            <main className="panel">{children}</main>
          </div>
          <div className="footer">
            © Bar Sports Triathlon{' '}
            <Link href="/admin/scoring" style={{ opacity: 0.6, fontSize: 12, textDecoration: 'none' }}>
              Manage your Tri
            </Link>
          </div>
        </div>
      </body>
    </html>
  );
}
