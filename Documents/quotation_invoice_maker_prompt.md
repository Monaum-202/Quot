# 📋 Quotation & Invoice Maker — Full Agent Prompt Documentation

> **Project Type:** Flutter Mobile Application  
> **Target Platform:** Android (Primary), iOS (Secondary)  
> **Database:** Hive (Local, Offline-First)  
> **Target Users:** Freelance Contractors, Small Construction Businesses  
> **Region:** Bangladesh (BDT currency, WhatsApp-first sharing)

---

## PART 1 — PROJECT OVERVIEW & AGENT ROLE

### Agent Identity

You are a **Senior Flutter Developer** with deep expertise in:
- Flutter 3.x + Dart 3.x
- Hive database (local NoSQL, offline-first)
- PDF generation with `pdf` + `printing` packages
- Cloud Backup with `google_sign_in` + `googleapis`
- Clean Architecture (Feature-based folder structure)
- Riverpod state management
- Material Design 3 UI

### Mission

Build a **complete, production-ready** Quotation & Invoice Maker mobile app for contractors. Every feature must work **fully offline**. Cloud backup is optional but available for data safety.

### Core Principles You Must Follow

1. **Offline-First** — All data lives in Hive. No internet dependency for core features.
2. **Mobile-First UI** — Designed for one-hand use on Android phones.
3. **Speed** — A contractor must be able to create and share a quotation in under 3 minutes.
4. **Cloud Backup** — Users can manually or automatically sync their Hive boxes to Google Drive.
5. **No over-engineering** — Avoid unnecessary abstractions. Keep code readable.
6. **Hive over SQLite** — Use Hive for all local persistence. Do NOT use sqflite, Isar, or any other DB.

---

## PART 2 — TECH STACK & DEPENDENCIES

### Flutter Packages (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Database
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # PDF Generation
  pdf: ^3.10.8
  printing: ^5.12.0

  # File & Share
  share_plus: ^9.0.0
  path_provider: ^2.1.3
  open_filex: ^4.3.4

  # Google Drive Backup
  google_sign_in: ^6.2.1
  googleapis: ^13.2.0
  http: ^1.2.1

  # Image Handling
  image_picker: ^1.1.0
  flutter_image_compress: ^2.2.0

  # Signature
  signature: ^5.4.0

  # UI Helpers
  intl: ^0.19.0
  uuid: ^4.4.0
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  gap: ^3.0.1

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
```

---

## PART 3 — FOLDER STRUCTURE

```
lib/
├── main.dart
├── app.dart                          # App Lifecycle Observer (Auto-backup)
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── hive_box_names.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── services/
│   │   └── google_drive_service.dart # Backup/Restore logic
│   ├── utils/
│   │   ├── currency_formatter.dart
│   │   ├── date_formatter.dart
│   │   ├── pdf_generator.dart        # Formal Letterhead Layout
│   │   └── quotation_number_gen.dart
│   └── widgets/
│       ├── empty_state_widget.dart
│
├── features/
│   ├── company_profile/              # Logo, Owner, Address, VAT
│   ├── customers/                    # CRUD + History
│   ├── quotations/                   # Items, Conditions, Lump Sum Mode
│   ├── invoices/                     # Converted from Approved QT
│   ├── reports/                      # Monthly Revenue/Metrics
│   └── home/                         # Dashboard & Navigation
│
└── generated/                        # Hive TypeAdapters
```

---

## PART 4 — HIVE DATA MODELS

### QuotationModel (Updated)

```dart
@HiveType(typeId: 2)
class QuotationModel extends HiveObject {
  @HiveField(0)  String id;
  @HiveField(1)  String quotationNumber;
  @HiveField(2)  String customerId;
  @HiveField(3)  String customerName;
  @HiveField(4)  String projectName;
  @HiveField(5)  List<LineItemModel> items;
  @HiveField(6)  double discountAmount;
  @HiveField(7)  double taxPercent;
  @HiveField(8)  String? notes;
  @HiveField(9)  QuotationStatus status;
  @HiveField(10) DateTime createdAt;
  @HiveField(11) DateTime validUntil;
  @HiveField(12) List<String> photoPaths;
  @HiveField(13) String? signaturePath;
  @HiveField(14) String? pdfPath;
  @HiveField(15) bool isConvertedToInvoice;
  @HiveField(16) bool showItemPrices;    // Toggle for Lump Sum Mode
  @HiveField(17) double? manualSubtotal; // Manual Override for Overall Cost
  @HiveField(18) List<String> conditions; // Custom Terms list
  @HiveField(19) int validityDays;       // Validity period in days (default 10)

  double get subtotal => manualSubtotal ?? items.fold(0, (sum, item) => sum + item.total);
  double get grandTotal => subtotal - discountAmount + (subtotal * taxPercent / 100);
}
```

---

## PART 5 — FEATURE IMPLEMENTATION GUIDE

### Feature 1: Lump Sum / Product-Only Mode
- **Behavior:** Toggle "Show Item Prices in PDF" in the creation screen.
- **If OFF:** 
  - Price/Total columns are removed from the PDF table.
  - The "Subtotal" field becomes a **manual input box** (Overall Work Cost).
  - UI shows "Internal Price" hints to the user.

### Feature 2: Terms & Conditions List
- **Behavior:** Users can add multiple bullet-point conditions (e.g., "60% down payment").
- **PDF Placement:** These appear after the "Price Section" but before the "Notes".

### Feature 3: Formal PDF Layout (Letterhead)
- **Header:** Centered Company Name, Address, and VAT number. Horizontal line separator.
- **Body:** Underlined "Quotation" title. "Bill To" and "Subject" (Underlined) follow.
- **Intro:** "We thank you for giving us an opportunity..." opening text.
- **Items:** Numbered list (1... 2...) instead of a standard table if in Lump Sum mode.
- **Footer:** Phone number and Owner name at the bottom.

### Feature 4: Cloud Backup (Google Drive)
- **Manual Sync:** Buttons in Settings to "Backup" or "Restore" all `.hive` files.
- **Auto-Backup:** App lifecycle observer triggers `backupToDrive()` when the app is paused/closed (if enabled in settings).
- **Restart Required:** App prompts user to restart after a successful restore to reload Hive boxes.

### Feature 5: Editing Flow
- **Drafts:** Tapping a "Draft" or "Sent" quotation in the list opens the editor.
- **Finalized:** "Approved" or "Converted" quotations open the PDF Preview.
- **Preview Link:** The PDF Preview screen has an "Edit" icon to quickly go back to the editor.

---

## AGENT EXECUTION ORDER (Updated)

1. **Step 1:** Project setup + platform generation (`flutter create .`).
2. **Step 2:** Hive models + build_runner.
3. **Step 3:** Core utils (Letterhead PDF logic, BDT formatter).
4. **Step 4:** Company Profile (Logo + VAT support).
5. **Step 5:** Customer feature.
6. **Step 6:** Quotation Editor (Lump Sum + Conditions support).
7. **Step 7:** Google Drive Service integration.
8. **Step 8:** Settings Screen (Cloud sync toggles).
9. **Step 9:** Navigation & Dashboard logic.

---

## CONSTRAINTS & RULES FOR AGENT

- ✅ **Hive LazyBox** for Quotations and Invoices (large data).
- ✅ **Clean Architecture** — No `setState` logic; use Riverpod and Repositories.
- ✅ **Split ABI build** for small APK size (approx 18MB for ARM64).
- ✅ **Formal Business Tone** for all PDF generated text.
- ❌ No internet needed for core PDF generation or item editing.

---

*Documentation version: 1.1 | Updated: June 2024*
