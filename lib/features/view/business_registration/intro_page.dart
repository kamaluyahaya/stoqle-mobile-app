import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'help-center/help.dart';
import 'selection-page.dart';

class StoqleIntroSlidePage extends StatefulWidget {
  const StoqleIntroSlidePage({Key? key}) : super(key: key);

  @override
  State<StoqleIntroSlidePage> createState() => _StoqleIntroSlidePageState();
}

class _StoqleIntroSlidePageState extends State<StoqleIntroSlidePage> {
  final _testimonialController = PageController(viewportFraction: 0.92);

  @override
  void dispose() {
    _testimonialController.dispose();
    super.dispose();
  }

  Widget _buildHero(BuildContext c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grow with Stoqle',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Powerful tools to grow your business by more than 18% — reach more customers, manage inventory and sell everywhere.',
            style: TextStyle(color: Colors.black54, height: 1.4, fontSize: 15),
          ),
          const SizedBox(height: 20),

          // Highlight metrics
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MetricCard(
                  value: '18%+',
                  label: 'Avg. Revenue Growth',
                  icon: LucideIcons.arrowUpRight,
                ),
                const SizedBox(width: 12),
                _MetricCard(
                  value: 'x3',
                  label: 'New Channels Reached',
                  icon: LucideIcons.users,
                ),
                const SizedBox(width: 12),
                _MetricCard(
                  value: '24/7',
                  label: 'Support',
                  icon: LucideIcons.headset,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SelectStoreTypePage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    LucideIcons.shoppingCart,
                    color: Colors.white,
                  ),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Get Started — It’s Free',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'title': 'Sell on Multiple Channels',
        'desc':
            'List once and sell on web, social and marketplaces seamlessly.',
        'icon': LucideIcons.layers,
      },
      {
        'title': 'Smart Inventory',
        'desc': 'Track stock in real-time for all your stores and warehouses.',
        'icon': LucideIcons.database,
      },
      {
        'title': 'Analytics & Insights',
        'desc':
            'Understand customer behavior and product trends with clear dashboards.',
        'icon': LucideIcons.chartBar,
      },
      {
        'title': 'Payments & Checkout',
        'desc': 'Fast, secure checkout with multiple payment options.',
        'icon': LucideIcons.creditCard,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features.map((f) {
        return _FeatureCard(
          title: f['title'] as String,
          description: f['desc'] as String,
          iconData: f['icon'] as IconData,
        );
      }).toList(),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      'Create your shop',
      'Upload products',
      'Start receiving orders',
      'Scale with insights',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),

          // Build steps vertically
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (i) {
              final stepNumber = (i + 1).toString().padLeft(
                2,
                '0',
              ); // 01, 02...
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Big step number
                    Text(
                      stepNumber,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.red.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Step description
                    Expanded(
                      child: Text(
                        steps[i],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.black87 : Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildCTA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to grow?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your free Stoqle shop today and see measurable growth within months.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Create my shop',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StoqleOnboardingPages(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Merchant Guide'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // so gradient shows behind AppBar too
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.headset, color: Colors.black87, size: 18),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => StoqleOnboardingPages()),
            ),
            tooltip: 'Help',
          ),
        ],
        title: const Text(
          'Stoqle',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFEBEE), // light red (top)
              Color(0xFFE0E0E0), // gray (middle)
              Colors.white, // white (bottom)
            ],
            stops: [0.0, 0.5, 1.0], // control where colors blend
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(context),
                const SizedBox(height: 18),
                _SectionTitle('Features to expand your reach'),
                const SizedBox(height: 8),
                _buildFeatures(),
                const SizedBox(height: 18),
                _SectionTitle('How Stoqle helps you'),
                const SizedBox(height: 8),
                _buildHowItWorks(),
                const SizedBox(height: 18),
                _SectionTitle('Trusted by merchants'),
                const SizedBox(height: 8),
                _buildCTA(),
                const SizedBox(height: 26),
                Center(
                  child: Text(
                    '© ${DateTime.now().year} Stoqle — Your business, amplified',
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----- Small helper widgets -----

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFFF7F7F9),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 50) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(41, 228, 92, 82),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, size: 20, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}
