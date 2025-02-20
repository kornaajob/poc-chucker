class EncryptionConfig {
  final String algorithm;
  final String key;
  final bool enabled;

  const EncryptionConfig({
    required this.algorithm,
    required this.key,
    this.enabled = true,
  });
}
