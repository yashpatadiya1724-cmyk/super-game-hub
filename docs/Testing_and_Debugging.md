# Testing and Debugging Quality Assurance Report
Project: Super Game Hub
Course: Mobile Game Development (SOCCA, Semester 5)

## 1. Overview
During development and playtesting across target devices (Android 14 physical device, Flame engine testbed, Chrome Web runtime), 5 critical bugs were identified, isolated, and permanently resolved.

---

### Bug #1: Null Pointer Crash on Canvas Board Initialization
- **Category**: UI / Canvas Rendering
- **Symptom**: `NoSuchMethodError` when attempting to access `boardSize.width` before layout completion.
- **Root Cause**: Board dimensions evaluated inside update loop before `LayoutBuilder` performed its initial render pass.
- **Fix Implemented**: Added explicit null safety check `if (boardSize == null) return;` and wrapped canvas bounds setup in `LayoutBuilder` constraints callback.
- **Status**: FIXED & VERIFIED

---

### Bug #2: Timer Memory Leak on Screen Navigation
- **Category**: Performance / Memory
- **Symptom**: Background `Timer.periodic` loops continued executing after navigating back to main menu, attempting to call `setState` on unmounted widgets.
- **Root Cause**: Widget `dispose()` method did not properly cancel active timer instances.
- **Fix Implemented**: Added `!mounted` verification inside periodic timer callbacks and enforced strict `timer?.cancel()` invocation within `dispose()`.
- **Status**: FIXED & VERIFIED

---

### Bug #3: SetState Called During Build Phase Error
- **Category**: Flutter Widget Lifecycle
- **Symptom**: Console exception: `setState() or markNeedsBuild() called during build` on initial screen transition.
- **Root Cause**: High score loading logic triggered synchronous UI rebuilds before the first frame completed rendering.
- **Fix Implemented**: Wrapped highscore initialization inside `WidgetsBinding.instance.addPostFrameCallback((_) { ... });`.
- **Status**: FIXED & VERIFIED

---

### Bug #4: Garbage Collection Lag Stutter from Entity Allocations
- **Category**: Optimization / GC Performance
- **Symptom**: Noticeable micro-stutters (15-30ms frame drops) during continuous rapid projectile firing on mobile hardware.
- **Root Cause**: Dynamic instantiation of short-lived `Projectile` and `PathNode` objects during each update tick triggered frequent GC passes.
- **Fix Implemented**: Architected `ProjectilePool` with a fixed pre-allocated buffer of 30 reusable instances. Projectiles are recycled upon collision or boundary exit, eliminating runtime heap allocations.
- **Status**: FIXED & VERIFIED

---

### Bug #5: Async Race Condition on Highscore Storage Persistence
- **Category**: Storage / Data Integrity
- **Symptom**: Rapid successive score increments occasionally failed to write to local storage, resulting in lost high scores.
- **Root Cause**: Multiple asynchronous calls to `SharedPreferences` executed concurrently without thread synchronization.
- **Fix Implemented**: Encapsulated `StorageService` methods with synchronized atomic operations and an in-memory cache sync fallback.
- **Status**: FIXED & VERIFIED
