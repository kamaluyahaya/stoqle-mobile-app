import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/default/defaultButton.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/helper/business-profile-helper.dart';
import 'address-info.dart';
import 'cs-info.dart';
import 'discount.dart';
import 'market-info.dart';
import 'payment-info.dart';
import 'promotion-info.dart';
import 'return_and_refund.dart';
import 'shipping-info.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // controllers used for preview and initial content
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shippingInfo = TextEditingController();
  final TextEditingController _returnController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _customerServiceController =
      TextEditingController();
  final TextEditingController _marketController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _promotionController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  String? profileImageUrl;
  String? coverImageUrl;

  bool _isLoading = true;
  bool _isSyncing = false;

  // keys used for SharedPreferences
  static const _kName = 'business_name';
  static const _kShipping = 'business_shipping_info';
  static const _kRefunds = 'business_return_refunds';
  static const _kPaymentInfo = 'business_payment_info';
  static const _kCustomerService = 'business_customer_service';
  static const _kAddress = 'business_address_info';
  static const _kMarket = 'business_market_affiliation';
  static const _kPromo = 'business_promotional_sale';
  static const _kDiscount = 'business_sales_discount';
  static const _kRegion = 'business_region';

  // snapshot of loaded prefs to detect unsaved changes
  Map<String, String?> _initialPrefs = {};

  Future<void> _loadAllPrefs() async {
    final name = await ProfilePrefs.loadField(_kName);
    final shipping = await ProfilePrefs.loadField(_kShipping);
    final refunds = await ProfilePrefs.loadField(_kRefunds);
    final payment = await ProfilePrefs.loadField(_kPaymentInfo);
    final address = await ProfilePrefs.loadField(_kAddress);
    final market = await ProfilePrefs.loadField(_kMarket);
    final customerService = await ProfilePrefs.loadField(_kCustomerService);
    final promo = await ProfilePrefs.loadField(_kPromo);
    final discount = await ProfilePrefs.loadField(_kDiscount);
    final region = await ProfilePrefs.loadField(_kRegion);

    // normalize: treat null as empty string
    final n = name ?? '';
    final s = shipping ?? '';
    final r = refunds ?? '';
    final p = payment ?? '';
    final a = address ?? '';
    final m = market ?? '';
    final cs = customerService ?? '';
    final pr = promo ?? '';
    final d = discount ?? '';
    final rg = region ?? '';

    if (!mounted) return;

    setState(() {
      // set controllers based on loaded prefs
      _nameController.text = n;
      _shippingInfo.text = s;
      _returnController.text = r;
      _paymentController.text = p;
      _addressController.text = a;
      _marketController.text = m;
      _customerServiceController.text = cs;
      _promotionController.text = pr;
      _discountController.text = d;
      _regionController.text = rg;

      // snapshot AFTER controllers were set
      _initialPrefs = {
        _kName: n,
        _kShipping: s,
        _kRefunds: r,
        _kPaymentInfo: p,
        _kAddress: a,
        _kMarket: m,
        _kCustomerService: cs,
        _kPromo: pr,
        _kDiscount: d,
        _kRegion: rg,
      };
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shippingInfo.dispose();
    _returnController.dispose();
    _paymentController.dispose();
    _customerServiceController.dispose();
    _marketController.dispose();
    _addressController.dispose();
    _promotionController.dispose();
    _discountController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  /// Save profile to backend and clear local prefs — does NOT pop.
  Future<void> _saveProfile() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    await _loadAllPrefs();

    final payload = <String, String>{
      'name': _nameController.text.trim(),
      'shipping_info': _shippingInfo.text.trim(),
      'return_refunds': _returnController.text.trim(),
      'payment_info': _paymentController.text.trim(),
      'customer_service': _customerServiceController.text.trim(),
      'address_info': _addressController.text.trim(),
      'market_affiliation': _marketController.text.trim(),
      'promotional_sale': _promotionController.text.trim(),
      'sales_discount': _discountController.text.trim(),
      'region': _regionController.text.trim(),
    };

    try {
      await _sendToBackend(payload);
      await ProfilePrefs.clearAll();
      await _loadAllPrefs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile synced successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to sync: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _sendToBackend(Map<String, String> payload) async {
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('Sending to backend: $payload');
  }

  @override
  void initState() {
    super.initState();
    // load current prefs into controllers and snapshot
    _loadAllPrefs().whenComplete(() {
      // After prefs are loaded, check if there's a pending draft and prompt user
      _checkPendingDraftOnEnter();
      if (mounted) setState(() => _isLoading = false);
    });
  }

  /// Returns true if any of the tracked preference keys contains non-empty data.
  Future<bool> _hasPendingPrefsData() async {
    final keys = [
      _kName,
      _kShipping,
      _kRefunds,
      _kPaymentInfo,
      _kCustomerService,
      _kAddress,
      _kMarket,
      _kPromo,
      _kDiscount,
      _kRegion,
    ];

    for (final k in keys) {
      final v = await ProfilePrefs.loadField(k);
      if (v != null && v.toString().trim().isNotEmpty) return true;
    }
    return false;
  }

  /// Called right after prefs load: if there's saved draft/pending data, prompt user to restore or discard.
  Future<void> _checkPendingDraftOnEnter() async {
    final hasPending = await _hasPendingPrefsData();
    if (!hasPending) return;

    // show dialog asking to restore or discard the pending draft
    final result = await showCupertinoDialog<String?>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Pending draft found',
            style: TextStyle(fontSize: 15, fontFamily: "Bold"),
          ),
        ),
        // content: const Text(
        //   'Do you want to restore it or discard it?',
        //   style: TextStyle(fontSize: 14),
        // ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text(
              'Discard',
              style: TextStyle(fontFamily: "Bold", fontSize: 15),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop('restore'),
            child: const Text(
              'Restore',
              style: TextStyle(fontFamily: "Bold", fontSize: 15),
            ),
          ),
        ],
      ),
    );

    if (result == 'discard') {
      await ProfilePrefs.clearAll();
      await _loadAllPrefs();
    } else {
      // 'restore' chosen (or default) -> controllers already populated by _loadAllPrefs()
    }
  }

  /// Intercept back: if any prefs data exists ask user to Continue later (keep), Discard, or Cancel.
  Future<bool> _onWillPop() async {
    final hasPending = await _hasPendingPrefsData();
    if (!hasPending) return true;

    final result = await showCupertinoDialog<String?>(
      barrierDismissible: true,
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Pending Draft',
            style: TextStyle(fontSize: 15, fontFamily: "Bold"),
          ),
        ),
        // content: const Text(
        //   'Do you want to continue editing later (keep draft) or discard it?',
        //   style: TextStyle(fontSize: 14),
        // ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: const Text(
              'Discard',
              style: TextStyle(fontFamily: "Bold", fontSize: 15),
            ),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop('keep'),
            child: const Text(
              'Continue later',
              style: TextStyle(fontFamily: "Bold", fontSize: 15),
            ),
          ),
        ],
      ),
    );

    if (result == 'keep') {
      return true; // keep draft, just pop
    } else if (result == 'discard') {
      await ProfilePrefs.clearAll();
      return true;
    } else {
      return false; // cancel
    }
  }

  Future<void> _handleBackPressed() async {
    final shouldPop = await _onWillPop();
    if (shouldPop && mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _editableRow({
    required String label,
    required String value,
    required String prefKey,
    bool isMultiline = false,
  }) {
    return InkWell(
      onTap: () async {
        // route to a dedicated editor page depending on prefKey
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SectionEditorLauncher(
              title: label,
              prefKey: prefKey,
              initialValue: value,
              isMultiline: isMultiline,
            ),
          ),
        );

        // Reload prefs after editor closes
        await _loadAllPrefs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                "$label:",
                style: TextStyle(fontSize: 15, color: kBlack),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                value.isNotEmpty ? value : 'Update $label',
                style: TextStyle(
                  fontSize: 15,
                  color: value.isNotEmpty ? Colors.black : Colors.grey[500],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope intercepts system back button
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: CupertinoColors.systemGroupedBackground,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back, color: Colors.black),
            onPressed: _handleBackPressed,
          ),
          centerTitle: true,
          title: const Text(
            'Update Business',
            style: TextStyle(color: Colors.black, fontFamily: "Bold"),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(12),
          child: SizedBox(
            child: DefaultButton(
              title: _isSyncing ? "Syncing..." : "Save",
              color: AppColors.kDefault,
              loader: _isSyncing ? const Text('') : const SizedBox.shrink(),
              onPressed: _isSyncing
                  ? null
                  : () async {
                      await _saveProfile();
                      if (mounted) Navigator.of(context).pop();
                    },
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          key: const ValueKey('avatar'),
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            LucideIcons.cat,
                            size: 50,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text
                          : 'Business name',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "Bold",
                        color: kBlack,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Shipping info',
                          value: _shippingInfo.text,
                          prefKey: _kShipping,
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Return & Refunds',
                          value: _returnController.text,
                          prefKey: _kRefunds,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Payment Info',
                          value: _paymentController.text,
                          prefKey: _kPaymentInfo,
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Customer Service',
                          value: _customerServiceController.text,
                          prefKey: _kCustomerService,
                          isMultiline: true,
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Address Info',
                          value: _addressController.text,
                          prefKey: _kAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Market Affiliation',
                          value: _marketController.text,
                          prefKey: _kMarket,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildCard(
                    child: Column(
                      children: [
                        _editableRow(
                          label: 'Promotional Sale',
                          value: _promotionController.text,
                          prefKey: _kPromo,
                        ),
                        Divider(color: kWhite10, thickness: 0.5),
                        _editableRow(
                          label: 'Sales Discount',
                          value: _discountController.text,
                          prefKey: _kDiscount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 90),
                ],
              ),
            ),

            if (_isLoading || _isSyncing)
              AbsorbPointer(
                absorbing: true,
                child: SizedBox.expand(
                  child: Container(
                    color: CupertinoColors.systemGroupedBackground.withOpacity(
                      0.9,
                    ),
                    child: SafeArea(
                      child: Center(child: CustomCircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Launcher that maps a prefKey to a dedicated editor page.
/// Add new editors here as your sections grow.
class SectionEditorLauncher extends StatelessWidget {
  final String title;
  final String prefKey;
  final String initialValue;
  final bool isMultiline;

  const SectionEditorLauncher({
    Key? key,
    required this.title,
    required this.prefKey,
    required this.initialValue,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (prefKey) {
      case _EditProfileKeys.kShipping:
        page = ShippingDurationEditor(
          prefKey: prefKey,
          initialValue: initialValue,
        );
        break;
      case _EditProfileKeys.kRefunds:
        page = RefundsEditor(prefKey: prefKey, initialValue: initialValue);
        break;
      case _EditProfileKeys.kPaymentInfo:
        page = PaymentInfoEditor(prefKey: prefKey, initialValue: initialValue);
        break;
      case _EditProfileKeys.kCustomerService:
        page = CustomerServiceEditor(
          prefKey: prefKey,
          initialValue: initialValue,
        );
        break;
      case _EditProfileKeys.kAddress:
        page = BusinessAddressEditor(
          prefKey: prefKey,
          initialValue: initialValue,
        );
        break;
      case _EditProfileKeys.kMarket:
        page = MarketEditor(prefKey: prefKey, initialValue: initialValue);
        break;
      case _EditProfileKeys.kPromo:
        page = PromotionsEditor(prefKey: prefKey, initialValue: initialValue);
        break;
      case _EditProfileKeys.kDiscount:
        page = SaleDiscountPage(prefKey: prefKey, initialValue: initialValue);
        break;
      default:
        page = GenericTextEditor(
          title: title,
          prefKey: prefKey,
          initialValue: initialValue,
          isMultiline: isMultiline,
        );
    }

    return page;
  }
}

class _EditProfileKeys {
  static const kShipping = 'business_shipping_info';
  static const kRefunds = 'business_return_refunds';
  static const kPaymentInfo = 'business_payment_info';
  static const kCustomerService = 'business_customer_service';
  static const kAddress = 'business_address_info';
  static const kMarket = 'business_market_affiliation';
  static const kPromo = 'business_promotional_sale';
  static const kDiscount = 'business_sales_discount';
}

/// Generic editor for simple text or multiline text.
class GenericTextEditor extends StatefulWidget {
  final String title;
  final String prefKey;
  final String initialValue;
  final bool isMultiline;

  const GenericTextEditor({
    Key? key,
    required this.title,
    required this.prefKey,
    required this.initialValue,
    this.isMultiline = false,
  }) : super(key: key);

  @override
  State<GenericTextEditor> createState() => _GenericTextEditorState();
}

class _GenericTextEditorState extends State<GenericTextEditor> {
  late TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ProfilePrefs.saveField(widget.prefKey, _controller.text.trim());
    setState(() => _saving = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.title}'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(color: _saving ? Colors.grey : Colors.blue),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          maxLines: widget.isMultiline ? 6 : 1,
          decoration: InputDecoration(
            labelText: widget.title,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
