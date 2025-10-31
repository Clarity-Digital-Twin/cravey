# Phase 5: Data Management + Settings

**Version:** 1.0 (Placeholder)
**Duration:** 1 week
**Dependencies:** Phases 1-3 (exports all data types)
**Status:** ⏳ Pending (starts after Phase 4 complete)

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can **export data** (CSV/JSON) and **delete all data** with confirmation.

**Feature Implemented:** Feature 5 (Data Management)

---

## 📦 Files to Create (6 files)

### Domain Layer (2 files)
- `Domain/UseCases/ExportDataUseCase.swift`
- `Domain/UseCases/DeleteAllDataUseCase.swift`

### Presentation Layer (4 files)
- `Presentation/ViewModels/SettingsViewModel.swift`
- `Presentation/Views/Settings/SettingsView.swift`
- `Presentation/Views/Settings/ExportDataView.swift`
- `Presentation/Views/Settings/DeleteDataView.swift` (alert only)

---

## ✅ Success Criteria

- [ ] Export generates CSV with all cravings + usage + recordings
- [ ] Export generates JSON with all data
- [ ] Share Sheet works (users can AirDrop/email export)
- [ ] Delete all data works (atomic deletion)
- [ ] Delete confirmation shows warning
- [ ] All tests passing (6 unit + 2 integration + 2 UI)

---

**Full implementation details will be added after Phase 4 completion.**

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[Phase 4 →](./PHASE_4.md)**
