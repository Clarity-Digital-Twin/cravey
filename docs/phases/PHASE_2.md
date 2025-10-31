# Phase 2: Usage Logging

**Version:** 1.0 (Placeholder)
**Duration:** 1 week
**Dependencies:** Phase 1 (reuses ChipSelector, TimestampPicker)
**Status:** ⏳ Pending (starts after Phase 1 complete)

---

## 🎯 Phase Goal

**Shippable Deliverable:** Users can log both **cravings AND usage** with ROA-specific amounts.

**Feature Implemented:** Feature 2 (Usage Logging)

---

## 📦 Files to Create (8 files)

### Domain Layer (4 files)
- `Domain/Entities/UsageEntity.swift`
- `Domain/UseCases/LogUsageUseCase.swift`
- `Domain/UseCases/FetchUsageUseCase.swift`
- `Domain/Repositories/UsageRepositoryProtocol.swift`

### Data Layer (2 files)
- `Data/Repositories/UsageRepository.swift`
- `Data/Mappers/UsageMapper.swift`

### Presentation Layer (2 files)
- `Presentation/ViewModels/UsageLogViewModel.swift`
- `Presentation/Views/Usage/UsageLogForm.swift`

### Components (1 file)
- `Presentation/Views/Components/PickerWheelInput.swift` (ROA-aware)

---

## ✅ Success Criteria

- [ ] Users can log usage in <10 seconds
- [ ] ROA picker shows context-aware amounts
- [ ] Multi-select triggers work (reuses ChipSelector)
- [ ] Usage list view displays logged usage
- [ ] All tests passing (10 unit + 2 integration + 2 UI)

---

**Full implementation details will be added after Phase 1 completion.**

**[← Back to Overview](./PHASE_OVERVIEW.md)** | **[Phase 1 →](./PHASE_1.md)**
