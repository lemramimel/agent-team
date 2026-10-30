# Third-party material

agent-team copies a curated subset of skills from other methods. Each is MIT-licensed; the license texts are in `licenses/`. Copies are pinned by commit in `vendor/skills.lock`. Only markdown is copied: no upstream script is vendored. `scripts/vendor-skills.sh status` shows upstream changes since the pinned commit, and `scripts/vendor-check.sh` checks that no skill contains an instruction that breaks the team's rules.

| Skill | Upstream | Commit | Adapted |
|---|---|---|---|
| `test-driven-development` | obra/superpowers (`skills/test-driven-development`) | `2ce8aa1` | "human partner" wording |
| `verification-before-completion` | obra/superpowers (`skills/verification-before-completion`) | `2ce8aa1` | provenance notice only |
| `writing-plans` | obra/superpowers (`skills/writing-plans`) | `2ce8aa1` | save path, French, sub-skill pointer, commit example |
| `requesting-code-review` | obra/superpowers (`skills/requesting-code-review`) | `2ce8aa1` | plan path; "Team rules" section appended (read-only, language, pre-report gate, depth by risk) |
| `receiving-code-review` | obra/superpowers (`skills/receiving-code-review`) | `2ce8aa1` | "human partner" wording |
| `dispatching-parallel-agents` | obra/superpowers (`skills/dispatching-parallel-agents`) | `2ce8aa1` | provenance notice only |
| `grilling` | mattpocock/skills (`skills/productivity/grilling`) | `a496f55` | provenance notice only |
| `handoff` | mattpocock/skills (`skills/productivity/handoff`) | `a496f55` | provenance notice only |
| `to-spec` | mattpocock/skills (`skills/engineering/to-spec`) | `a496f55` | manual-only flag removed so agents can load it; publication through the `tracker` skill and only after user approval; no automatic triage label; French template headings |
| `to-tickets` | mattpocock/skills (`skills/engineering/to-tickets`) | `a496f55` | manual-only flag removed so agents can load it; publication through the `tracker` skill; no automatic triage label; French ticket template with "Bloqué par" |
| `diagnosing-bugs` | mattpocock/skills (`skills/engineering/diagnosing-bugs`) | `a496f55` | upstream bash helper not included; references replaced |
| `codebase-design` | mattpocock/skills (`skills/engineering/codebase-design`) | `a496f55` | provenance notice only |
| `domain-modeling` | mattpocock/skills (`skills/engineering/domain-modeling`) | `a496f55` | provenance notice only |
| `pr-description` | mattpocock/skills (`skills/engineering/pr`) | `a496f55` | renamed from `pr`; template mapped onto Contexte / Changements / Vérification / Limites |
| `retro` | mattpocock/skills (`skills/engineering/retro`) | `a496f55` | provenance notice only |
| `architecture-decision-records` | affaan-m/everything-claude-code (`skills/architecture-decision-records`) | `b38be6a` | provenance notice only |
| `documentation-lookup` | affaan-m/everything-claude-code (`skills/documentation-lookup`) | `b38be6a` | provenance notice only |
| `accessibility` | affaan-m/everything-claude-code (`skills/accessibility`) | `b38be6a` | iOS, Android, diagram and cross-platform sections removed |
| `frontend-design-direction` | affaan-m/everything-claude-code (`skills/frontend-design-direction`) | `b38be6a` | upstream checker script not included; reference removed |
| `click-path-audit` | affaan-m/everything-claude-code (`skills/click-path-audit`) | `b38be6a` | cross-references renamed to the skills we ship |
| `security-review` | affaan-m/everything-claude-code (`skills/security-review`) | `b38be6a` | Solana, Supabase and RLS content removed; Prisma example; project stack notes appended |

## Agent adapted from an upstream agent
- `agents/sam.md` is adapted from `agents/security-reviewer.md` of affaan-m/everything-claude-code at `b38be6a` (MIT): the workflow, the pattern table, the false-positive list; the prompt-defense boilerplate was dropped and the human actions were made explicit.

## Licenses
- obra/superpowers: MIT, `licenses/obra_superpowers.LICENSE`
- mattpocock/skills: MIT, `licenses/mattpocock_skills.LICENSE`. The `pr-description` skill credits Dex Horthy (Humanlayer), see its `CREDITS.md`.
- affaan-m/everything-claude-code: MIT, `licenses/affaan-m_everything-claude-code.LICENSE`
- BMAD-METHOD (not vendored, used as a dependency): MIT, (c) BMad Code LLC.
- garrytan/gstack (not vendored, see `docs/METHODS.md`): MIT.
