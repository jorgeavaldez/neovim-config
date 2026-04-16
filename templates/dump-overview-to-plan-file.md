based on the above, put together a practical implementation plan in @PLAN_FILE for handoff to another engineer.

prioritize signal over exhaustiveness. include what a follow-up engineer needs to start safely and efficiently; do not turn the plan into a research dump.

if you have any clarifying questions, comments, concerns, or blockers that would materially affect the plan — STOP and let me address them before you continue. do not guess.

the plan should include:
- a brief summary of what we're doing and why
- a "current status" section directly below the summary that captures what's done, what's in progress, what's blocked, and what's next
- business context and requirements — not just the "what" but the "why", constraints, and expected behavior
- explicit scope: what's IN scope and what's OUT of scope
- assumptions that have already been validated, clearly distinguished from assumptions that still need validation before starting
- references to relevant files in the codebase (use relative paths)
- the key findings, observations, decisions, and implementation details that would save the next engineer time

structure the plan in phases. each phase should include:
- goal and description
- files touched or created
- approach and key details
- acceptance criteria (how to know it's done)
where possible, design phases so they can be worked in parallel. clearly mark dependency phases and what they depend on.

include a progress checklist that maps to the phases and key deliverables so an engineer can quickly see what is complete and what remains.

constraints:
- do NOT include full code implementations. code snippets are fine only when they remove material ambiguity.
- remove material ambiguity, but do NOT chase perfection or document every conceivable edge case.
- if something is unresolved but non-blocking, document it briefly in the most relevant section instead of expanding the plan.
- keep the plan concise, integrated, and useful. avoid duplication, implementation journals, and append-only discovery dumps.
- prioritize blocker-level and high-risk information over low-value polish.
- if you do any additional investigation, keep findings filtered to the most important risks, gaps, or decisions — not exhaustive nitpicks.

when you're done writing:
1. do one self-review focused only on blocker-level gaps, contradictions, or missing implementation details
2. optionally run at most one review task only if the work is unusually cross-cutting or high-risk
3. if you run that review task, ask for at most the top 5 blocker/high-risk issues
4. incorporate only material fixes
5. STOP once the plan is implementation-ready; do not loop on repeated reviews or micro-edits

quality bar:
- the receiving engineer should be able to implement without re-discovering the core context
- remaining issues, if any, should be editorial or low-risk rather than blockers
- good enough and clear beats exhaustive and bloated
