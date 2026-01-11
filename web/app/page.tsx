export default function Home() {
  return (
    <main style={{ maxWidth: 900, padding: 24, margin: '0 auto' }}>
      <h1>Bar Sports Triathlon</h1>
      <p>
        This is the new rebuild of barsportstri.com. We’ll start static-first, then add historical data and realtime scoring.
      </p>
      <ul>
        <li><a href="/rules">Rules</a></li>
        <li><a href="/payouts">Payouts / Scoring</a></li>
        <li><a href="/past-results">Past Results</a></li>
      </ul>
    </main>
  );
}
