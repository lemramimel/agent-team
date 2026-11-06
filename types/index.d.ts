export type Phase = {
  id: string
  label: string
  agents: string[]
  status: 'done' | 'active' | 'pending' | 'skipped'
  detail: string
}
export type AgentRun = { running: number; runs: number }
export type Run = {
  ticket: string
  startedAt: number
  isChecked: boolean
  agents: Record<string, AgentRun>
}
export type Snapshot = {
  branch: string
  ticket: string
  title: string
  risk: string
  phases: Phase[]
  prUrl: string
  isTrunk: boolean
  isMerged: boolean
  hasCi: boolean
  runUrl: string
  runStatus: string
  failedSteps: string[]
  at: number
}

declare module 'claude-code' {
  interface PluginState {
    'feature-panel': {
      snapshot: Shaped<Snapshot | null>
      run: Shaped<Run>
    }
  }
}
