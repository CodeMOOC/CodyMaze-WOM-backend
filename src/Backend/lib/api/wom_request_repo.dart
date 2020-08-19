import 'dart:async';

import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:mirabilandia/channel.dart';
import 'package:mirabilandia/models/client_request.dart';
import 'package:mirabilandia/models/request_verification_response.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uuid/uuid.dart';

import 'wom_request_api.dart';

class WomRepository {
  WomRequestApiProvider _apiProvider;

  WomRepository() {
    _apiProvider = WomRequestApiProvider();
  }

  Future<RequestVerificationResponse> requestWomCreation(
      ClientRequest clientRequest) async {
    try {
      final nonce = Uuid().v1();

      final payloadMap = <String, dynamic>{
        'SourceId': sourceId,
        'Nonce': nonce,
        'Vouchers': [
          <String, dynamic>{
            'Latitude': clientRequest.lat,
            'Longitude': clientRequest.long,
            'Aim': 'E',
            'Count': 30,
            'Timestamp': DateTime.now().toIso8601String(),
          },
        ],
      };

      print("WOM REQUEST ------------- ");
      print(payloadMap);

      //encode map to json string
      final payloadMapEncoded = json.encode(payloadMap);

      final parser = RSAKeyParser();
      final publicKey = parser.parse(registryPublicKey) as RSAPublicKey;
      final privKey =
          await parseKeyFromFile<RSAPrivateKey>('/private/codymaze.pem');

      final encrypter =
          Encrypter(RSA(publicKey: publicKey, privateKey: privKey));

      final encrypted = encrypter.encrypt(payloadMapEncoded);

      final Map<String, dynamic> map = {
        'SourceId': '5f3ab6d898e66631aaeb60f2',
        'Nonce': nonce,
        'Payload': encrypted.base64,
      };

      final responseBody = await _apiProvider.requestWomCreation(
          'http://$womDomain/api/v1/voucher/create', map);

      //decode response body into json
      final jsonResponse = json.decode(responseBody);
      final encryptedPayload = jsonResponse["payload"] as String;
      final decryptedPayload = encrypter.decrypt64(encryptedPayload);

      //decode decrypted paylod into json
      final Map<String, dynamic> jsonDecrypted =
          json.decode(decryptedPayload) as Map<String, dynamic>;
      print(jsonDecrypted.toString());
      return RequestVerificationResponse.fromMap(jsonDecrypted);
    } catch (ex) {
      return RequestVerificationResponse(ex.toString());
    }
  }

  Future<bool> verifyWomCreation(RequestVerificationResponse response) async {
    print("WOM VERIFY ------------- ");
    final payloadMap = <String, String>{
      "Otc": response.otc,
    };

    print(payloadMap);

    try {
      final payloadMapEncoded = json.encode(payloadMap);

      final parser = RSAKeyParser();
      final publicKey = parser.parse(registryPublicKey) as RSAPublicKey;
      final privKey =
          await parseKeyFromFile<RSAPrivateKey>('/private/codymaze.pem');

      final encrypter =
          Encrypter(RSA(publicKey: publicKey, privateKey: privKey));

      final payloadEncrypted = encrypter.encrypt(payloadMapEncoded);

      final map = <String, dynamic>{
        "Payload": payloadEncrypted.base64,
      };

      return _apiProvider.verifyWomCreation(
          'http://$womDomain/api/v1/voucher/verify', map);
    } catch (ex) {
      print(ex.toString());
      return false;
    }
  }
}
