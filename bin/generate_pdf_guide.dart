import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final pdf = pw.Document();

  final primaryColor = PdfColor.fromHex('#059669'); // Deep Emerald Green
  final headerBgColor = PdfColor.fromHex('#F8FAFC'); // Soft Slate Background
  final bodyColor = PdfColor.fromHex('#334155'); // Dark Slate Text
  final subtitleColor = PdfColor.fromHex('#64748B');

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      header: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(bottom: 16),
        padding: const pw.EdgeInsets.only(bottom: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Sukli POS - Store Operating & Workflow Manual',
              style: pw.TextStyle(color: primaryColor, fontSize: 9.5, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Official Documentation',
              style: pw.TextStyle(color: subtitleColor, fontSize: 9.5),
            ),
          ],
        ),
      ),
      footer: (context) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 16),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.8)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Copyright (c) 2026 Sukli POS. All rights reserved.', style: pw.TextStyle(color: subtitleColor, fontSize: 9)),
            pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(color: subtitleColor, fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
      build: (pw.Context context) => [
        // Title Banner
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(22),
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Sukli POS',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Comprehensive Operating Manual & User Training Guide',
                style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#047857'),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'System Version 1.0.0 - Offline-First Architecture',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),

        // Intro Text
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: headerBgColor,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColor.fromHex('#CBD5E1')),
          ),
          child: pw.Text(
            'Welcome to Sukli POS! This manual provides thorough, step-by-step instructions for store administrators and cashiers. Follow these procedures to set up your store profile, manage menu inventory, create staff accounts, process sales transactions, connect thermal printers, and analyze sales reports.',
            style: pw.TextStyle(color: bodyColor, fontSize: 10.5, height: 1.45),
          ),
        ),
        pw.SizedBox(height: 20),

        // SECTION 1
        _buildSectionHeader('SECTION 1: INITIAL SETUP & ADMIN CONFIGURATION', primaryColor, headerBgColor),
        pw.SizedBox(height: 10),
        _buildStep(
          '1.1 Administrator Registration & Authentication',
          'Launch the Sukli POS app on your Android device. On the initial login screen, select "Administrator Login". If you are a new store owner, tap "Sign Up" to register your admin email and password. If you already have an account, enter your credentials to log into the Admin Dashboard.',
        ),
        _buildStep(
          '1.2 Store Profile Setup',
          'Navigate to Settings from the side navigation menu. Under the "Store Profile" card:\n'
          '  - Store Name: Enter your registered store or cafe name (e.g. Sukli Bistro & Cafe).\n'
          '  - Store Address: Enter your complete business address (e.g. 123 Main Street, Sampaloc, Manila).\n'
          '  - Contact Number: Enter your store contact phone number (e.g. +63 917 123 4567).\n'
          '  - Store Tagline: Enter a brand tagline or customer greeting (e.g. Freshly Brewed Every Day!).\n'
          '  - Tap the "Update Store Profile" button to save these details.',
        ),
        _buildStep(
          '1.3 Receipt Customization & Paper Layout',
          'Scroll down to the "Receipt Customization" section in Settings:\n'
          '  - Header & Footer Text: Customize the top title header and bottom thank-you message.\n'
          '  - Toggle Options: Turn on/off "Show Date & Time", "Show Cashier Name", and "Show Order Number".\n'
          '  - Printer Paper Size: Select "58mm Roll" for portable handheld printers or "80mm Roll" for desktop models.\n'
          '  - Auto-Cut: Enable "Auto-Cut Thermal Paper" if your printer has a hardware paper cutter.\n'
          '  - Tap "Save Receipt Layout" to commit your settings.',
        ),
        _buildStep(
          '1.4 Bluetooth Thermal Printer Pairing & Testing',
          'Turn on your Bluetooth thermal receipt printer and ensure Bluetooth is active on your mobile device:\n'
          '  1. In Settings, scroll to the "Bluetooth Printer" section and tap "Scan for Printers".\n'
          '  2. A modal bottom sheet will scan for nearby paired Bluetooth devices.\n'
          '  3. Tap your printer device name (e.g., PT-210, MPT-II, POS-5802) to connect.\n'
          '  4. Once connected, tap "Test Print" to verify alignment and output quality.',
        ),
        pw.SizedBox(height: 18),

        // SECTION 2
        _buildSectionHeader('SECTION 2: ACCOUNT CREATION (ADMIN & CASHIERS)', primaryColor, headerBgColor),
        pw.SizedBox(height: 10),
        _buildStep(
          '2.1 Managing Administrator Profile',
          'To update your Admin account information, open Settings -> "Admin Profile". Here you can update your Administrator Name and Email. You can also update your admin password under "Change Password" by entering your current password and confirming your new password.',
        ),
        _buildStep(
          '2.2 Creating Cashier User Accounts & 4-Digit PINs',
          'Cashiers use simplified 4-digit PIN logins for rapid shift switching during busy business hours:\n'
          '  1. Open User Management from the Admin Quick Links menu.\n'
          '  2. Tap "+ Add Cashier Account".\n'
          '  3. Enter the Cashier\'s full name (e.g. Juan Dela Cruz).\n'
          '  4. Assign a unique 4-digit security PIN (e.g. 1234).\n'
          '  5. Tap "Save Account". The new cashier can now log in immediately from the Cashier Login screen.',
        ),
        pw.SizedBox(height: 18),

        // SECTION 3
        _buildSectionHeader('SECTION 3: MENU CREATION & INVENTORY SETUP', primaryColor, headerBgColor),
        pw.SizedBox(height: 10),
        _buildStep(
          '3.1 Creating Product Categories',
          'Categories organize your product catalog for quick filtering on the cashier POS screen:\n'
          '  1. Open Menu Management -> tap the "Categories" tab.\n'
          '  2. Tap "+ Add Category" (e.g., Espresso Coffee, Cold Drinks, Pastries, Meals).\n'
          '  3. Choose a distinct visual color accent badge for easy cashier recognition and tap Save.',
        ),
        _buildStep(
          '3.2 Adding Products & Setting Inventory Stock',
          'Add items to your store catalog:\n'
          '  1. Open Menu Management -> tap the "Products" tab -> tap "+ Add Product".\n'
          '  2. Enter Item Name (e.g. Iced Latte), Base Price (e.g. P120.00), and Stock Quantity (e.g. 50).\n'
          '  3. Assign the product to its category.\n'
          '  4. Optionally upload a product image from your device gallery.',
        ),
        _buildStep(
          '3.3 Configuring Product Variants & Modifiers/Add-ons',
          'For items with options (sizes, milk types, extra shots):\n'
          '  - Product Variants: Under the product form, add size/serving choices (e.g., Small, Medium [+P15], Large [+P30]).\n'
          '  - Modifiers / Add-ons: Add optional extra ingredients (e.g., Oat Milk [+P20], Extra Espresso Shot [+P15], Less Ice).\n'
          '  - Tap "Save Product". These options will automatically pop up when a cashier taps the item.',
        ),
        pw.SizedBox(height: 18),

        // SECTION 4
        _buildSectionHeader('SECTION 4: CASHIER DAILY OPERATIONS & CHECKOUT', primaryColor, headerBgColor),
        pw.SizedBox(height: 10),
        _buildStep(
          '4.1 Cashier Login & Shift Start',
          'On the app launch screen, tap "Cashier Login". Select your Cashier Name or enter your 4-digit PIN. Once authenticated, you will enter the Cashier POS Screen with the catalog on the left and active Cart on the right.',
        ),
        _buildStep(
          '4.2 Taking Customer Orders & Adding Items to Cart',
          '1. Filter the catalog by tapping category tabs at the top (All, Coffee, Pastries, etc.).\n'
          '2. Tap any product tile to add it to the cart.\n'
          '3. If the product has variants or modifiers, a pop-up modal will appear. Select the customer\'s preferred size and add-ons, then tap "Add to Order".',
        ),
        _buildStep(
          '4.3 Cart Management',
          '  - Adjust Quantity: Use the + and - buttons on any cart row to change quantities.\n'
          '  - Remove Item: Swipe left or tap the trash icon to remove a row from the active order.\n'
          '  - Customer Name: Optionally enter the customer\'s name for order queue identification.',
        ),
        _buildStep(
          '4.4 Processing Checkout & Printing Receipts',
          '1. Tap the green "Checkout" button.\n'
          '2. Select Payment Method: Cash, GCash, or Maya.\n'
          '3. For Cash: Enter the amount tendered (e.g. P200.00). The app displays exact change (e.g. P38.00).\n'
          '4. Tap "Complete Transaction".\n'
          '5. The Payment Success Screen appears, displaying the order number (e.g. #0043) and automatically transmitting receipt data to your Bluetooth thermal printer.',
        ),
        pw.SizedBox(height: 18),

        // SECTION 5
        _buildSectionHeader('SECTION 5: ORDER HISTORY, CLOUD SYNC & ANALYTICS', primaryColor, headerBgColor),
        pw.SizedBox(height: 10),
        _buildStep(
          '5.1 Order History & Re-printing Receipts',
          'Open "Order History" from the navigation menu to view all past sales. You can search by order number or filter by date. Tap any transaction row to open the Order Details Sheet to inspect items, payment method, cashier name, or tap "Reprint Receipt" to issue a duplicate thermal receipt.',
        ),
        _buildStep(
          '5.2 Processing Item Voids & Order Refunds',
          'If a customer cancels or returns an order, open the order in Order History:\n'
          '  - Void Transaction: Requires Admin PIN approval. Marks order as Voided and restores product stock levels.\n'
          '  - Partial/Full Refund: Process refunds with supervisor authorization.',
        ),
        _buildStep(
          '5.3 Offline-First Operation & Automatic Cloud Sync',
          'Sukli POS is powered by Isar local database and runs 100% offline. All transactions are saved locally even without internet. When Wi-Fi/data is restored, the Supabase Sync Queue Manager automatically pushes queued transactions to the cloud in the background. Check the top bar indicator (Green = Synced, Orange = Offline Queue).',
        ),
        _buildStep(
          '5.4 Exporting Sales Reports & Analytics (Admin Only)',
          'Log in as Admin and open "Reports & Analytics":\n'
          '  1. Select custom date ranges (Today, Yesterday, This Week, This Month, or Custom Date).\n'
          '  2. Review visual sales metrics: Gross Revenue, Net Revenue, Payment Breakdown, and Top Selling Products.\n'
          '  3. Export Data: Tap "Export Excel" or "Export PDF". Excel reports include embedded pre-rendered chart visualizer sheets for business presentation.',
        ),
      ],
    ),
  );

  final targetDir = Directory('r:/Code/Sukli POS/sukli_pos/user_guide');
  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  final file = File('${targetDir.path}/Sukli_POS_User_Guide.pdf');
  await file.writeAsBytes(await pdf.save());

  final rootFile = File('r:/Code/Sukli POS/sukli_pos/Sukli_POS_User_Guide.pdf');
  await rootFile.writeAsBytes(await pdf.save());

  final artifactFile = File('C:/Users/allen/.gemini/antigravity/brain/8994d79d-fb9d-482b-82ce-055d5202d080/Sukli_POS_User_Guide.pdf');
  await artifactFile.writeAsBytes(await pdf.save());

  print('SUCCESS: Created PDF at ${file.path}');
}

pw.Widget _buildSectionHeader(String title, PdfColor accentColor, PdfColor bgColor) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(top: 10, bottom: 10),
    padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    decoration: pw.BoxDecoration(
      color: bgColor,
      borderRadius: pw.BorderRadius.circular(5),
      border: pw.Border(left: pw.BorderSide(color: accentColor, width: 4.5)),
    ),
    child: pw.Text(
      title,
      style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget _buildStep(String title, String description) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(color: PdfColor.fromHex('#0F172A'), fontSize: 11.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          description,
          style: pw.TextStyle(color: PdfColor.fromHex('#334155'), fontSize: 10, height: 1.45),
        ),
      ],
    ),
  );
}
