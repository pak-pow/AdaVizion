---
date: 2026-03-16
project: AdaVizion (EUventure)
topic: QR Integration & Sequential Dialog Logic
dev: Dequito
Tags:
  - "[[Flutter]]"
  - "[[Dart]]"
  - "[[Mobile Scanner]]"
  - "[[Asynchronous Programming]]"
  - "[[Dev Log]]"
  - "[[State Management]]"
---

# 📝 DEV LOG: WEEK 1 - DAY 3

**Core Objective:** Implement a functional QR scanning module using the `mobile_scanner` package. Develop a sequential post-scan interaction flow that utilizes asynchronous dialogs to handle user decision-making (viewing "Fun Facts" vs. returning to the dashboard).

## 1. The Initiative & Context

With the initial `DashboardScreen` architecture implemented, the next phase involved activating the center-docked Floating Action Button. The goal was to transition from the static UI to a live camera interface capable of processing real-world data.

The technical challenge for Day 3 was managing the "Post-Scan State." A standard scanner often immediately triggers an action, but for EUventure, we required a "Decision Gate"—a moment where the user acknowledges the scan and chooses their next path without losing the context of the application.

## 2. Scanning Mechanics & Implementation

### Component: The (`QRCodeScreen`)

- **External Integration:** Integrated the `mobile_scanner` package to leverage hardware-accelerated QR detection.
- **Hardware Control:** Implemented a `MobileScannerController` to gain granular control over the camera lifecycle.
- **The "Double-Scan" Prevention:** A critical issue with live camera feeds is "rapid firing," where the scanner detects the same QR code multiple times per second, triggering overlapping logic.
- **Resolution:** Introduced a `bool isScanning` flag and called `cameraController.stop()` immediately upon the first valid detection. This "freezes" the feed, providing a stable UI environment for the subsequent dialogs.

```dart
onDetect: (capture) {
  if (isScanning) {
    final barcode = capture.barcodes.first;
    if (barcode.rawValue != null) {
      setState(() => isScanning = false);
      cameraController.stop();
      _showOptionsDialog(barcode.rawValue!);
    }
  }
}
```

## 3. Barebones UI/UX Architecture: Sequential Asynchronous Dialogs

### The "Decision Gate" Logic

- **Challenge:** Creating a smooth transition between scanning, viewing a "Fun Fact," and returning to the dashboard without the app feeling "jumpy" or glitchy.

- **Execution:** Utilized a nested `showDialog` approach. Instead of navigating to a new screen for facts, the information is presented as a high-priority `AlertDialog` styled with the project's design system.

### Asynchronous Flow Control (`async/await`)

To prevent the common Flutter "Navigator collision" (where multiple screens pop or push simultaneously), I implemented an asynchronous sequence in the "View Fun Facts" button:

1. **Step 1:** `Navigator.pop(context)` — Closes the initial "Options" menu.

2. **Step 2:** `await showDialog(...)` — Opens the Fun Facts popup and stalls the code execution. The app waits here until the user dismisses the fact.

3. **Step 3:** `Navigator.pop(context)` — Once the fact is dismissed, the logic resumes and pops the `QRCodeScreen`, returning the user to the `Dashboard`.

## 4. The Output & Result

Day 3 successfully bridges the gap between the physical environment and the digital interface. The QR module is not only functional but architected to be user-friendly, preventing accidental multiple scans and providing clear, branching pathways for the user post-interaction. The "Fun Facts" logic is now waiting to be linked to a backend database or a local content library.

![Day3.1](../screenshots/day3.1.png)

![Day3.2](../screenshots/day3.2.png)