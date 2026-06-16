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
- Clean Architecture (Feature-based folder structure)
- Riverpod state management
- Material Design 3 UI

### Mission

Build a **complete, production-ready** Quotation & Invoice Maker mobile app for contractors. Every feature must work **fully offline**. Internet is only needed for WhatsApp/Email sharing.

### Core Principles You Must Follow

1. **Offline-First** — All data lives in Hive. No internet dependency for core features.
2. **Mobile-First UI** — Designed for one-hand use on Android phones.
3. **Speed** — A contractor must be able to create and share a quotation in under 3 minutes.
4. **No over-engineering** — Avoid unnecessary abstractions. Keep code readable.
5. **Hive over SQLite** — Use Hive for all local persistence. Do NOT use sqflite, Isar, or any other DB.

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

### Why Hive?

| Reason | Detail |
|--------|--------|
| **Pure Dart** | No native dependencies, works on all platforms |
| **Blazing fast** | Key-value store, faster than SQLite for read-heavy apps |
| **No schema migration headaches** | Just update the TypeAdapter |
| **Typed adapters** | `@HiveType` annotations give compile-time safety |
| **Lazy loading** | `LazyBox` for large datasets like quotation history |

---

## PART 3 — FOLDER STRUCTURE

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, theme, router
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── hive_box_names.dart       # All box name constants
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── currency_formatter.dart   # BDT formatting
│   │   ├── date_formatter.dart
│   │   ├── pdf_generator.dart        # Central PDF logic
│   │   └── quotation_number_gen.dart # Auto QT-2024-001
│   └── widgets/
│       ├── app_button.dart
│       ├── app_text_field.dart
│       └── empty_state_widget.dart
│
├── features/
│   │
│   ├── company_profile/
│   │   ├── data/
│   │   │   ├── models/company_model.dart         # @HiveType(typeId: 0)
│   │   │   └── repositories/company_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/company_profile_screen.dart
│   │   │   └── widgets/logo_picker_widget.dart
│   │   └── providers/company_provider.dart
│   │
│   ├── customers/
│   │   ├── data/
│   │   │   ├── models/customer_model.dart         # @HiveType(typeId: 1)
│   │   │   └── repositories/customer_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── customer_list_screen.dart
│   │   │   │   └── customer_detail_screen.dart
│   │   │   └── widgets/customer_card.dart
│   │   └── providers/customer_provider.dart
│   │
│   ├── quotations/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── quotation_model.dart           # @HiveType(typeId: 2)
│   │   │   │   └── line_item_model.dart           # @HiveType(typeId: 3)
│   │   │   └── repositories/quotation_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── quotation_list_screen.dart
│   │   │   │   ├── create_quotation_screen.dart
│   │   │   │   └── quotation_preview_screen.dart
│   │   │   └── widgets/
│   │   │       ├── line_item_row.dart
│   │   │       ├── totals_section.dart
│   │   │       └── status_badge.dart
│   │   └── providers/quotation_provider.dart
│   │
│   ├── templates/
│   │   ├── data/
│   │   │   ├── models/template_model.dart         # @HiveType(typeId: 4)
│   │   │   └── repositories/template_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/template_list_screen.dart
│   │   │   └── widgets/template_card.dart
│   │   └── providers/template_provider.dart
│   │
│   ├── invoices/
│   │   ├── data/
│   │   │   ├── models/invoice_model.dart          # @HiveType(typeId: 5)
│   │   │   └── repositories/invoice_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── invoice_list_screen.dart
│   │   │   │   └── invoice_preview_screen.dart
│   │   └── providers/invoice_provider.dart
│   │
│   └── reports/
│       ├── presentation/
│       │   └── screens/reports_screen.dart
│       └── providers/reports_provider.dart
│
└── generated/                        # Hive TypeAdapters (build_runner output)
    ├── company_model.g.dart
    ├── customer_model.g.dart
    ├── quotation_model.g.dart
    └── ...
```

---

## PART 4 — HIVE DATA MODELS

### Hive Box Names (hive_box_names.dart)

```dart
class HiveBoxNames {
  static const String company     = 'company_box';
  static const String customers   = 'customers_box';
  static const String quotations  = 'quotations_box';
  static const String invoices    = 'invoices_box';
  static const String templates   = 'templates_box';
  static const String settings    = 'settings_box';
}
```

### Box Initialization (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register all adapters BEFORE opening boxes
  Hive.registerAdapter(CompanyModelAdapter());
  Hive.registerAdapter(CustomerModelAdapter());
  Hive.registerAdapter(QuotationModelAdapter());
  Hive.registerAdapter(LineItemModelAdapter());
  Hive.registerAdapter(InvoiceModelAdapter());
  Hive.registerAdapter(TemplateModelAdapter());
  Hive.registerAdapter(QuotationStatusAdapter());

  // Open all boxes
  await Hive.openBox<CompanyModel>(HiveBoxNames.company);
  await Hive.openBox<CustomerModel>(HiveBoxNames.customers);
  await Hive.openLazyBox<QuotationModel>(HiveBoxNames.quotations); // Lazy for large data
  await Hive.openLazyBox<InvoiceModel>(HiveBoxNames.invoices);
  await Hive.openBox<TemplateModel>(HiveBoxNames.templates);
  await Hive.openBox(HiveBoxNames.settings);

  runApp(ProviderScope(child: MyApp()));
}
```

### Model Definitions

#### CompanyModel (typeId: 0)

```dart
@HiveType(typeId: 0)
class CompanyModel extends HiveObject {
  @HiveField(0) String name;
  @HiveField(1) String ownerName;
  @HiveField(2) String phone;
  @HiveField(3) String address;
  @HiveField(4) String? email;
  @HiveField(5) String? logoPath;       // Local file path after picking
  @HiveField(6) String? signaturePath;  // Local file path after signature pad
  @HiveField(7) String? taxNumber;
  @HiveField(8) String currency;        // Default: 'BDT'
}
```

#### CustomerModel (typeId: 1)

```dart
@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0) String id;             // UUID
  @HiveField(1) String name;
  @HiveField(2) String phone;
  @HiveField(3) String address;
  @HiveField(4) String? email;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) List<String> quotationIds; // References to quotation IDs
}
```

#### LineItemModel (typeId: 3)

```dart
@HiveType(typeId: 3)
class LineItemModel {
  @HiveField(0) String description;
  @HiveField(1) double quantity;
  @HiveField(2) String unit;            // 'sqft', 'job', 'pcs', 'rft', etc.
  @HiveField(3) double unitPrice;
  @HiveField(4) double get total => quantity * unitPrice;
}
```

#### QuotationModel (typeId: 2)

```dart
@HiveType(typeId: 2)
class QuotationModel extends HiveObject {
  @HiveField(0)  String id;                    // UUID
  @HiveField(1)  String quotationNumber;       // QT-2024-001
  @HiveField(2)  String customerId;
  @HiveField(3)  String customerName;          // Denormalized for speed
  @HiveField(4)  String projectName;
  @HiveField(5)  List<LineItemModel> items;
  @HiveField(6)  double discountAmount;
  @HiveField(7)  double taxPercent;
  @HiveField(8)  String? notes;
  @HiveField(9)  QuotationStatus status;
  @HiveField(10) DateTime createdAt;
  @HiveField(11) DateTime validUntil;
  @HiveField(12) List<String> photoPaths;      // Attached site/material photos
  @HiveField(13) String? signaturePath;        // Customer signature
  @HiveField(14) String? pdfPath;              // Cached PDF path
  @HiveField(15) bool isConvertedToInvoice;

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get grandTotal => subtotal - discountAmount + (subtotal * taxPercent / 100);
}
```

#### QuotationStatus Enum (typeId: 6)

```dart
@HiveType(typeId: 6)
enum QuotationStatus {
  @HiveField(0) draft,
  @HiveField(1) sent,
  @HiveField(2) approved,
  @HiveField(3) rejected,
  @HiveField(4) convertedToInvoice,
}
```

#### TemplateModel (typeId: 4)

```dart
@HiveType(typeId: 4)
class TemplateModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String name;            // "House Construction", "Electrical Work"
  @HiveField(2) String? description;
  @HiveField(3) List<LineItemModel> defaultItems;
  @HiveField(4) DateTime createdAt;
}
```

#### InvoiceModel (typeId: 5)

```dart
@HiveType(typeId: 5)
class InvoiceModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String invoiceNumber;     // INV-2024-001
  @HiveField(2) String quotationId;       // Source quotation
  @HiveField(3) String customerId;
  @HiveField(4) String customerName;
  @HiveField(5) String projectName;
  @HiveField(6) List<LineItemModel> items;
  @HiveField(7) double discountAmount;
  @HiveField(8) double taxPercent;
  @HiveField(9) double paidAmount;        // For partial payments
  @HiveField(10) DateTime issuedAt;
  @HiveField(11) DateTime dueDate;
  @HiveField(12) String? notes;
  @HiveField(13) String? pdfPath;

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get grandTotal => subtotal - discountAmount + (subtotal * taxPercent / 100);
  double get balanceDue => grandTotal - paidAmount;
}
```

---

## PART 5 — FEATURE IMPLEMENTATION GUIDE

### Feature 1: Company Profile

**Screen:** `CompanyProfileScreen`

**Behavior:**
- Only ONE company profile exists (use key `'company'` in Hive box)
- Logo picker → compress to max 200KB → save to app documents dir
- Signature pad → save as PNG → save to app documents dir
- Show setup wizard on first launch if profile is empty

**Repository Pattern:**
```dart
class CompanyRepository {
  final Box<CompanyModel> _box = Hive.box(HiveBoxNames.company);

  CompanyModel? get company => _box.get('company');

  Future<void> saveCompany(CompanyModel model) async {
    await _box.put('company', model);
  }
}
```

---

### Feature 2: Customer Management

**Screens:** `CustomerListScreen`, `CustomerDetailScreen`

**Behavior:**
- List with search bar (filter by name/phone)
- Tap customer → see all their quotations history
- Add/Edit customer inline (bottom sheet, not new screen)
- Delete customer → warn if they have active quotations

**Key UI:** `ValueListenableBuilder` on Hive box for real-time updates:
```dart
ValueListenableBuilder(
  valueListenable: Hive.box<CustomerModel>(HiveBoxNames.customers).listenable(),
  builder: (context, box, _) {
    final customers = box.values.toList();
    // render list
  },
)
```

---

### Feature 3: Create Quotation

**Screen:** `CreateQuotationScreen`

**Form Sections (in order):**
1. Customer selector (search + select or create new inline)
2. Project name text field
3. Valid until date picker
4. Line items list (add/remove/reorder rows)
5. Discount field
6. Tax % field
7. Notes field (optional)
8. Attach photos button
9. Save as Draft / Preview buttons

**Line Item Row Widget:**
```
[ Description field ] [ Qty ] [ Unit dropdown ] [ Price ] [ Total ] [ Delete ]
```

**Unit Options:** sqft, rft, job, pcs, kg, bag, day, hour, ls (lump sum)

**Auto Quotation Number:**
```dart
String generateQuotationNumber() {
  final box = Hive.box(HiveBoxNames.settings);
  int counter = box.get('qt_counter', defaultValue: 0) + 1;
  box.put('qt_counter', counter);
  final year = DateTime.now().year;
  return 'QT-$year-${counter.toString().padLeft(3, '0')}';
}
```

**Template Loading:**
- "Load Template" button opens bottom sheet
- Select template → pre-fill line items
- User can then modify before saving

---

### Feature 4: PDF Generation

**File:** `core/utils/pdf_generator.dart`

**PDF Layout (top to bottom):**
```
┌─────────────────────────────────────────┐
│ [LOGO]    Company Name                  │
│           Address | Phone | Email       │
├─────────────────────────────────────────┤
│ QUOTATION                  QT-2024-001  │
│ Date: 01 Jan 2024    Valid Until: ...   │
├─────────────────────────────────────────┤
│ Bill To:                                │
│ Customer Name                           │
│ Address | Phone                         │
├─────────────────────────────────────────┤
│ Project: Office Renovation              │
├─────────────────────────────────────────┤
│ # │ Description    │ Qty │ Unit │ Total │
│ 1 │ Painting Work  │1000 │sqft  │  ৳500 │
│ 2 │ Electrical     │   1 │ job  │  ৳300 │
├─────────────────────────────────────────┤
│                       Subtotal:  ৳800   │
│                       Discount:  ৳50    │
│                       Tax (5%):  ৳37.5  │
│                    Grand Total:  ৳787.5 │
├─────────────────────────────────────────┤
│ Notes: Payment due within 7 days        │
├─────────────────────────────────────────┤
│ [Site Photos if any - 2 per row]        │
├─────────────────────────────────────────┤
│ Customer Signature:  Contractor Sign:   │
│ [signature image]    [signature image]  │
└─────────────────────────────────────────┘
```

**Image Compression Before PDF:**
```dart
Future<Uint8List> compressForPdf(String imagePath) async {
  final compressed = await FlutterImageCompress.compressWithFile(
    imagePath,
    quality: 60,
    minWidth: 800,
    minHeight: 600,
  );
  return compressed!;
}
```

**Share Flow:**
```dart
Future<void> shareQuotationPdf(QuotationModel q) async {
  final pdf = await PdfGenerator.generate(q);
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/${q.quotationNumber}.pdf');
  await file.writeAsBytes(await pdf.save());

  // Update cached path in Hive
  q.pdfPath = file.path;
  await q.save();

  // Share via WhatsApp / any app
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Quotation ${q.quotationNumber} from ${companyName}',
  );
}
```

---

### Feature 5: Templates

**Screen:** `TemplateListScreen`

**Preloaded Templates (seed on first launch):**

| Template Name | Default Line Items |
|--------------|-------------------|
| House Construction | Foundation Work, Brickwork, Plaster, Roofing |
| Electrical Installation | Wiring, DB Board, Light Points, Fan Points |
| Plumbing Work | Water Supply Line, Drainage, Fixtures |
| Interior Design | False Ceiling, Wall Painting, Flooring, Furniture |
| Painting Work | Wall Preparation, Primer, 2 Coats Paint |

**Seed Logic (run once):**
```dart
Future<void> seedTemplatesIfEmpty() async {
  final box = Hive.box<TemplateModel>(HiveBoxNames.templates);
  if (box.isEmpty) {
    // insert default templates
  }
}
```

**One-Click Generate:**
- Select template → opens `CreateQuotationScreen` with pre-filled items
- All fields still editable

---

### Feature 6: Status Tracking

**Status Flow:**
```
Draft → Sent → Approved → Converted to Invoice
              ↘ Rejected
```

**UI:** Color-coded badge on quotation card:

| Status | Color |
|--------|-------|
| Draft | Grey |
| Sent | Blue |
| Approved | Green |
| Rejected | Red |
| Converted | Purple |

**Status Update:** Long press on quotation card → bottom sheet with status options.

---

### Feature 7: Digital Signature

**Package:** `signature: ^5.4.0`

**Screen Flow:**
1. In quotation preview → tap "Get Customer Signature"
2. Full-screen signature pad opens
3. Customer signs with finger
4. Tap "Confirm" → save PNG to app documents
5. Path saved in `QuotationModel.signaturePath`
6. Signature appears in PDF

```dart
SignatureController _controller = SignatureController(
  penStrokeWidth: 3,
  penColor: Colors.black,
  exportBackgroundColor: Colors.white,
);

// On confirm:
final image = await _controller.toPngBytes();
final file = File('${docDir.path}/sig_${quotation.id}.png');
await file.writeAsBytes(image!);
```

---

### Feature 8: Reports Dashboard

**Screen:** `ReportsScreen`

**Metrics to Show:**

```
This Month
┌──────────┬──────────┬──────────┬──────────┐
│  Total   │ Approved │ Pending  │ Revenue  │
│    12    │    7     │    3     │ ৳45,000  │
└──────────┴──────────┴──────────┴──────────┘

Status Breakdown (simple bar or pie)
Recent Activity (last 5 quotations)
```

**Computation (no SQL, pure Dart):**
```dart
// Get all quotations from lazy box
Future<List<QuotationModel>> getThisMonthQuotations() async {
  final box = Hive.lazyBox<QuotationModel>(HiveBoxNames.quotations);
  final now = DateTime.now();
  final results = <QuotationModel>[];

  for (final key in box.keys) {
    final q = await box.get(key);
    if (q != null &&
        q.createdAt.month == now.month &&
        q.createdAt.year == now.year) {
      results.add(q);
    }
  }
  return results;
}
```

---

## PART 6 — UI/UX GUIDELINES & NAVIGATION

### Navigation Structure

```
BottomNavigationBar (4 tabs):
├── 🏠 Home / Dashboard
├── 📄 Quotations
├── 👥 Customers
└── ⚙️  Settings
```

**FAB:** On Quotations tab → "+" → Create New Quotation

### Color Scheme

```dart
// app_colors.dart
class AppColors {
  static const primary     = Color(0xFF1565C0); // Deep Blue
  static const secondary   = Color(0xFF00897B); // Teal
  static const success     = Color(0xFF2E7D32); // Green
  static const warning     = Color(0xFFF57F17); // Amber
  static const error       = Color(0xFFC62828); // Red
  static const background  = Color(0xFFF5F5F5);
  static const surface     = Color(0xFFFFFFFF);
  static const onPrimary   = Color(0xFFFFFFFF);
}
```

### Critical UX Rules

1. **No internet required** for any core action — show no loading spinners for local data.
2. **Hive `listenable()`** for real-time list updates — no manual `setState` refresh.
3. **Confirm before delete** — always show `AlertDialog` with undo option (30s).
4. **Currency format** — always display as `৳1,000.00` using `intl` package.
5. **Empty states** — every list screen must have an illustration + CTA when empty.
6. **Form validation** — inline errors, not popup alerts.
7. **PDF preview** before sharing — show `PdfPreview` widget from `printing` package.

### Responsive Line Item Table

On small screens (< 360px width), collapse line item row to 2 lines:
```
Line 1: [Description                    ] [Delete]
Line 2: [Qty] [Unit ▾] × [Price] = [Total]
```

---

## AGENT EXECUTION ORDER

When building this app, follow this exact sequence:

```
Step 1: Project setup + pubspec.yaml
Step 2: Hive models + TypeAdapters (run build_runner)
Step 3: Hive initialization in main.dart
Step 4: Core utils (currency formatter, date formatter, quotation number gen)
Step 5: Company Profile feature (needed by PDF)
Step 6: Customer feature
Step 7: Templates feature + seed data
Step 8: Create Quotation feature (depends on Customers + Templates)
Step 9: PDF Generator
Step 10: Quotation Preview + Share flow
Step 11: Status tracking
Step 12: Digital Signature
Step 13: Convert to Invoice feature
Step 14: Reports screen
Step 15: Polish: empty states, error handling, first-launch wizard
```

---

## CONSTRAINTS & RULES FOR AGENT

- ✅ Use **Hive only** — no SQLite, no Isar, no Firebase
- ✅ Use **Riverpod** for state management — no Provider, no BLoC, no GetX
- ✅ Use **`pdf` package** for PDF — not `flutter_html_to_pdf`
- ✅ All monetary values stored as `double` in Hive, displayed formatted
- ✅ All IDs are `UUID v4` strings — not auto-increment integers
- ✅ Images compressed before storing path or embedding in PDF
- ❌ No internet calls for core features
- ❌ No `print()` statements in production code — use `debugPrint()` only in dev
- ❌ No hardcoded strings — use `app_strings.dart` constants
- ❌ Do not use `setState` in screens — use Riverpod providers only

---

*Documentation version: 1.0 | Last updated: 2024*
