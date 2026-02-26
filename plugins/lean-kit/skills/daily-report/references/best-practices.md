# Claude Code Best Practices Reference

Curated tips from official documentation and community experience.
Used by the report generator (Section 9) to provide data-backed suggestions.

---

## 1. Cache Optimization

- **Stable system prompt**: Place CLAUDE.md instructions and project context at the top of prompts so the cache prefix stays warm across turns.
- **Session continuity**: Staying in the same session keeps cache warm. Excessive `/clear` or session restarts invalidate cache.
- **Cache hit rate target**: >85% cache read ratio indicates effective prompt structure. Below 70% suggests frequent context changes.
- **Cost impact**: Cache read is 10x cheaper than fresh input (e.g., $1.50/M vs $15/M for Opus). Prioritize cache-friendly workflows.

## 2. Model Selection (Tiering)

- **Opus**: Complex reasoning, architecture planning, multi-step debugging, critical code review.
- **Sonnet**: Standard coding tasks, refactoring, documentation, CI/CD pipeline work. 5x cheaper than Opus.
- **Haiku**: Simple tasks — formatting, commit message generation, straightforward file edits. 19x cheaper than Opus.
- **Subagent tiering**: Use `model: "sonnet"` or `model: "haiku"` in Task tool for parallelized workers doing focused tasks.

## 3. Context Management

- **Context window awareness**: Opus 4.6 has ~200K context window. Sessions approaching limit trigger compression or continuation.
- **`/clear` timing**: Use after completing a logical unit of work to free context. Don't clear mid-task.
- **Session splitting**: Break large tasks into phases. Each phase in a new session preserves cache efficiency.
- **Plan mode**: Start complex tasks with `/plan` to structure work before consuming tokens on implementation.

## 4. Prompt Techniques

- **Plan → Implement pattern**: Write a detailed plan first, then execute with "Implement the following plan:". Reduces backtracking.
- **GC loop (Generator-Critic)**: For precision-critical outputs, explicitly request verification passes. Define criteria upfront.
- **Specific instructions**: "Verify build succeeds + no unused imports" beats vague "make sure it's correct".
- **Incremental prompts**: Break "do everything" into "do step 1", "now step 2". Keeps each response focused.

## 5. Subagent Usage

- **Explore agent**: Best for codebase navigation. Record frequently accessed paths in CLAUDE.md to reduce Explore calls.
- **TeamCreate parallel**: Use for independent subtasks (e.g., build-engineer + source-engineer). Reduces wall-clock time.
- **Subagent model**: Default is parent model. Override to sonnet/haiku for cost-effective parallelism.
- **Task isolation**: `isolation: "worktree"` for write tasks that might conflict with main session.

## 6. Session Strategy

- **Logical commit points**: Commit after each meaningful milestone, not all at end. Protects against session loss.
- **Empty session avoidance**: Verify correct project directory before starting. Empty sessions waste startup overhead.
- **Carry-over awareness**: Sessions spanning midnight carry previous-day cache costs into the new day's accounting.
- **AskUserQuestion**: Prefer asking for clarification early over trial-and-error iterations. One question saves multiple retry cycles.

## 7. Tool Usage Efficiency

- **Read vs Bash**: Use Read tool for file content (better UX, structured output). Reserve Bash for shell operations.
- **Glob vs find**: Glob is optimized for Claude Code. Avoid `find` commands when Glob suffices.
- **Grep vs rg**: Use Grep tool (built-in ripgrep wrapper) rather than Bash grep/rg.
- **Edit precision**: Edit tool for targeted changes. Write tool only for new files or complete rewrites.

## 8. CLAUDE.md Optimization

- **Key paths**: Document frequently referenced file paths to reduce Explore/Glob calls.
- **Conventions**: Codify naming conventions, commit message formats, PR templates.
- **Memory vs CLAUDE.md**: Use CLAUDE.md for stable project rules. Use memory for cross-project personal preferences.
- **Token budget**: Keep CLAUDE.md concise (<500 lines). Large files inflate every prompt's cache creation cost.
