import 'package:mirabilandia/controllers/wom_controller.dart';
import 'package:http/http.dart' as http;
import 'api/wom_request_repo.dart';
import 'mirabilandia.dart';

String womDomain;
String registryPublicKey;
String sourceId;

class MirabilandiaChannel extends ApplicationChannel {

  @override
  Future prepare() async {
    // Load configuration values onto globals
    final config = MyConfiguration(options.configurationFilePath);
    womDomain = config.womDomain;
    sourceId = config.sourceId;

    registryPublicKey = await getRegistryPublicKey();

    logger.onRecord.listen((rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router
      .route("/")
      .linkFunction((request) async {
        return Response.ok("We are live!");
      });

    router
      .route("/vouchers")
      .link(() => WomController(WomRepository()));

    return router;
  }

  Future<String> getRegistryPublicKey()async{
    final registryPublicKeyResponse = await http.get('https://$womDomain/api/v2/auth/key');
   return registryPublicKeyResponse.body;
  }
}

class MyConfiguration extends Configuration {
  MyConfiguration(String fileName) : super.fromFile(File(fileName));

  String womDomain;
  String sourceId;
}
