# DEBT-009: GPS "Current Location" Spec Not Implemented

**Priority:** P3 (Spec Drift / Feature Gap)
**Status:** OPEN
**Created:** 2026-01-27
**Last Audited:** 2026-01-27

## Problem

The master specs include a location option:
- **Current Location (GPS auto-detect via CoreLocation, local storage only)**

The app does not currently integrate CoreLocation, request location permission, or store coordinates. A placeholder "Current Location" chip was removed from `LocationOptions.presets` to avoid misleading users into thinking GPS is active.

## Impact

- Feature gap vs SSOT (`docs/master/*`)
- Potential user confusion if a GPS-labeled option appears without GPS behavior

## Options

### Option A: Implement GPS (Spec-Complete)

- Add CoreLocation integration (local-only)
- Add `NSLocationWhenInUseUsageDescription` to `Config/iOS.Info.plist.template`
- Store coordinates locally (or store only coarse/preset location, per privacy stance)

### Option B: Defer GPS (Current)

- Keep location as manual presets only (Home/Work/Social/Outside/Car)
- Update product/spec docs to reflect GPS being postponed

## Acceptance Criteria

- [ ] Decide: Implement GPS now (A) vs defer (B) and update specs accordingly
- [ ] If implementing GPS: location permission + local-only storage is in place and covered by tests where feasible

