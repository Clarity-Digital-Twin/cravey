# Bug & Issue Tracker

**Last Updated:** 2026-01-26
**Total Issues:** 65 (47 legacy + 18 from audit)

---

## Quick Stats

| Category | Open | Fixed | Total |
|----------|------|-------|-------|
| P0 - Critical | 0 | 4 | 4 |
| P1 - Major | 4 | 6 | 10 |
| P2 - Minor | 5 | 10 | 15 |
| P3 - Tech Debt | 9 | 7 | 16 |
| P4 - Code Quality | 8 | 12 | 20 |

---

## Priority Definitions

- **P0 - Critical:** Crashes, data loss, security issues. Fix immediately.
- **P1 - Major:** Features broken, significant user impact. Fix this sprint.
- **P2 - Minor:** Edge cases, race conditions, logic errors. Fix soon.
- **P3 - Tech Debt:** Architecture concerns, testability issues. Pay down incrementally.
- **P4 - Code Quality:** Code smells, style, minor optimizations. Fix opportunistically.

---

## File Structure

### Current Bugs
| File | Contents |
|------|----------|
| `AUDIT_2026_01_26.md` | **NEW** - Deep code audit (18 issues) |
| `P0_CRITICAL.md` | Critical issues (all fixed) |
| `P1_MAJOR.md` | Major functional issues |
| `P2_MINOR.md` | Minor issues and edge cases |
| `P3_TECH_DEBT.md` | Architecture and design debt |
| `P4_CODE_QUALITY.md` | Code quality improvements |

### Related Docs
| File | Contents |
|------|----------|
| `../debt/README.md` | **NEW** - Design/UX/Clinical debt |
| `../debt/LANG_CLINICAL.md` | Stigma-free language issues |
| `../debt/UX_DESIGN.md` | UX/UI design issues |
| `../debt/FEATURE_GAPS.md` | Missing/incomplete features |

---

## Top Priorities

### Must Fix Before Beta (P2)

| ID | Issue | File |
|----|-------|------|
| BUG-025 | StartupFailure alert not shown | CraveyApp.swift |
| BUG-026 | HomeView sheet success race condition | HomeView.swift |
| BUG-027 | RecordingMapper silent enum downgrade | RecordingMapper.swift |
| BUG-028 | Streak calculation logic unclear | DashboardViewModel.swift |
| BUG-029 | Delete all data not atomic | SwiftDataDeleteAllUserDataUseCase.swift |

### Should Fix Soon (P1)

| ID | Issue | File |
|----|-------|------|
| BUG-015 | First launch onboarding missing | - |
| BUG-016 | Home tab UX mismatch | HomeView.swift |
| BUG-017 | Dashboard spec gap | DashboardView.swift |
| BUG-018 | Recordings feature stubbed | - |

### Clinical/Language Debt (Critical for Release)

| ID | Issue | File |
|----|-------|------|
| LANG-001 | "Days Clean" is stigmatizing | DashboardView.swift |
| LANG-002 | "Clean" in specs/comments | Multiple |
| LANG-003 | Streak nomenclature unclear | DashboardViewModel.swift |

---

## Recently Fixed

- BUG-023 - Removed startup fatalError; added AppUnavailable fallback
- BUG-024 - UsageListViewModel preserves error context
- QUALITY-013 - RecordingModel linkedCravings non-optional
- QUALITY-014 - Consistent save error mapping in Log* use cases
- BUG-019 - Disabled interactive sheet dismiss during save
- BUG-020 - Intensity color scale aligned to spec
- BUG-021 - Dashboard top triggers include usage triggers
- BUG-022 - Domain validation for future timestamps + notes length

---

## Bug ID Format

```
BUG-XXX    - Functional bugs (crashes, wrong behavior)
DEBT-XXX   - Technical debt (architecture, design)
QUALITY-XXX - Code quality (style, performance)
LANG-XXX   - Language/terminology (stigma-free)
UX-XXX     - User experience issues
FEAT-XXX   - Feature gaps
```

---

## Workflow

1. Pick issue from highest priority
2. Create branch: `fix/BUG-XXX-short-description`
3. Fix the issue
4. Update status in the relevant doc
5. PR with bug ID in title

---

## Archive

Legacy P0-P4 files are kept for historical reference but new issues should use the explicit ID format (BUG-XXX, DEBT-XXX, etc.) in the audit file or create new dedicated issue files.
