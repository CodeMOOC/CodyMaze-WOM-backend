import 'package:aqueduct/aqueduct.dart';

class ClientRequest extends Serializable {

  String id;
  double lat;
  double long;

@override
  Map<String, dynamic> asMap() {
    return <String, dynamic>{
      'id': id,
      'lat':lat ,
      'long': long
    };
  }

  @override
  void readFromMap(Map<String, dynamic> object) {
   id = object['id'] as String;
   lat = object['lat'] as double;
   long = object['long'] as double;
  }
}
