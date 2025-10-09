class AuthState {
  final bool isLoading;
  final bool isOtpSent;
  final bool otpVerified;
  final bool needsProfile;
  final String? accountStatus;
  final String? message;
  final String? email;
  final String? phone;
  final String? token;
  final String? name;
  final int? user_id; // <- new
  final String? toastMessage;

  const AuthState({
    required this.isLoading,
    required this.isOtpSent,
    required this.otpVerified,
    required this.needsProfile,
    this.accountStatus,
    this.message,
    this.email,
    this.phone,
    this.token,
    this.name,
    this.user_id,
    this.toastMessage,
  });

  factory AuthState.initial() => const AuthState(
    isLoading: false,
    isOtpSent: false,
    otpVerified: false,
    needsProfile: false,
    accountStatus: null,
    message: null,
    email: null,
    phone: null,
    token: null,
    name: null,
    user_id: null,
  );

  AuthState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    bool? otpVerified,
    bool? needsProfile,
    String? accountStatus,
    String? message,
    String? email,
    String? phone,
    String? token,
    String? name,
    int? user_id,
    String? toastMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      needsProfile: needsProfile ?? this.needsProfile,
      accountStatus: accountStatus ?? this.accountStatus,
      message: message ?? this.message,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      name: name ?? this.name,
      user_id: user_id ?? this.user_id,
      toastMessage: toastMessage ?? this.toastMessage, // ✅ FIXED
    );
  }

  bool get isLoggedIn => token != null;
}
