import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class WomRequestApiProvider {

  Future<String> requestWomCreation(
      String url, Map<String, dynamic> map) async {
    final resp = await http.post(
      url,
      body: json.encode(map),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    );
    if (resp.statusCode == 200) {
      print(resp.body);
      return resp.body;
    }
    final Map<String, dynamic> jsonError = json.decode(resp.body) as Map<String, dynamic>;
    throw Exception(jsonError['title']);
  }

  Future<bool> verifyWomCreation(
      String url, Map<String, dynamic> map) async {
    final resp = await http.post(
      url,
      body: json.encode(map),
      headers: {HttpHeaders.contentTypeHeader: "application/json"},
    );
    if (resp.statusCode == 200) {
      return true;
    }
    final Map<String, dynamic> jsonError = json.decode(resp.body) as Map<String, dynamic>;
    throw Exception(jsonError['title']);
  }
}
