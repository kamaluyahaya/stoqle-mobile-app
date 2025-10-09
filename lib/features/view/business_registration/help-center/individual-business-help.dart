import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../selection-page.dart';

class IndividualBusinessHelp extends StatefulWidget {
  const IndividualBusinessHelp({Key? key}) : super(key: key);

  @override
  State<IndividualBusinessHelp> createState() => _IndividualBusinessHelpState();
}

class _IndividualBusinessHelpState extends State<IndividualBusinessHelp> {
  final PageController _controller = PageController();
  int _index = 0;

  // Replace this with your real support number. Keep international format.
  // Example for Nigeria: +2348000000000
  static const String supportWhatsAppNumber = '+2348000000000';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final phone = supportWhatsAppNumber.replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/${phone.replaceFirst('+', '')}');
    // Launch code intentionally left commented so you can wire your preferred URL launcher.
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri, mode: LaunchMode.externalApplication);
    // }
  }

  Widget _buildPage({required int number, required Widget content}) {
    // big red watermark text
    return Stack(
      children: [
        // Watermark
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Transform.rotate(
                // angle: -1.5,
                angle: -math.pi / 2,
                child: Text(
                  'STOQLE',
                  style: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    color: Colors.red.withOpacity(0.09),
                    letterSpacing: 6,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big number column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
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

              // Card like content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(129, 255, 255, 255),
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
    final pages = [
      _buildPage(
        number: 1,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Stoqle Merchant',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            Text(
              'Stoqle Merchant is a complete commerce toolkit built for small and growing businesses.\n\n'
              'List products quickly, accept payments, manage inventory across multiple locations, and reach customers on web, social and marketplaces — all from one dashboard.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Key highlights:',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            _BulletRow(
              text: 'Average merchant growth of 18%+ after onboarding.',
            ),
            _BulletRow(text: 'Unified product & order management.'),
            _BulletRow(text: 'Native analytics and customer insights.'),
          ],
        ),
      ),

      _buildPage(
        number: 2,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Store Types — Individual vs Enterprise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose the store type that fits you. Below are the differences and what to expect when you open an Individual or Enterprise store on Stoqle.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 12),

              const Text(
                'Individual Store',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const _BulletRow(
                text:
                    'Designed for single-person sellers, artisans and home-based businesses.',
              ),
              const _BulletRow(
                text:
                    'No CAC required — you can register using your National ID (NIN).',
              ),
              const _BulletRow(
                text:
                    'For launch, Individuals can ONLY receive orders from Kaduna residents in Kaduna North, Kaduna South and Igabi LGA. Other LGAs and states are "Coming Soon".',
              ),

              const SizedBox(height: 12),
              const Text(
                'Enterprise Store',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const _BulletRow(
                text:
                    'For registered businesses and larger merchants operating across multiple locations.',
              ),
              const _BulletRow(
                text:
                    'Requires CAC registration document during onboarding for business verification.',
              ),
              const _BulletRow(
                text:
                    'Enterprises can access advanced features: multi-location inventory, team accounts, and VAT/invoice support.',
              ),

              const SizedBox(height: 12),
              const Text(
                'Quick note:',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                '- Individuals: fast onboarding with NIN; limited regional delivery for now.\n'
                '- Enterprises: full business tools; CAC required; broader delivery coverage (as enabled by Stoqle).',
                style: TextStyle(height: 1.45),
              ),
            ],
          ),
        ),
      ),

      _buildPage(
        number: 3,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Create an Individual Store',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'Quick steps to open an Individual store (good for solo sellers):',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            const _NumberedStep(
              index: 1,
              text: 'Sign up or log in with your phone number.',
            ),
            const _NumberedStep(
              index: 2,
              text: 'Open profile and choose "Open Individual Store".',
            ),
            const _NumberedStep(
              index: 3,
              text:
                  'Provide store name, product categories and a local Kaduna address.',
            ),
            const _NumberedStep(
              index: 4,
              text: 'Upload your National ID (NIN) for identity verification.',
            ),
            const _NumberedStep(
              index: 5,
              text:
                  'Agree to the Merchant Service Agreement and submit. You will be able to list products immediately once approved.',
            ),

            const SizedBox(height: 12),
            const Text(
              'Service area for Individual Stores',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const _BulletRow(
              text:
                  'Initially limited: orders accepted only from Kaduna residents in Kaduna North, Kaduna South and Igabi LGA.',
            ),
            const _BulletRow(
              text:
                  'A "Coming Soon" label will appear for other LGAs and states.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectStoreTypePage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text(
                        'Open Individual Store',
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

      _buildPage(
        number: 4,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grow & Support',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'With Stoqle you can:',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            const _BulletRow(
              text: 'Reach a wider range of customers across channels.',
            ),
            const _BulletRow(
              text: 'Reduce stockouts and sell more with smart inventory.',
            ),
            const _BulletRow(
              text: 'Use analytics to promote top performing products.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Need help? Contact our support on WhatsApp:',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openWhatsApp,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F7F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.phoneCall, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$supportWhatsAppNumber',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 18, color: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectStoreTypePage(),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Learn more'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectStoreTypePage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text(
                        'Open Store',
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
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Stoqle — Individual Store',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
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
                // <<< key change: scroll vertically instead of horizontally
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (ctx, i) => pages[i],
              ),
            ),

            // footer controls
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
                '${index}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
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
