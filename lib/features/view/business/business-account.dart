import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BusinessPolicyEditorPage extends StatefulWidget {
  final String businessId;
  final String apiBase; // optional base URL (e.g. https://api.example.com)

  const BusinessPolicyEditorPage({
    Key? key,
    required this.businessId,
    this.apiBase = '',
  }) : super(key: key);

  @override
  _BusinessPolicyEditorPageState createState() =>
      _BusinessPolicyEditorPageState();
}

class _BusinessPolicyEditorPageState extends State<BusinessPolicyEditorPage> {
  bool _loading = true;
  bool _saving = false;
  String? _noticeMsg;
  bool _noticeIsError = false;

  // default policies (platform defaults)
  static const Map<String, dynamic> DEFAULT_POLICIES = {
    'ship_time': 'Ships within 1-3 business days',
    'promise_to_ship':
        'We aim to process orders within 48 hours and ship within 3 business days.',
    'delivery_notice':
        'Delivery times vary by location — typically 2-7 business days.',
    'payment_policy':
        'We accept bank transfer, card payments and POS on delivery (where available). Payments are processed securely.',
    'return_shipping_subsidy': 0,
    'seven_day_no_reason_return': 0,
    'rapid_refund': 1,
    'cs_reply_time': 'Replies within 24 hours on business days',
    'cs_avg_shipping': 'Average shipping: 3-5 days',
    'cs_good_reviews_summary':
        'We prioritize customer satisfaction and quick resolutions.',
    'default_welcome_message':
        'Hello! Thanks for visiting our store — how can we help today?',
    'from_market': 'stoqle',
    'additional_info': {},
  };

  // working policy
  late Map<String, dynamic> policy;

  // controllers
  late TextEditingController shipTimeCtrl;
  late TextEditingController promiseCtrl;
  late TextEditingController deliveryNoticeCtrl;
  late TextEditingController paymentCtrl;
  late TextEditingController csReplyCtrl;
  late TextEditingController csAvgShippingCtrl;
  late TextEditingController csGoodReviewsCtrl;
  late TextEditingController welcomeCtrl;
  late TextEditingController additionalJsonCtrl;

  // toggles
  bool returnShippingSubsidy = false;
  bool sevenDayNoReasonReturn = false;
  bool rapidRefund = true;

  @override
  void initState() {
    super.initState();
    policy = Map<String, dynamic>.from(DEFAULT_POLICIES);

    shipTimeCtrl = TextEditingController();
    promiseCtrl = TextEditingController();
    deliveryNoticeCtrl = TextEditingController();
    paymentCtrl = TextEditingController();
    csReplyCtrl = TextEditingController();
    csAvgShippingCtrl = TextEditingController();
    csGoodReviewsCtrl = TextEditingController();
    welcomeCtrl = TextEditingController();
    additionalJsonCtrl = TextEditingController();

    _loadPolicy();
  }

  @override
  void dispose() {
    shipTimeCtrl.dispose();
    promiseCtrl.dispose();
    deliveryNoticeCtrl.dispose();
    paymentCtrl.dispose();
    csReplyCtrl.dispose();
    csAvgShippingCtrl.dispose();
    csGoodReviewsCtrl.dispose();
    welcomeCtrl.dispose();
    additionalJsonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPolicy() async {
    setState(() {
      _loading = true;
      _noticeMsg = null;
    });

    final url =
        '${widget.apiBase}/api/businesses/${widget.businessId}/policies';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final data = body is Map && body['policy'] != null
            ? body['policy']
            : null;
        if (data == null) {
          // use defaults
          policy = Map<String, dynamic>.from(DEFAULT_POLICIES);
        } else {
          // merge defaults with returned policy (so missing fields fall back)
          policy = Map<String, dynamic>.from(DEFAULT_POLICIES);
          data.forEach((k, v) {
            policy[k] = v ?? policy[k];
          });
        }
      } else {
        policy = Map<String, dynamic>.from(DEFAULT_POLICIES);
        _noticeMsg = 'Failed to load business policy. Using platform defaults.';
        _noticeIsError = true;
      }
    } catch (e) {
      policy = Map<String, dynamic>.from(DEFAULT_POLICIES);
      _noticeMsg = 'Failed to load business policy. Using platform defaults.';
      _noticeIsError = true;
    }

    // populate controllers & toggles
    shipTimeCtrl.text = policy['ship_time'] ?? '';
    promiseCtrl.text = policy['promise_to_ship'] ?? '';
    deliveryNoticeCtrl.text = policy['delivery_notice'] ?? '';
    paymentCtrl.text = policy['payment_policy'] ?? '';
    csReplyCtrl.text = policy['cs_reply_time'] ?? '';
    csAvgShippingCtrl.text = policy['cs_avg_shipping'] ?? '';
    csGoodReviewsCtrl.text = policy['cs_good_reviews_summary'] ?? '';
    welcomeCtrl.text = policy['default_welcome_message'] ?? '';
    additionalJsonCtrl.text = jsonEncode(policy['additional_info'] ?? {});

    returnShippingSubsidy =
        (policy['return_shipping_subsidy'] == 1 ||
        policy['return_shipping_subsidy'] == true);
    sevenDayNoReasonReturn =
        (policy['seven_day_no_reason_return'] == 1 ||
        policy['seven_day_no_reason_return'] == true);
    rapidRefund =
        (policy['rapid_refund'] == 1 || policy['rapid_refund'] == true);

    setState(() {
      _loading = false;
    });
  }

  bool _validate() {
    // very light validation
    if (paymentCtrl.text.trim().length < 10) {
      _showNotice(
        'Please describe your payment options (at least 10 characters).',
        isError: true,
      );
      return false;
    }
    // validate additional_info JSON
    try {
      json.decode(
        additionalJsonCtrl.text.trim().isEmpty
            ? '{}'
            : additionalJsonCtrl.text.trim(),
      );
    } catch (e) {
      _showNotice('Additional info must be valid JSON.', isError: true);
      return false;
    }
    return true;
  }

  void _showNotice(String msg, {bool isError = false}) {
    setState(() {
      _noticeMsg = msg;
      _noticeIsError = isError;
    });
    // also show a snackbar
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    if (scaffoldMessenger != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        ),
      );
    }
  }

  Future<void> _savePolicy() async {
    if (!_validate()) return;

    setState(() {
      _saving = true;
      _noticeMsg = null;
    });

    final payload = {
      'ship_time': shipTimeCtrl.text.trim(),
      'promise_to_ship': promiseCtrl.text.trim(),
      'delivery_notice': deliveryNoticeCtrl.text.trim(),
      'payment_policy': paymentCtrl.text.trim(),
      'return_shipping_subsidy': returnShippingSubsidy ? 1 : 0,
      'seven_day_no_reason_return': sevenDayNoReasonReturn ? 1 : 0,
      'rapid_refund': rapidRefund ? 1 : 0,
      'cs_reply_time': csReplyCtrl.text.trim(),
      'cs_avg_shipping': csAvgShippingCtrl.text.trim(),
      'cs_good_reviews_summary': csGoodReviewsCtrl.text.trim(),
      'default_welcome_message': welcomeCtrl.text.trim(),
      'from_market': policy['from_market'] ?? 'stoqle',
      'additional_info': json.decode(
        additionalJsonCtrl.text.trim().isEmpty
            ? '{}'
            : additionalJsonCtrl.text.trim(),
      ),
    };

    final url =
        '${widget.apiBase}/api/businesses/${widget.businessId}/policies';

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'policy': payload}),
      );
      if (res.statusCode == 200) {
        _showNotice('Policies saved successfully.');
        // update local state
        setState(() {
          policy = payload;
        });
      } else {
        final body = res.body.isNotEmpty ? json.decode(res.body) : null;
        _showNotice(
          body != null && body['message'] != null
              ? body['message']
              : 'Failed to save policies.',
          isError: true,
        );
      }
    } catch (e) {
      _showNotice('Failed to save policies. Please try again.', isError: true);
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  void _resetToDefaults() {
    setState(() {
      policy = Map<String, dynamic>.from(DEFAULT_POLICIES);
      shipTimeCtrl.text = policy['ship_time'];
      promiseCtrl.text = policy['promise_to_ship'];
      deliveryNoticeCtrl.text = policy['delivery_notice'];
      paymentCtrl.text = policy['payment_policy'];
      csReplyCtrl.text = policy['cs_reply_time'];
      csAvgShippingCtrl.text = policy['cs_avg_shipping'];
      csGoodReviewsCtrl.text = policy['cs_good_reviews_summary'];
      welcomeCtrl.text = policy['default_welcome_message'];
      additionalJsonCtrl.text = jsonEncode(policy['additional_info']);

      returnShippingSubsidy = false;
      sevenDayNoReasonReturn = false;
      rapidRefund = true;

      _noticeMsg = 'Reverted to platform defaults.';
      _noticeIsError = false;
    });
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
    scaffoldMessenger?.showSnackBar(
      SnackBar(content: Text('Reverted to platform defaults.')),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) SizedBox(height: 4),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Business Policies'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _saving || _loading ? null : _savePolicy,
          child: Text(
            _saving ? 'Saving...' : 'Save',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: _loading
            ? Center(child: CupertinoActivityIndicator())
            : Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_noticeMsg != null)
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _noticeIsError
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _noticeIsError
                                  ? Colors.red.shade100
                                  : Colors.green.shade100,
                            ),
                          ),
                          child: Text(
                            _noticeMsg!,
                            style: TextStyle(
                              color: _noticeIsError
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),

                      _sectionCard(
                        title: 'Shipping',
                        subtitle: 'How and when you ship products',
                        child: Column(
                          children: [
                            CupertinoTextField(
                              controller: shipTimeCtrl,
                              placeholder: 'Ship time',
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                            SizedBox(height: 10),
                            CupertinoTextField(
                              controller: promiseCtrl,
                              placeholder: 'Promise to ship',
                              maxLines: 3,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                            SizedBox(height: 10),
                            CupertinoTextField(
                              controller: deliveryNoticeCtrl,
                              placeholder: 'Delivery notice',
                              maxLines: 2,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _sectionCard(
                        title: 'Payment',
                        subtitle: 'Accepted payment methods and processing',
                        child: Column(
                          children: [
                            CupertinoTextField(
                              controller: paymentCtrl,
                              placeholder: 'Payment policy',
                              maxLines: 4,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _sectionCard(
                        title: 'Returns & Refunds',
                        subtitle:
                            'Return windows, who pays shipping, refunds timeline',
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Return shipping subsidy'),
                                CupertinoSwitch(
                                  value: returnShippingSubsidy,
                                  onChanged: (v) =>
                                      setState(() => returnShippingSubsidy = v),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('7-day no reason return'),
                                CupertinoSwitch(
                                  value: sevenDayNoReasonReturn,
                                  onChanged: (v) => setState(
                                    () => sevenDayNoReasonReturn = v,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rapid refund'),
                                CupertinoSwitch(
                                  value: rapidRefund,
                                  onChanged: (v) =>
                                      setState(() => rapidRefund = v),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _sectionCard(
                        title: 'Customer Service',
                        subtitle: 'How you respond and help customers',
                        child: Column(
                          children: [
                            CupertinoTextField(
                              controller: csReplyCtrl,
                              placeholder: 'Reply time',
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                            SizedBox(height: 10),
                            CupertinoTextField(
                              controller: csAvgShippingCtrl,
                              placeholder: 'Average shipping summary',
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                            SizedBox(height: 10),
                            CupertinoTextField(
                              controller: csGoodReviewsCtrl,
                              placeholder: 'Good reviews summary',
                              maxLines: 2,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                          ],
                        ),
                      ),

                      _sectionCard(
                        title: 'Extras',
                        subtitle: 'Default message and metadata',
                        child: Column(
                          children: [
                            CupertinoTextField(
                              controller: welcomeCtrl,
                              placeholder: 'Welcome message',
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                            SizedBox(height: 8),
                            CupertinoTextField(
                              controller: additionalJsonCtrl,
                              placeholder:
                                  '{ "cod_zones": ["Kaduna North", "Kaduna South"] }',
                              maxLines: 5,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                            ),
                            SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Use JSON for structured extras',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fields left blank will use platform defaults.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          Row(
                            children: [
                              CupertinoButton(
                                onPressed: _resetToDefaults,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text('Reset to defaults'),
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              CupertinoButton.filled(
                                onPressed: _saving ? null : _savePolicy,
                                child: Text(
                                  _saving ? 'Saving...' : 'Save changes',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 20),
                      Text(
                        'Tip: Enterprise stores can have extra policy sections (e.g. bulk shipping). Individual stores inherit some platform limitations.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
