# Phase 4: Dashboard

**Version:** 1.0 (Placeholder)
**Duration:** 1 week
**Dependencies:** Phases 1-2 (needs craving + usage data)
**Status:** ⏳ Pending (starts after Phase 3 complete)

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can **visualize progress** with 11 metrics and date range filtering.

**Feature Implemented:** Feature 4 (Dashboard)

---

## 📦 Files to Create (5 files)

### Domain Layer (1 file)
- `Domain/UseCases/FetchDashboardDataUseCase.swift`

### Presentation Layer (2 files)
- `Presentation/ViewModels/DashboardViewModel.swift`
- `Presentation/Views/Dashboard/DashboardView.swift`

### Components (2 files)
- `Presentation/Views/Components/ChartCard.swift`
- `Presentation/Views/Components/EmptyStateView.swift`

---

## 📊 11 Metrics to Implement

1. Summary Card (total cravings + usage)
2. Current Streak
3. Longest Streak
4. Craving Intensity Over Time (line chart)
5. Craving Frequency (bar chart)
6. Trigger Breakdown (pie chart)
7. Time of Day Heatmap
8. Usage by ROA (bar chart)
9. Craving vs Usage Correlation (line chart)
10. Success Rate (managed cravings)
11. Weekly Trends (bar chart)

---

## ✅ Success Criteria

- [ ] Dashboard loads <3 seconds with 90 days of data
- [ ] All 11 metrics render correctly
- [ ] Date range filter works (7/30/90 days)
- [ ] Empty state shows for <2 logs
- [ ] All tests passing (8 unit + 2 integration + 1 UI)

---

**Full implementation details will be added after Phase 3 completion.**

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[Phase 3 →](./PHASE_3.md)**
