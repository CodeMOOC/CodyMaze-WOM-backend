import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:mirabilandia/api/wom_request_repo.dart';
import 'package:mirabilandia/channel.dart';
import 'package:mirabilandia/models/client_request.dart';

class WomController extends ResourceController {

  final WomRepository _womRepository;

  WomController(this._womRepository);

  @Operation.post()
  Future<Response> generateWOM(@Bind.body() ClientRequest clientRequest) async {
    // POST /vouchers

    final response =
    await _womRepository.requestWomCreation(clientRequest);
    if (response.hasError) {
      print(response.error);
      return Response.serverError(body:{'error':response.error});
    }
    final verificationResponse =
    await _womRepository.verifyWomCreation(response);
    if (verificationResponse) {
      return Response.ok({'id':clientRequest.id,'womLink':'https://$womDomain/vouchers/${response.otc}' ,'womPassword':response.password,'womCount':30,});
    } else {
      return Response.serverError(body: {'error':'La verifica è fallita'});
    }
  }
}
