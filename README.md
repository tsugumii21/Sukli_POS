# Sukli POS
### Empowering Local SMBs with Decent Work and Economic Growth (SDG 8) through Digital Point-of-Sale
A modern, secure, and production-ready Offline-First Point-of-Sale (POS) System designed for Philippine Micro, Small, and Medium Enterprises (MSMEs) to manage transactions, track inventory, issue receipts, and sync sales data in real time.

**Flutter (Dart) | Isar Database | Supabase | PDF | Excel**

📋 Overview
Sukli POS is a robust, offline-first point-of-sale application tailored for local small businesses (e.g. Sari-Sari stores, local retail shops, eateries) in the Philippines. It serves as a unified platform for cashiers to process checkouts quickly using Cash or GCash, and for administrators to manage inventory, audit past transactions, track sales performance via reports, and export records to Excel and PDF formats. Utilizing Isar Database for local offline persistence, it ensures zero disruption during internet blackouts and syncs automatically with Supabase when connectivity is restored.

🌍 Sustainable Development Goal 8 (SDG 8) Alignment
Sukli POS directly supports UN Sustainable Development Goal 8: Decent Work and Economic Growth. By providing local micro and small businesses (MSMEs) with an easy-to-use, professional POS tool, it helps transition traditional manual operations into formal, digitized workflows. The offline-first architecture ensures that stores in remote areas with unstable internet connectivity can maintain continuous operations without losing sales records. Dynamic sales reporting and inventory insights help business owners reduce wastage, manage costs, and make informed financial decisions, promoting sustainable economic growth and local entrepreneurship.

🔄 User Flows

🛡️ Admin Flow
- **Login**: Admin logs in using secure administrator credentials.
- **Dashboard Overview**: Views aggregate KPI counts (Total Sales Today, Orders Today, Pending Sync items), and a scrollable Recent Activity panel displaying recent orders.
- **Recent Activity**: Visualizes transactions showing sequence numbers and cashier unique codes (e.g. `#0029-5FG6`).
- **Order History & Search**: Accesses the full Order History to search by order number, filter by date, payment method, or status (Completed, Voided, Refunded).
- **Reports & Analytics**: Generates dynamic report views and exports detailed sales records to Excel (complete with embedded Pie and Column charts) and PDF formats. Handles Scoped Storage fallback via native sharing on mobile devices.

🩺 Cashier Flow
- **Dashboard Checkout**: Cashier processes sales checkouts directly on the main POS dashboard.
- **Payment Options**: Allows cashiers to select payment methods (Cash, GCash) and calculates change (sukli) dynamically.
- **Recent Activity**: Cashiers see the recent order history on their dashboard displaying cashier sequence-only numbers (e.g., `#0029`) to keep the screen uncluttered.
- **Payment Success & Receipting**: Displays a success screen showing cashier sequence number and provides options for printing physical receipts or saving PDF copies.

🚀 Setup & Installation Instructions

Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Supabase Account and Setup
- Git

Local Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/tsugumii21/Sukli_POS.git
   cd Sukli_POS
   ```

2. **Configure Environment Variables**: Create a `.env` file in the root directory and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Get Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run Database Generator**: Apply code generation for Isar schemas and Riverpod providers:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **Run the Application**:
   ```bash
   flutter run
   ```

📦 Features Implemented
- 🛡️ **Admin Panel**: Real-time sales statistics, pending sync queue metrics, Supplier/Medicine/Item listings, and system audit tools.
- 📶 **Offline-First Architecture**: Double-entry safety with local Isar database. Background worker queues transactions and uploads to Supabase when network is restored.
- 📊 **Reports & Visual Charts**: Visual sales breakdowns and summaries.
- 📈 **Advanced Excel Exports**: Exports sales records and details to Excel sheets, automatically embedding interactive Pie charts (payment breakdown) and Column charts (cashier revenue breakdown) using Syncfusion.
- 📄 **PDF Export & System Sharing**: Standardized PDF report generation. Incorporates dynamic try-catch falling back to native share sheets when writing directly to system Downloads is blocked (Android 11+).
- 🔑 **Role-Based Access**: Secure cashiers and admin accounts, dividing management capability from daily sales checkouts.
