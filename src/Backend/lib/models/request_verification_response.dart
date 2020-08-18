class RequestVerificationResponse {
  static String REGISTRY_URL = "registryUrl";
  static String NONCE = "nonce";
  static String OTC = "otc";
  static String PASSWORD = "password";

  String registryUrl;
  String nonce;
  String otc;
  String password;
  String error;

  bool get hasError => error != null;

  RequestVerificationResponse(this.error);

  RequestVerificationResponse.fromMap(Map<String, dynamic> map)
      : registryUrl = map[REGISTRY_URL] as String,
        nonce = map[NONCE]as String,
        password = map[PASSWORD]as String,
        otc = map[OTC]as String;
}
