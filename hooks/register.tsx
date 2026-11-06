import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Phase, Run, Snapshot } from '../types'

const PANE = 'feature-panel'
const OPEN = { id: PANE, title: 'Feature', columns: 40, backgroundColor: 'transparent' } as const
const EMPTY: Run = { ticket: '', startedAt: 0, isChecked: false, agents: {}, tokens: {} }
const snapshot = atom({ plugin: 'feature-panel', key: 'snapshot' } as const, null as Snapshot | null, { shape: 'snapshot-1' })
const run = atom({ plugin: 'feature-panel', key: 'run' } as const, EMPTY, { shape: 'run-2' })

const ROSTER = ['atlas', 'mira', 'winston', 'sally', 'quinn', 'amelia', 'iris', 'vera', 'sam', 'gita', 'ned'] as const
const ROLE: Record<string, string> = {
  atlas: 'CEO', mira: 'produit', winston: 'architecte', sally: 'UX', quinn: 'QA', amelia: 'dev',
  iris: 'UI', vera: 'relecture', sam: 'sécurité', gita: 'git', ned: 'devops',
}
const REVIEWERS: Record<string, string[]> = { low: ['vera'], medium: ['vera', 'quinn'], high: ['vera', 'quinn', 'sam'] }

type Ctx = {
  isTrunk: boolean
  subjects: string[]
  prState: string
  runStatus: string
  hasCi: boolean
  risk: string
  run: Run
}

const seen = (r: Run, names: string[]) => names.some(n => (r.agents[n]?.runs ?? 0) > 0)
const busy = (r: Run, names: string[]) => names.some(n => (r.agents[n]?.running ?? 0) > 0)

const computePhases = (c: Ctx): Phase[] => {
  const hasTestCommit = c.subjects.some(s => /^test(\(|:)/.test(s))
  const hasCode = c.subjects.some(s => !/^(test|docs)/.test(s))
  const hasPr = c.prState !== ''
  const merged = c.prState === 'MERGED'
  const reviewers: string[] = REVIEWERS[c.risk] ?? ['vera', 'quinn']
  const rounds = c.run.agents.vera?.runs ?? 0
  const ciOk = c.runStatus === 'success'
  const mergeNote = c.risk === 'high' ? 'suspendue : accord requis (risk:high)' : !c.hasCi ? 'suspendue : pas de CI' : 'squash vers develop, sur l’appel'
  // id, label, agents, optional, evidence, finished, detail when active
  const raw: [string, string, string[], boolean, boolean, boolean, string][] = [
    ['prevol', 'Pré-vol', ['atlas'], false, !c.isTrunk, true, 'ticket, risque, arbre propre, branche'],
    ['design', 'Conception', ['mira', 'winston', 'sally'], true, seen(c.run, ['mira', 'winston', 'sally']), !busy(c.run, ['mira', 'winston', 'sally']), 'seulement si nécessaire'],
    ['tests', 'Tests d’abord', c.risk === 'low' ? ['amelia'] : ['quinn'], true, hasTestCommit, hasTestCommit, 'écrits avant le code, échec attendu'],
    ['build', 'Build', ['amelia', 'iris'], false, seen(c.run, ['amelia', 'iris']) || hasCode, !busy(c.run, ['amelia', 'iris']) && (seen(c.run, ['amelia', 'iris']) || hasCode), `${c.subjects.length} commit(s)`],
    ['checks', 'Contrôles', ['atlas'], true, c.run.isChecked, c.run.isChecked, 'lint, types, tests, build'],
    ['review', 'Relecture', reviewers, false, rounds > 0, rounds > 0 && !busy(c.run, reviewers), rounds > 0 ? `tour ${rounds} / 2` : `risk:${c.risk}`],
    ['deliver', 'Commits et PR', ['gita'], false, hasPr, hasPr, 'git-flow.sh commit puis pr'],
    ['ci', 'CI', ['atlas'], false, c.runStatus !== '', ciOk || merged, c.runStatus ? c.runStatus : c.hasCi ? 'en attente du run' : 'aucun workflow'],
    ['merge', 'Fusion', ['atlas'], false, merged, merged, mergeNote],
    ['report', 'Compte rendu', ['atlas'], false, merged, merged, 'livré, PR, relecture'],
  ]
  let reached = -1
  raw.forEach((p, i) => { if (p[4]) reached = i })
  let isActiveSet = false
  return raw.map(([id, label, agents, optional, evidence, finished, detail], i) => {
    if (i < reached && optional && !evidence) return { id, label, agents, status: 'skipped' as const, detail: 'sans objet' }
    if (i < reached || (i === reached && finished)) return { id, label, agents, status: 'done' as const, detail: '' }
    if (!isActiveSet) {
      isActiveSet = true
      return { id, label, agents, status: 'active' as const, detail }
    }
    return { id, label, agents, status: 'pending' as const, detail: '' }
  })
}

const collect = async ($: any): Promise<Snapshot> => {
  const sh = async (argv: string[]): Promise<string> => {
    try {
      const r = await $.process.run(argv, { timeoutMs: 20000 })
      return r.exitCode === 0 ? r.stdout : ''
    } catch {
      return ''
    }
  }
  const branch = (await sh(['git', 'rev-parse', '--abbrev-ref', 'HEAD'])).trim()
  const isTrunk = ['develop', 'main', 'master', ''].includes(branch)
  const r: Run = await read($, run)
  let ticket = r.ticket
  let title = ''
  let prState = ''
  let prUrl = ''
  if (!isTrunk) {
    const pr = await sh(['gh', 'pr', 'view', '--json', 'title,state,url'])
    if (pr) {
      const p = JSON.parse(pr)
      title = p.title ?? ''
      prState = p.state ?? ''
      prUrl = p.url ?? ''
      ticket = ticket || (title.match(/\(#(\d+)\)/)?.[1] ? `#${title.match(/\(#(\d+)\)/)![1]}` : '')
    }
  }
  const base = (await sh(['git', 'rev-parse', '--verify', 'develop'])) ? 'develop' : 'origin/develop'
  const subjects = isTrunk ? [] : (await sh(['git', 'log', `${base}..HEAD`, '--format=%s'])).trim().split('\n').filter(Boolean)

  let risk = 'medium'
  if (ticket) {
    const issue = await sh(['gh', 'issue', 'view', ticket.replace('#', ''), '--json', 'title,labels'])
    if (issue) {
      const i = JSON.parse(issue)
      title = title || (i.title ?? '')
      const label = (i.labels ?? []).map((l: any) => l.name as string).find((n: string) => /^risk:/.test(n))
      if (label) risk = label.slice(5)
    }
  }

  const hasCi = (await sh(['grep', '-rl', 'pull_request', '.github/workflows'])).trim() !== ''
  let runUrl = ''
  let runStatus = ''
  let failedSteps: string[] = []
  if (!isTrunk) {
    const list = await sh(['gh', 'run', 'list', '--branch', branch, '-L', '1', '--json', 'databaseId,status,conclusion,url'])
    const last = list ? JSON.parse(list)[0] : undefined
    if (last) {
      runUrl = last.url
      runStatus = last.status === 'completed' ? last.conclusion : last.status
      if (runStatus === 'failure') {
        const view = await sh(['gh', 'run', 'view', String(last.databaseId), '--json', 'jobs'])
        if (view) failedSteps = JSON.parse(view).jobs.flatMap((j: any) => (j.steps ?? []).filter((s: any) => s.conclusion === 'failure').map((s: any) => s.name as string))
      }
    }
  }
  const phases = computePhases({ isTrunk, subjects, prState, runStatus, hasCi, risk, run: r })
  return { branch, ticket, title, risk, phases, prUrl, isTrunk, isMerged: prState === 'MERGED', hasCi, runUrl, runStatus, failedSteps, at: await $.clock.now() }
}

let isShown = false

async function sync($: any) {
  const before = await read($, snapshot)
  const s = await collect($)
  await update($, snapshot, () => s)
  const isOver = s.isMerged || (s.isTrunk && before !== null && !before.isTrunk)
  if (isOver && isShown) {
    isShown = false
    await $.ui.close({ id: PANE })
  }
}

async function show($: any) {
  isShown = true
  await $.ui.open(OPEN)
  await sync($)
}

const agentOf = (e: any): string => {
  const t = e?.input?.subagent_type ?? e?.args?.subagent_type ?? JSON.stringify(e).match(/"subagent_?[tT]ype":"([^"]+)"/)?.[1] ?? ''
  return String(t).replace(/^agent-team:/, '')
}

// Tokens d'un sous-agent : `totalTokens` de son résultat.
const tokensOf = (out: any): number => {
  const n = Number(out?.result?.totalTokens ?? out?.totalTokens ?? 0)
  return Number.isFinite(n) && n > 0 ? n : 0
}

// 12345 -> « 12,3k », 1234567 -> « 1,23M ».
const fmt = (n: number): string => {
  if (n < 1000) return String(n)
  const [v, u] = n < 1_000_000 ? [n / 1000, 'k'] : [n / 1_000_000, 'M']
  return `${(v >= 100 ? v.toFixed(0) : v >= 10 ? v.toFixed(1) : v.toFixed(2)).replace('.', ',')}${u}`
}

// Les tokens d'un sous-agent vont à l'étape en cours quand il se termine.
async function setAgent($: any, name: string, isStart: boolean, tokens = 0) {
  const snap = await read($, snapshot)
  const at = snap?.phases.find(p => p.status === 'active') ?? [...(snap?.phases ?? [])].reverse().find(p => p.status === 'done')
  await update($, run, r => {
    const cur = r.agents[name] ?? { running: 0, runs: 0 }
    const next = isStart ? { running: cur.running + 1, runs: cur.runs + 1 } : { running: Math.max(0, cur.running - 1), runs: cur.runs }
    const spent = !isStart && tokens > 0 && at ? { ...r.tokens, [at.id]: (r.tokens[at.id] ?? 0) + tokens } : r.tokens
    return { ...r, agents: { ...r.agents, [name]: next }, tokens: spent }
  })
  if (isShown) await sync($)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'equipe', description: 'Ouvre le panneau des étapes de /feature et des agents' })
    void sync($).then(async () => {
      const s = await read($, snapshot)
      if (s && !s.isTrunk && !s.isMerged) await show($)
    })
    $.clock.every(8000, () => { if (isShown) void sync($) })
    return next(e)
  })

  on('command.run', { command: 'equipe' }, async $ => {
    await show($)
    return { text: 'Panneau de /feature ouvert.' }
  })

  // /feature #N (ou /agent-team:feature #N) ouvre le panneau et repart d'un état vierge.
  on('prompt.submit', async ($, e, next) => {
    const m = e.text.match(/^\s*\/(?:agent-team:)?feature\b\s*(#\d+)?/)
    if (m) {
      const now = await $.clock.now()
      await update($, run, () => ({ ...EMPTY, ticket: m[1] ?? '', startedAt: now }))
      void show($)
    }
    return next(e)
  })

  on('tool.call', { tool: 'Agent' }, async ($, e: any, next) => {
    const name = agentOf(e)
    if (!name || !(ROSTER as readonly string[]).includes(name)) return next(e)
    await setAgent($, name, true)
    let out: unknown
    try {
      out = await next(e)
      return out as any
    } finally {
      await setAgent($, name, false, tokensOf(out))
    }
  })

  on('tool.call', { tool: 'Bash' }, async ($, e: any, next) => {
    const cmd: string = e?.input?.command ?? e?.args?.command ?? ''
    if (/\b(npm|pnpm|yarn)\b.*\b(test|lint|typecheck|build)\b/.test(cmd)) await update($, run, r => ({ ...r, isChecked: true }))
    const out = await next(e)
    if (isShown) void sync($)
    return out
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const s = await read($, snapshot)
    const r: Run = await read($, run)
    if (!s) return <Text dimColor>Chargement…</Text>
    const cols = Number(('bodyColumns' in e ? e.bodyColumns : 0) || 38)
    const w = Math.max(10, cols - 1)
    const rule = '─'.repeat(w)
    const counted = s.phases.filter(p => p.status !== 'skipped')
    const done = counted.filter(p => p.status === 'done').length
    const filled = counted.length ? Math.round((done / counted.length) * w) : 0
    const head = (t: string) => <Text dimColor bold>{t.toUpperCase()}</Text>
    const riskColor = s.risk === 'high' ? 'red' : s.risk === 'low' ? 'green' : 'yellow'
    const ci = s.runStatus === 'success' ? { i: '✓', c: 'green' } : s.runStatus === 'failure' ? { i: '✗', c: 'red' } : s.runStatus ? { i: '●', c: 'yellow' } : { i: '○', c: 'gray' }
    const mark = (p: Phase) => (p.status === 'done' ? '✓' : p.status === 'active' ? '▶' : p.status === 'skipped' ? '–' : '○')
    const tint = (p: Phase) => (p.status === 'done' ? 'green' : p.status === 'active' ? 'yellow' : 'gray')
    return (
      <Box flexDirection="column">
        <Text bold color="cyan">{s.ticket || 'AUCUN TICKET'}</Text>
        {s.title !== '' && <Text>{s.title}</Text>}
        <Text dimColor>⎇ {s.branch}</Text>
        <Text color={riskColor}>risk:{s.risk}</Text>
        <Text dimColor>{rule}</Text>
        <Box justifyContent="space-between">
          {head('Workflow /feature')}
          <Text bold>{done}/{counted.length}</Text>
        </Box>
        <Text color={done === counted.length ? 'green' : 'cyan'}>{'▰'.repeat(filled)}<Text dimColor>{'▱'.repeat(w - filled)}</Text></Text>
        {s.phases.map(p => (
          <Box flexDirection="column">
            <Text color={tint(p)} bold={p.status === 'active'} dimColor={p.status === 'skipped'}>
              {mark(p)} {p.label}
              <Text dimColor>  {p.agents.join(', ')}</Text>
            </Text>
            {(r.tokens[p.id] ?? 0) > 0 && <Text dimColor>    {fmt(r.tokens[p.id] ?? 0)} tokens</Text>}
            {p.status !== 'done' && p.status !== 'skipped' && p.detail !== '' && <Text dimColor>    {p.detail}</Text>}
          </Box>
        ))}
        <Text dimColor>{rule}</Text>
        {head('Agents')}
        {ROSTER.map(n => {
          const a = r.agents[n]
          const isOn = (a?.running ?? 0) > 0
          const isMain = n === 'atlas'
          const icon = isOn || isMain ? '●' : (a?.runs ?? 0) > 0 ? '✓' : '○'
          const color = isOn || isMain ? 'yellow' : (a?.runs ?? 0) > 0 ? 'green' : 'gray'
          return (
            <Box justifyContent="space-between">
              <Text color={color}>{icon} {n} <Text dimColor>{ROLE[n]}</Text></Text>
              {(a?.runs ?? 0) > 0 && <Text dimColor>×{a!.runs}</Text>}
            </Box>
          )
        })}
        <Text dimColor>{rule}</Text>
        <Box justifyContent="space-between">
          {head('CI')}
          <Text color={ci.c}>{ci.i} {s.runStatus || (s.hasCi ? 'aucun run' : 'aucun workflow')}</Text>
        </Box>
        {s.failedSteps.map(n => <Text color="red"> ✗ {n}</Text>)}
        <Text dimColor>{rule}</Text>
        <Box justifyContent="space-between">
          {head('Tokens (sous-agents)')}
          <Text bold>{fmt(Object.values(r.tokens).reduce((a, b) => a + b, 0))}</Text>
        </Box>
      </Box>
    )
  })
}
