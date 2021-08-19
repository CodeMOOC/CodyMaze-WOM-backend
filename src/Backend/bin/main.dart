import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_wom_connector/dart_wom_connector.dart';
import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

late String womDomain;
late String sourceId;
late String registryPublicKey;
late String instrumentPrivateKey;

const _hostname = '0.0.0.0';

class Service {
  final InstrumentClient instrumentClient;

  Service(this.instrumentClient);

  // The [Router] can be used to create a handler, which can be used with
  // [shelf_io.serve].
  Handler get handler {
    final router = Router();

    // Handlers can be added with `router.<verb>('<route>', handler)`, the
    // '<route>' may embed URL-parameters, and these may be taken as parameters
    // by the handler (but either all URL parameters or no URL parameters, must
    // be taken parameters by the handler).
    router.post('/vouchers', (Request request) async {
      final map =
          jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final id = map['id'] as String;
      final vouchers = <Voucher>[
        Voucher(
            lat: 43.7292635,
            long: 12.6129107,
            aim: 'E',
            count: 30,
            dateTime: DateTime.now()),
      ];
      try {
        final response = await instrumentClient.requestVouchers(vouchers);

        final verificationResponse =
            await instrumentClient.verifyRequest(response);
        if (verificationResponse) {
          return Response.ok(jsonEncode({
            'id': id,
            'womLink': response.link,
            'womPassword': response.password,
            'womCount': 30,
          }));
        } else {
          return Response.internalServerError(
              body: {'error': 'La verifica è fallita'});
        }
      } catch (ex) {
        return Response.internalServerError(body: {'error': ex.toString()});
      }
    });

    router.get('/', (Request request) async {
      await Future.delayed(const Duration(seconds: 1));
      return Response.ok("We are live!");
    });

    return router;
  }
}

Future<String> getRegistryPublicKey() async {
  final registryPublicKeyResponse =
      await http.get(Uri.parse('https://$womDomain/api/v2/auth/key'));
  return registryPublicKeyResponse.body;
}

void main() async {
  final envVars = Platform.environment;
  womDomain = envVars['WOM_DOMAIN'] as String;
  sourceId = envVars['SOURCE_ID'] as String;

  registryPublicKey = await getRegistryPublicKey();

  final privateKeyFile = File('/private/codymaze.pem');
  instrumentPrivateKey = await privateKeyFile.readAsString();

  final service = Service(InstrumentClient(
      Instrument(
        id: sourceId,
        locationIsFixed: true,
        defaultLocation: Location(
          latitude: 43.7292635,
          longitude: 12.6129107,
        ),
        name: 'CodyMaze',
        privateKey: instrumentPrivateKey,
        publicKey: '',
        enabledAims: {'E'},
        perAimBudget: {},
      ),
      womDomain,
      registryPublicKey));
  final server = await shelf_io.serve(service.handler, _hostname, 8080);
  print('Serving at http://${server.address.host}:${server.port}');
}
