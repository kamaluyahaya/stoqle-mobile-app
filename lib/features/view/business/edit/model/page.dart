// Model
import 'dart:convert';

class ShippingDurationItem {
  final String type; // 'avg' | 'promise'
  int value;
  String unit; // 'hours' | 'days' | 'weeks'

  ShippingDurationItem({
    required this.type,
    required this.value,
    required this.unit,
  });

  factory ShippingDurationItem.fromJson(Map<String, dynamic> j) {
    // infer type if not present (backwards compatibility)
    String inferredType = 'avg';
    if (j.containsKey('type') &&
        (j['type'] == 'promise' || j['type'] == 'avg')) {
      inferredType = j['type'];
    } else {
      final t = (j['title'] ?? '').toString().toLowerCase();
      if (t.contains('promise')) inferredType = 'promise';
    }

    return ShippingDurationItem(
      type: inferredType,
      value: (j['value'] is int)
          ? j['value']
          : int.tryParse('${j['value']}') ?? 0,
      unit: j['unit'] ?? 'hours',
    );
  }

  Map<String, dynamic> toJson() => {'type': type, 'value': value, 'unit': unit};

  ShippingDurationItem copy() =>
      ShippingDurationItem(type: type, value: value, unit: unit);
}

class MarketInfo {
  final String? market;
  final bool trustedPartner;
  final String? note;

  MarketInfo({this.market, required this.trustedPartner, this.note});

  factory MarketInfo.fromJson(Map<String, dynamic> j) {
    return MarketInfo(
      market: (j['market'] ?? '').toString().isEmpty ? null : j['market'],
      trustedPartner: j['trusted_partner'] == true,
      note: (j['note'] ?? '').toString().isEmpty ? null : j['note'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'market': market, 'trusted_partner': trustedPartner, 'note': note}
        ..removeWhere((_, v) => v == null);
}

class BusinessAddressInfo {
  final String line1;
  final String line2;

  BusinessAddressInfo({required this.line1, required this.line2});

  factory BusinessAddressInfo.fromJson(Map<String, dynamic> j) {
    return BusinessAddressInfo(
      line1: (j['address_line_1'] ?? '').toString(),
      line2: (j['address_line_2'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'address_line_1': line1,
    'address_line_2': line2,
  };
}

class CustomerServiceInfo {
  final String replyTime; // e.g. "Within 1 hour"
  final double goodReviewSummary; // numeric rating 1.0 - 5.0
  final String welcomeDm;

  CustomerServiceInfo({
    required this.replyTime,
    required this.goodReviewSummary,
    required this.welcomeDm,
  });

  factory CustomerServiceInfo.fromJson(Map<String, dynamic> j) {
    double rating = 5.0;
    final raw = j['good_review_summary'];
    if (raw != null) {
      if (raw is num) {
        rating = raw.toDouble();
      } else {
        rating = double.tryParse(raw.toString()) ?? 5.0;
      }
    }

    return CustomerServiceInfo(
      replyTime: (j['reply_time'] ?? '').toString(),
      goodReviewSummary: rating,
      welcomeDm: (j['welcome_dm'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'reply_time': replyTime,
    'good_review_summary': goodReviewSummary,
    'welcome_dm': welcomeDm,
  };
}

class PaymentInfo {
  final bool supportAvailable;
  final bool podEnabled;
  final bool codEnabled;
  final String accountNumber;
  final String accountName;
  final String bankName;

  PaymentInfo({
    required this.supportAvailable,
    required this.podEnabled,
    required this.codEnabled,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> j) {
    return PaymentInfo(
      supportAvailable: j['support_available'] == true,
      podEnabled: j['pod_enabled'] == true,
      codEnabled: j['cod_enabled'] == true,
      accountNumber: (j['account_number'] ?? '').toString(),
      accountName: (j['account_name'] ?? '').toString(),
      bankName: (j['bank_name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'support_available': supportAvailable,
    'pod_enabled': podEnabled,
    'cod_enabled': codEnabled,
    'account_number': accountNumber,
    'account_name': accountName,
    'bank_name': bankName,
  };
}

class Promotion {
  final String occasion;
  final DateTime start;
  final DateTime end;
  final double discount;

  Promotion({
    required this.occasion,
    required this.start,
    required this.end,
    required this.discount,
  });

  factory Promotion.fromJson(Map<String, dynamic> j) {
    return Promotion(
      occasion: (j['occasion'] ?? '').toString(),
      start: DateTime.tryParse(j['start'] ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(j['end'] ?? '') ?? DateTime.now(),
      discount: double.tryParse(j['discount'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'occasion': occasion,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'discount': discount,
  };
}

class BusinessProfilePayload {
  final MarketInfo marketInfo;
  final BusinessAddressInfo businessAddress;
  final CustomerServiceInfo customerService;
  final PaymentInfo paymentInfo;
  final List<ShippingDurationItem> shippingDurations;
  final List<Promotion> promotions;

  BusinessProfilePayload({
    required this.marketInfo,
    required this.businessAddress,
    required this.customerService,
    required this.paymentInfo,
    required this.shippingDurations,
    required this.promotions,
  });

  factory BusinessProfilePayload.fromJson(Map<String, dynamic> j) {
    return BusinessProfilePayload(
      marketInfo: MarketInfo.fromJson(j['market_info'] ?? {}),
      businessAddress: BusinessAddressInfo.fromJson(
        j['business_address'] ?? {},
      ),
      customerService: CustomerServiceInfo.fromJson(
        j['customer_service_info'] ?? {},
      ),
      paymentInfo: PaymentInfo.fromJson(j['payment_info'] ?? {}),
      shippingDurations: (j['shipping_durations'] as List? ?? [])
          .map((e) => ShippingDurationItem.fromJson(e))
          .toList(),
      promotions: (j['promotions'] as List? ?? [])
          .map((e) => Promotion.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'market_info': marketInfo.toJson(),
    'business_address': businessAddress.toJson(),
    'customer_service_info': customerService.toJson(),
    'payment_info': paymentInfo.toJson(),
    'shipping_durations': shippingDurations.map((e) => e.toJson()).toList(),
    'promotions': promotions.map((e) => e.toJson()).toList(),
  };
}

final payload = BusinessProfilePayload(
  marketInfo: MarketInfo(
    market: 'Kaduna Market',
    trustedPartner: true,
    note: 'Top Partner',
  ),
  businessAddress: BusinessAddressInfo(
    line1: 'No. 12 Independence Road',
    line2: 'Kaduna North',
  ),
  customerService: CustomerServiceInfo(
    replyTime: 'Within 1 hour',
    goodReviewSummary: 4.8,
    welcomeDm: 'Welcome to our store!',
  ),
  paymentInfo: PaymentInfo(
    supportAvailable: true,
    podEnabled: true,
    codEnabled: false,
    accountNumber: '1234567890',
    accountName: 'KSOFT Technova',
    bankName: 'Access Bank',
  ),
  shippingDurations: [
    ShippingDurationItem(type: 'avg', value: 2, unit: 'days'),
    ShippingDurationItem(type: 'promise', value: 5, unit: 'days'),
  ],
  promotions: [
    Promotion(
      occasion: 'Independence Day',
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 3)),
      discount: 10,
    ),
  ],
);

final requestBody = payload.toJson();

void main() {
  final payload = BusinessProfilePayload(
    marketInfo: MarketInfo(
      market: 'Kaduna Market',
      trustedPartner: true,
      note: 'Top Partner',
    ),
    businessAddress: BusinessAddressInfo(
      line1: 'No. 12 Independence Road',
      line2: 'Kaduna North',
    ),
    customerService: CustomerServiceInfo(
      replyTime: 'Within 1 hour',
      goodReviewSummary: 4.8,
      welcomeDm: 'Welcome to our store!',
    ),
    paymentInfo: PaymentInfo(
      supportAvailable: true,
      podEnabled: true,
      codEnabled: false,
      accountNumber: '1234567890',
      accountName: 'KSOFT Technova',
      bankName: 'Access Bank',
    ),
    shippingDurations: [
      ShippingDurationItem(type: 'avg', value: 2, unit: 'days'),
      ShippingDurationItem(type: 'promise', value: 5, unit: 'days'),
    ],
    promotions: [
      Promotion(
        occasion: 'Independence Day',
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 3)),
        discount: 10,
      ),
    ],
  );

  final requestBody = payload.toJson();

  // Pretty print JSON
  final prettyJson = const JsonEncoder.withIndent('  ').convert(requestBody);
  print(prettyJson);
}

// print(requestBody)
