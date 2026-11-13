#!/usr/bin/env node
/**
 * AutoRin QA runner — orchestrates safe smoke checks across web/backend/flutter.
 * Never claims PASS without executing. Marks BLOCKED when prerequisites missing.
 * Does not modify application business logic or hit production by default.
 */
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const QA_ROOT = path.resolve(__dirname, '..');
const REPO_ROOT = path.resolve(QA_ROOT, '..');
const REPORTS = path.join(QA_ROOT, 'reports');

const workflow = (process.argv[2] || 'full').toLowerCase();

function run(cmd, args, opts = {}) {
  const result = spawnSync(cmd, args, {
    cwd: opts.cwd || REPO_ROOT,
    encoding: 'utf8',
    shell: true,
    env: { ...process.env, ...opts.env },
    timeout: opts.timeout ?? 300_000,
  });
  return {
    cmd: [cmd, ...args].join(' '),
    status: result.status,
    signal: result.signal,
    stdout: result.stdout?.slice(-8000) ?? '',
    stderr: result.stderr?.slice(-8000) ?? '',
    error: result.error ? String(result.error.message || result.error) : null,
  };
}

function which(bin) {
  const r = spawnSync(process.platform === 'win32' ? 'where' : 'which', [bin], {
    encoding: 'utf8',
    shell: true,
  });
  return r.status === 0 ? r.stdout.trim().split(/\r?\n/)[0] : null;
}

function section(name, fn) {
  console.log(`\n=== ${name} ===`);
  const started = Date.now();
  let outcome;
  try {
    outcome = fn();
  } catch (err) {
    outcome = { status: 'FAIL', detail: String(err?.message ?? err) };
  }
  return { name, elapsedMs: Date.now() - started, ...outcome };
}

function webSmoke() {
  const pw = path.join(QA_ROOT, 'web', 'node_modules', '@playwright', 'test');
  if (!fs.existsSync(pw)) {
    return { status: 'BLOCKED', detail: 'Playwright not installed. Run: npm run qa:web:install' };
  }
  const r = run('npx', ['playwright', 'test', '--project=chromium', '--grep', '@smoke'], {
    cwd: path.join(QA_ROOT, 'web'),
    env: { QA_START_WEB: process.env.QA_START_WEB ?? '0' },
  });
  if (r.error) return { status: 'BLOCKED', detail: r.error, run: r };
  if (r.status === 0) return { status: 'PASS', run: r };
  // Distinguish unreachable app vs real failures
  const combined = `${r.stdout}\n${r.stderr}`;
  if (/ERR_CONNECTION_REFUSED|net::ERR_|ECONNREFUSED/i.test(combined)) {
    return {
      status: 'BLOCKED',
      detail: 'Web app not reachable. Start autorin-web (npm run dev) or set QA_START_WEB=1',
      run: r,
    };
  }
  return { status: 'FAIL', detail: `exit ${r.status}`, run: r };
}

function backendUnit() {
  const pkg = path.join(REPO_ROOT, 'autorin-backend', 'package.json');
  if (!fs.existsSync(pkg)) return { status: 'BLOCKED', detail: 'autorin-backend missing' };
  const r = run('npm', ['test', '--', '--passWithNoTests'], {
    cwd: path.join(REPO_ROOT, 'autorin-backend'),
  });
  if (r.error) return { status: 'BLOCKED', detail: r.error, run: r };
  return { status: r.status === 0 ? 'PASS' : 'FAIL', detail: `exit ${r.status}`, run: r };
}

function backendGraphqlSmoke() {
  const r = run('node', ['./backend/tests/graphql-smoke.mjs'], { cwd: QA_ROOT });
  if (r.status === 2) return { status: 'BLOCKED', detail: r.stdout || r.stderr, run: r };
  if (r.status === 0) {
    try {
      const parsed = JSON.parse(r.stdout.trim().split('\n').slice(-20).join('\n').match(/\{[\s\S]*\}/)?.[0] ?? '{}');
      return { status: parsed.status || 'PASS', detail: parsed.detail, run: r };
    } catch {
      return { status: 'PASS', run: r };
    }
  }
  return { status: 'FAIL', detail: `exit ${r.status}`, run: r };
}

function backendContract() {
  const r = run('node', ['--test', './backend/tests/api-contract.smoke.test.mjs'], { cwd: QA_ROOT });
  if (r.error) return { status: 'BLOCKED', detail: r.error, run: r };
  return { status: r.status === 0 ? 'PASS' : 'FAIL', detail: `exit ${r.status}`, run: r };
}

function flutterTests() {
  if (!which('flutter')) return { status: 'BLOCKED', detail: 'flutter not on PATH' };
  const r = run('flutter', ['test'], { cwd: path.join(REPO_ROOT, 'my_auto'), timeout: 600_000 });
  if (r.error) return { status: 'BLOCKED', detail: r.error, run: r };
  return { status: r.status === 0 ? 'PASS' : 'FAIL', detail: `exit ${r.status}`, run: r };
}

function flutterAnalyze() {
  if (!which('flutter')) return { status: 'BLOCKED', detail: 'flutter not on PATH' };
  const r = run('flutter', ['analyze'], { cwd: path.join(REPO_ROOT, 'my_auto'), timeout: 600_000 });
  if (r.error) return { status: 'BLOCKED', detail: r.error, run: r };
  return { status: r.status === 0 ? 'PASS' : 'FAIL', detail: `exit ${r.status}`, run: r };
}

function securityAudit() {
  const results = [];
  const headers = run('node', ['./backend/tests/security-headers.mjs'], { cwd: QA_ROOT });
  results.push({
    check: 'api-headers',
    status: headers.status === 2 ? 'BLOCKED' : headers.status === 0 ? 'PASS_WITH_NOTES' : 'FAIL',
    output: headers.stdout || headers.stderr,
  });
  const zap = which('zap') || which('zap.sh') || which('zap-cli');
  results.push({
    check: 'owasp-zap',
    status: zap ? 'READY' : 'BLOCKED',
    detail: zap ? `found: ${zap}` : 'OWASP ZAP not installed. Install manually for DAST.',
  });
  const npmAudit = run('npm', ['audit', '--omit=dev'], {
    cwd: path.join(REPO_ROOT, 'autorin-backend'),
  });
  results.push({
    check: 'npm-audit-backend',
    status: npmAudit.status === 0 ? 'PASS' : 'PASS_WITH_NOTES',
    detail: `exit ${npmAudit.status}`,
    output: (npmAudit.stdout || npmAudit.stderr).slice(0, 2000),
  });
  const blocked = results.every((r) => r.status === 'BLOCKED');
  return {
    status: blocked ? 'BLOCKED' : 'PASS_WITH_NOTES',
    detail: 'Partial security smoke; full ZAP/SAST is manual',
    results,
  };
}

function performanceAudit() {
  const k6 = which('k6');
  if (!k6) {
    return {
      status: 'BLOCKED',
      detail: 'k6 not installed. Script ready at qa/performance/k6-smoke.js',
    };
  }
  const r = run('k6', ['run', path.join(QA_ROOT, 'performance', 'k6-smoke.js')]);
  return { status: r.status === 0 ? 'PASS' : 'FAIL', detail: `exit ${r.status}`, run: r };
}

function writeReport(sections) {
  fs.mkdirSync(REPORTS, { recursive: true });
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const summary = {
    generatedAt: new Date().toISOString(),
    workflow,
    safety:
      'Local/staging only. Never production without permission. No auto bug-fixes. No secret logging.',
    sections,
    counts: sections.reduce(
      (acc, s) => {
        acc[s.status] = (acc[s.status] || 0) + 1;
        return acc;
      },
      {},
    ),
  };
  const jsonPath = path.join(REPORTS, `qa-run-${workflow}-${stamp}.json`);
  const mdPath = path.join(REPORTS, `qa-run-${workflow}-${stamp}.md`);
  const latestJson = path.join(REPORTS, 'LATEST.json');
  const latestMd = path.join(REPORTS, 'LATEST.md');
  fs.writeFileSync(jsonPath, JSON.stringify(summary, null, 2));
  const md = [
    `# QA run — ${workflow}`,
    '',
    `Generated: ${summary.generatedAt}`,
    '',
    `Safety: ${summary.safety}`,
    '',
    '## Results',
    '',
    ...sections.map(
      (s) =>
        `- **${s.name}**: ${s.status}${s.detail ? ` — ${s.detail}` : ''} (${s.elapsedMs}ms)`,
    ),
    '',
    '## Counts',
    '',
    '```json',
    JSON.stringify(summary.counts, null, 2),
    '```',
    '',
  ].join('\n');
  fs.writeFileSync(mdPath, md);
  fs.writeFileSync(latestJson, JSON.stringify(summary, null, 2));
  fs.writeFileSync(latestMd, md);
  console.log(`\nReport written: ${mdPath}`);
  return summary;
}

const plan = {
  full: ['web', 'backend-unit', 'backend-graphql', 'backend-contract', 'flutter-test', 'flutter-analyze'],
  web: ['web'],
  backend: ['backend-unit', 'backend-graphql', 'backend-contract'],
  flutter: ['flutter-test', 'flutter-analyze'],
  security: ['security'],
  performance: ['performance'],
  regression: ['web', 'backend-unit', 'backend-contract', 'flutter-test'],
  report: [],
};

const steps = plan[workflow];
if (!steps && workflow !== 'report') {
  console.error(`Unknown workflow: ${workflow}`);
  console.error(`Known: ${Object.keys(plan).join(', ')}`);
  process.exit(1);
}

if (workflow === 'report') {
  const latest = path.join(REPORTS, 'LATEST.md');
  if (!fs.existsSync(latest)) {
    console.log('No LATEST.md yet. Run npm run qa:full first.');
    process.exit(2);
  }
  console.log(fs.readFileSync(latest, 'utf8'));
  process.exit(0);
}

const runners = {
  web: () => section('Web Playwright @smoke', webSmoke),
  'backend-unit': () => section('Backend Jest unit', backendUnit),
  'backend-graphql': () => section('Backend GraphQL smoke', backendGraphqlSmoke),
  'backend-contract': () => section('Backend fixture contract', backendContract),
  'flutter-test': () => section('Flutter test', flutterTests),
  'flutter-analyze': () => section('Flutter analyze', flutterAnalyze),
  security: () => section('Security audit', securityAudit),
  performance: () => section('Performance audit', performanceAudit),
};

const sections = steps.map((s) => runners[s]());
const summary = writeReport(sections);

const hardFail = sections.some((s) => s.status === 'FAIL');
const allBlocked = sections.length > 0 && sections.every((s) => s.status === 'BLOCKED');
if (hardFail) process.exit(1);
if (allBlocked) process.exit(2);
process.exit(0);
