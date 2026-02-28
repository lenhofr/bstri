import test from 'node:test';
import assert from 'node:assert/strict';

import { computeBowlingOwed } from '../lib/scoring-rules';

test('computeBowlingOwed: returns null for all when no scores', () => {
  const result = computeBowlingOwed({ josh: { raw: null }, joe: { raw: null } });
  assert.deepEqual(result, { josh: null, joe: null });
});

test('computeBowlingOwed: returns null for highest scorer, computes owed for others', () => {
  // josh: 250 (highest), joe: 100 → (250-100)*5 = 750 pennies = $7.50
  const result = computeBowlingOwed({ josh: { raw: 250 }, joe: { raw: 100 } });
  assert.equal(result.josh, null);
  assert.equal(result.joe, 750);
});

test('computeBowlingOwed: multiple players', () => {
  const result = computeBowlingOwed({
    a: { raw: 200 },
    b: { raw: 150 },
    c: { raw: 100 }
  });
  // a is highest → null
  assert.equal(result.a, null);
  // b: (200-150)*5 = 250
  assert.equal(result.b, 250);
  // c: (200-100)*5 = 500
  assert.equal(result.c, 500);
});

test('computeBowlingOwed: ties for highest both get null', () => {
  const result = computeBowlingOwed({
    a: { raw: 200 },
    b: { raw: 200 },
    c: { raw: 150 }
  });
  assert.equal(result.a, null);
  assert.equal(result.b, null);
  // c: (200-150)*5 = 250
  assert.equal(result.c, 250);
});

test('computeBowlingOwed: player with no score gets null', () => {
  const result = computeBowlingOwed({ a: { raw: 200 }, b: { raw: null } });
  assert.equal(result.a, null);
  assert.equal(result.b, null);
});

test('computeBowlingOwed: single player gets null (no one to compare against)', () => {
  const result = computeBowlingOwed({ a: { raw: 150 } });
  assert.equal(result.a, null);
});
