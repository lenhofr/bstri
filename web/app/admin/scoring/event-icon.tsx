'use client';

import { usePathname } from 'next/navigation';

import BowlingPinIcon from '../../_icons/bowling-pin.svg';
import BilliardsIcon from '../../_icons/billiards.svg';
import DartIcon from '../../_icons/dart.svg';
import PencilIcon from '../../_icons/pencil.svg';

export default function AdminScoringEventIcon() {
  const pathname = usePathname();

  if (pathname.includes('/admin/scoring/bowling')) return <BowlingPinIcon className="icon" aria-label="Bowling" />;
  if (pathname.includes('/admin/scoring/pool')) return <BilliardsIcon className="icon" aria-label="Pool" />;
  if (pathname.includes('/admin/scoring/darts')) return <DartIcon className="icon" aria-label="Darts" />;
  return <PencilIcon className="icon" aria-label="Setup" />;
}
