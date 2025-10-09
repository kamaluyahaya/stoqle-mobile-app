import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:stoqle/component/colors/color.dart';

/// Stoqle — Multi-page Help Center
/// - Apple-like styling inspired by your existing EnterproseBusinessHelp example
/// - Vertical, big-numbered pages with large STOQLE watermark
/// - Contains 12 pages covering the entire app behaviour described by the user
///
/// Usage:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const StoqleHelpPages()));

class StoqleHelpPages extends StatefulWidget {
  const StoqleHelpPages({Key? key}) : super(key: key);

  @override
  State<StoqleHelpPages> createState() => _StoqleHelpPagesState();
}

class _StoqleHelpPagesState extends State<StoqleHelpPages> {
  final PageController _controller = PageController();
  int _index = 0;

  // Replace with your real support contact in international format
  static const String supportWhatsAppNumber = '+2348000000000';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPage({required int number, required Widget content}) {
    return Stack(
      children: [
        // Watermark
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.rotate(
                angle: -math.pi / 2,
                child: Text(
                  'STOQLE',
                  style: TextStyle(
                    fontSize: 120,
                    fontFamily: "Bold",
                    color: Colors.red.withOpacity(0.2),
                    letterSpacing: 6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 64,
                      fontFamily: "Bold",
                      color: Colors.red.withOpacity(0.09),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 4,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 20),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(90, 228, 228, 228),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // 01 — Overview
      _buildPage(
        number: 1,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Welcome to Stoqle',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Stoqle combines social features + eCommerce in a single product discovery and selling experience.\n\nUsers may login and immediately access the dashboard — we automatically register accounts on successful login so there is minimal friction to start exploring.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),

      // 02 — Auto-registration & Login options
      _buildPage(
        number: 2,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Login & Auto-registration',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Users can login with OTP or with password. If a user logs in successfully and does not already exist in the system, Stoqle will automatically create an account for them and redirect them to the dashboard.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(text: 'OTP-based quick access for fast onboarding.'),
            _BulletRow(
              text:
                  'Password login for returning users with full profile access.',
            ),
            _BulletRow(
              text:
                  'Auto-registration reduces signup friction and increases activation rates.',
            ),
          ],
        ),
      ),

      // 03 — Dashboard navigation
      _buildPage(
        number: 3,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'After login users land on the dashboard. The main navigation contains:\nHome, Market, Post, Messages and Profile — each area has focused functionality.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(text: 'Home: feed of posts and promotions.'),
            _BulletRow(text: 'Market: explore shops, categories and products.'),
            _BulletRow(
              text: 'Post: social posting (non-business accounts can post).',
            ),
            _BulletRow(
              text: 'Messages: customer & vendor chat, order updates.',
            ),
            _BulletRow(text: 'Profile: account, store settings and policies.'),
          ],
        ),
      ),

      // 04 — Social posting & order placement
      _buildPage(
        number: 4,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Social Posts & Buying',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'All users (including non-business accounts) can create social posts, view products and place orders directly from product pages. However only business accounts can create product listings and open a shop.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(
              text:
                  'Non-business account: can post socially and buy, but cannot open a shop.',
            ),
            _BulletRow(
              text:
                  'To request a store, go to Profile → Open Store and submit required documents.',
            ),
          ],
        ),
      ),

      // 05 — Business registration types
      _buildPage(
        number: 5,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Registering a Business',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Bold",
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Stoqle supports two store types: Individual and Enterprise. Each has different verification requirements and capabilities.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Individual Store',
                style: TextStyle(fontFamily: "Bold", color: Colors.black87),
              ),
              SizedBox(height: 8),
              _BulletRow(
                text: 'Onboard with NIN (National Identification Number).',
              ),
              _BulletRow(text: 'Quick verification and lightweight features.'),
              SizedBox(height: 12),
              Text('Enterprise Store', style: TextStyle(fontFamily: "Bold")),
              SizedBox(height: 8),
              _BulletRow(text: 'Requires CAC + authorized signatory ID (NIN).'),
              _BulletRow(
                text:
                    'Access to multi-location inventory, invoices and team roles.',
              ),
              SizedBox(height: 12),
              Text('Tip:', style: TextStyle(fontFamily: "Bold")),
              SizedBox(height: 8),
              Text(
                '- Choose Individual for fast starts; upgrade to Enterprise when you need advanced tools.',
              ),
            ],
          ),
        ),
      ),

      // 06 — Vendor payouts & payment receivers
      _buildPage(
        number: 6,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Vendor Payments & Payouts',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Vendors receive orders and can be paid via their bank account number, SOD (Store On Delivery) or instant options enabled on the platform. Ensure your payout details are correct to avoid delays.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(text: 'Add bank account in Profile → Payouts.'),
            _BulletRow(
              text:
                  'SOD / cash-on-delivery must be enabled per store settings.',
            ),
            _BulletRow(
              text:
                  'Platform supports scheduled and instant payout options (configurable).',
            ),
          ],
        ),
      ),

      // 07 — Store policies (shipping/payment/delivery/return)
      _buildPage(
        number: 7,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Business Policies',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Bold",
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Each vendor can configure their own: Shipping Policy, Payment Policy, Delivery Policy and Return & Refund Policy. These policies are shown on the store page and at checkout so customers are informed.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              _BulletRow(
                text: 'Shipping: zones, rates, carriers and estimated times.',
              ),
              _BulletRow(
                text:
                    'Payment: accepted methods, upfront payment rules, and invoice requirements.',
              ),
              _BulletRow(
                text: 'Delivery: SLA, recommended couriers and pickup options.',
              ),
              _BulletRow(
                text: 'Return & Refund: conditions, timelines and chargebacks.',
              ),
            ],
          ),
        ),
      ),

      // 08 — Explore shops & categories
      _buildPage(
        number: 8,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Explore Shops & Categories',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Users can browse shops by category, view product lists for each shop and filter by price, rating and delivery zone. Product pages show vendor policies and trusted partner badges when applicable.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(
              text: 'Category filters and search for quick discovery.',
            ),
            _BulletRow(
              text: 'Shop pages show products, policies and contact options.',
            ),
          ],
        ),
      ),

      // 09 — Trusted partners & guarantees
      _buildPage(
        number: 9,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Trusted Partners',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Trusted partners are merchants vetted by Stoqle. Purchases from trusted partners carry a 100% delivery guarantee as defined by platform terms. Trusted partner products display a badge on shop and product pages.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(
              text: 'Trusted badge appears on store and product listings.',
            ),
            _BulletRow(
              text:
                  'Guaranteed delivery: follow dispute flow if delivery fails.',
            ),
          ],
        ),
      ),

      // 10 — Following vendors & notifications
      _buildPage(
        number: 10,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Follow Vendors & Activity',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Users can follow and unfollow vendors. Following a vendor surfaces their posts and product drops in your Home feed and enables notifications for promotions and restocks.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(
              text: 'Follow to get product updates and sales in your feed.',
            ),
            _BulletRow(text: 'Unfollow anytime from the vendor profile.'),
          ],
        ),
      ),

      // 11 — Non-business account limitations & how to request a store
      _buildPage(
        number: 11,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Non-business Accounts',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Bold",
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Non-business accounts have a full social experience (posting, liking, commenting) and can place orders. They cannot create product listings or open a shop until they request a store and submit verification documents.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            _BulletRow(
              text:
                  'To request a store: Profile → Open Store → Choose Individual or Enterprise.',
            ),
            _BulletRow(
              text: 'Provide NIN for Individual; CAC + NIN for Enterprise.',
            ),
          ],
        ),
      ),

      // 12 — Support, disputes & FAQ
      _buildPage(
        number: 12,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support & FAQ',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Bold",
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Need help? Use the in-app chat for quick answers. For order disputes and refunds use the Order → Report Issue flow. You can also reach support on WhatsApp:',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // hook to open WhatsApp or copy number
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.phoneCall, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$supportWhatsAppNumber',
                          style: const TextStyle(
                            fontFamily: "Bold",
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                'Common Questions',
                style: TextStyle(fontFamily: "Bold", color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const _BulletRow(
                text:
                    'How long until I receive payout? — See Payouts in Profile.',
              ),
              const _BulletRow(
                text:
                    'How do I change my store policies? — Profile → Store Settings → Policies.',
              ),
              const _BulletRow(
                text:
                    'What if my product is not delivered? — Use the Report Issue flow for orders.',
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator to support or open store flow
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          'Contact Support',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: kBlack),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Stoqle — Help Center',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: "Bold",
            fontSize: 15,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (ctx, i) => pages[i],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 22.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Text(
                    '${_index + 1}/${pages.length}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _index == pages.length - 1
                        ? null
                        : () => _controller.nextPage(
                            duration: const Duration(milliseconds: 420),
                            curve: Curves.easeInOut,
                          ),
                    child: const Text('Scroll'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----- small helper widgets -----

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.check_circle, size: 18, color: Colors.red),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  final int index;
  final String text;
  const _NumberedStep({required this.index, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.kDarkMode,
                  fontFamily: "Bold",
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
