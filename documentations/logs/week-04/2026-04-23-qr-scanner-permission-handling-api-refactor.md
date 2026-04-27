| Field | Details |
| :--- | :--- |
| **Date** | 2026-04-23 |
| **Project** | EUventure |
| **Topic** | QR Code Scanner — Permission Handling, API Refactor & Code Cleanup |
| **Developer** | Dequito |
| **Tags** | `Flutter`, `Frontend`, `QR Code`, `mobile_scanner`, `State Management`, `UI Design`, `Dev Log` |

# DEV LOG: WEEK 4 - DAY 6

## Core Objective

Resolve all known issues logged in Week 4 Day 4: camera permission handling, scan window masking, backend API refactor to the new `/landmarks/visit` endpoint, and wiring the "View Landmark" stub. Also cleaned up the file for DRY and maintainability.

---

## 1. Camera Permission Handling

Added full camera permission state tracking with a dedicated UI for each state.

- **Permission state:** `_cameraPermissionGranted` is a nullable bool — `null` (pending), `true` (granted), `false` (denied). Each state maps to a distinct overlay in the `Stack`.
- **Pending state:** A full-screen black `ColoredBox` with a `CircularProgressIndicator` covers the camera layer while the browser permission popup is open, preventing a flash of raw camera output.
- **Denied state:** A `_buildPermissionDeniedUI()` overlay renders a `no_photography` icon, an explanation message, and a "Try Again" button. Covers the camera layer entirely via `StackFit.expand`.
- **`_onControllerStateChanged` listener:** Drives permission state from the controller's `isInitialized` and `error` fields for native (iOS/Android).
- **`_onScannerError` errorBuilder:** Handles the web-specific case where `NotAllowedError` surfaces as a widget-level exception rather than a controller state change. Intercepts the error, schedules a `setState` via `addPostFrameCallback`, and returns a `SizedBox.expand()` so MobileScanner's raw browser error string never renders.
- **Retry flow (`_retryPermission`):** Fully disposes and recreates both the `MobileScannerController` and the `MobileScanner` widget (via a new `UniqueKey`). This replicates the navigate-away-and-back behavior, re-invoking `getUserMedia` and re-triggering the browser permission popup.

---

## 2. Scan Window & Frame Overlay

Addressed the known issue where the scanner detected QR codes outside the visible frame box.

- **`scanWindow` rect:** Now passed to `MobileScanner` on native builds, restricting actual barcode detection to the visible frame area. Set to `null` on web since `mobile_scanner`'s web implementation does not honour `scanWindow`.
- **Web limitation:** On web (our primary deployment target), the scan frame is a visual guide only — the full camera frame is always scanned regardless. This is a `mobile_scanner` package constraint and is documented in the `_ScanOverlayPainter` class doc comment.
- **Native support:** The `scanWindow` rect is aligned with the `_ScanOverlayPainter`'s punched-out rectangle, so if the app is ever deployed natively, detection will be correctly restricted to the frame.

---

## 3. Backend API Refactor

Refactored `LandmarkApi` and `QRCodeScreen` to use the new `POST /landmarks/visit` endpoint, replacing the old sequential-try workaround.

- **Old flow:** `getChecklist()` was called on every scan to retrieve all landmark IDs, then `visitLandmark(id, qrCode)` was tried sequentially against each until one accepted — worst case one API call per landmark.
- **New flow:** A single `POST /landmarks/visit` call is made with the raw QR string. The backend now handles matching internally and returns the full reward payload on success.
- **`LandmarkApi.visitLandmark(qrCode)`:** Signature simplified — no longer requires a landmark ID. The raw scanned UUID is passed directly.
- **Error handling:** The backend returns distinct error responses for already-visited (`409`) and invalid QR (`403`) cases. `_onScanError` maps these to the appropriate dialog via string matching on the exception message.

---

## 4. "View Landmark" Stub

Wired a temporary navigation helper for the success dialog's "View Landmark" button.

- **`_navigateToLandmarkDetails(int landmarkId)`:** Calls `Navigator.pushNamed` to `/landmark_details` with the `landmarkId` as arguments.
- Marked with a `TODO` comment to reroute once the Landmark Details screen is fully implemented.

---

## 5. Code Cleanup (DRY & Maintainability)

Refactored `QRCodeScreen` to remove duplication across dialogs and controller lifecycle management.

- **`_showScanDialog`:** Single dialog builder replacing four near-identical `AlertDialog` definitions. Accepts `title`, optional `content`, and `actions`. All error dialogs now use this.
- **`_dialogButton`:** Unified button builder for dialog actions. Accepts `label`, `onPressed`, and an `isText` flag to toggle between `ElevatedButton` and `TextButton` styling.
- **`_closeDialogAnd`:** Helper that calls `Navigator.pop` then executes a provided callback — removes repeated pop + action boilerplate from every dialog button.
- **`_initController` / `_disposeController`:** Extracted controller wiring into dedicated helpers called by `initState`, `dispose`, and `_retryPermission`, eliminating duplicated listener registration/removal logic.
- **`_onScanError`:** Extracted error string matching out of `_handleScan` into its own method for clarity and easier extension.

---

## 6. Known Issues & To-Dos

| # | Issue | Priority |
| :--- | :--- | :--- |
| 1 | Scan frame is a visual guide only on web — `mobile_scanner` does not honour `scanWindow` in its web implementation. Full camera frame is always scanned. | Low — web deployment only, acceptable UX tradeoff |
| 2 | "View Landmark" navigates to `/landmark_details` stub. Needs final wiring once the Landmark Details screen is complete. | Low |
