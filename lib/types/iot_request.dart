import 'dart:convert';
import 'dart:io';

class IotRequest {
  static String serverIp = "";
  static int serverPort = 0;
  static setServerAddress(String address) {
    List<String> splitAddress = address.split(":");
    serverIp = splitAddress[0];
    serverPort = int.parse(splitAddress[1]);
  }

  static sendJsonRequest(Map<String,dynamic> jsonData, void Function(Map<String,dynamic>) onResponse, {bool useCustomIp = false, String customIp = "", int customPort = 0}) async {
    HttpClient httpClient = HttpClient();
    String content = jsonEncode(jsonData);

    try {
      var httpRequest = await httpClient.get(useCustomIp? customIp : serverIp, useCustomIp? customPort : serverPort, "/")
        ..headers.contentType = ContentType.json
        ..headers.contentLength = content.length
        ..write(content);

      var httpResponse = await httpRequest.close().timeout(
          Duration(seconds: 5));

      var httpResponseContent = await utf8.decoder.bind(httpResponse).join();
      Map<String, dynamic> receivedJson = jsonDecode(httpResponseContent);
      onResponse(receivedJson);
    }
    catch (e) {
      onResponse({"responseId" : "VALID", "data" : {"result" : "ERROR"}});
    }
  }

  static sendValidRequest(void Function(Map<String,dynamic>) onResponse, {bool useCustomIp = false, String customIp = "", int customPort = 0}) {
    sendJsonRequest({"requestId" : "VALID"}, onResponse, useCustomIp: useCustomIp, customIp: customIp, customPort: customPort);
  }

  static sendListRequest(void Function(Map<String,dynamic>) onResponse) {
    sendJsonRequest({"requestId" : "LIST"}, onResponse);
  }

  static sendValRequest(String moduleId, String sendValue, void Function(Map<String,dynamic>) onResponse) {
    sendJsonRequest({"requestId" : "VAL", "data": {"id" : moduleId, "reqVal" : sendValue}}, onResponse);
  }

  static sendNewRequest(String moduleId, void Function(Map<String,dynamic>) onResponse) {
    sendJsonRequest({"requestId" : "NEW", "data": {"id" : moduleId}}, onResponse);
  }

  static sendSearchRequest(String moduleId, void Function(Map<String,dynamic>) onResponse) {
    sendJsonRequest({"requestId" : "SEARCH", "data": {"id" : moduleId}}, onResponse);
  }

  static sendDeleteRequest(String moduleId, void Function(Map<String,dynamic>) onResponse) {
    sendJsonRequest({"requestId" : "DELETE", "data": {"id" : moduleId}}, onResponse);
  }
}