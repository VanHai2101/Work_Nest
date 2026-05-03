class TotpSecretEntity {
  final String secretKey;
  final String qrCodeUrl;
  final dynamic firebaseSecret;

  const TotpSecretEntity({
    required this.secretKey,
    required this.qrCodeUrl,
    required this.firebaseSecret,
  });
}
