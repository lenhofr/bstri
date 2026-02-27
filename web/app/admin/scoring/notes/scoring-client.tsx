'use client';

import { useScoring } from '../scoring-context';

export default function NotesScoringClient() {
  const { doc, setCommentary } = useScoring();

  return (
    <div>
      <h2>Notes</h2>
      <p className="kicker" style={{ marginTop: 6 }}>
        Notable moments from the event — shown at the bottom of the public scoring page.
      </p>
      <textarea
        value={doc.commentary ?? ''}
        onChange={(e) => setCommentary(e.target.value)}
        placeholder="e.g. Rob bowled a 300 in Game 2. Jake sank the 8 ball on the break."
        rows={8}
        style={{ width: '100%', resize: 'vertical' }}
      />
    </div>
  );
}
