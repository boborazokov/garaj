import fs from 'node:fs';
const p = new URL('../reports/backend-graphql-probes.json', import.meta.url);
const j = JSON.parse(fs.readFileSync(p, 'utf8'));
const walk = (v) => {
  if (Array.isArray(v)) return v.map(walk);
  if (v && typeof v === 'object') {
    const o = {};
    for (const [k, val] of Object.entries(v)) {
      o[k] = k === 'correctCode' ? '[REDACTED_OTP]' : walk(val);
    }
    return o;
  }
  return v;
};
fs.writeFileSync(p, JSON.stringify(walk(j), null, 2));
console.log('OTP redacted');
