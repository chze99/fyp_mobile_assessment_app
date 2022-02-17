// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  // final String url = 'http://10.0.2.2:8000/api/';
  final String url = 'http://192.168.0.15:80/api/';
  final String host_url = 'http://192.168.0.15:80';
  var token;

  getUrl() {
    return host_url;
  }

  Future<void> getToken() async {
    SharedPreferences local_storage = await SharedPreferences.getInstance();
    token = json.decode(local_storage.getString('token') ?? "")['token'];
  }

  authData(data, apiUrl) async {
    var new_url = url + apiUrl;
    return await http.post(Uri.parse(new_url),
        body: jsonEncode(data), headers: _setHeaders());
  }

  getData(apiUrl) async {
    var new_url = url + apiUrl;
    await getToken();
    return await http.get(Uri.parse(new_url), headers: _setHeaders());
  }

  postData(data, apiUrl) async {
    var new_url = url + apiUrl;
    await getToken();
    return await http.post(Uri.parse(new_url),
        body: jsonEncode(data), headers: _setHeaders());
  }

  Future uploadImageToServer(profile_image, id_image, apiUrl) async {
    var new_url = url + apiUrl;
    final uri = Uri.parse(new_url);
    var profile_image_to_upload =
        await http.MultipartFile.fromPath("profile_image", profile_image!.path);
    var ic_image_to_upload =
        await http.MultipartFile.fromPath("id_image", id_image!.path);
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_setHeaders());
    request.files.add(profile_image_to_upload);
    request.files.add(ic_image_to_upload);
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    return respStr;
  }

  Future uploadFileToServer(file, qdid, apiUrl) async {
    var new_url = url + apiUrl;
    final uri = Uri.parse(new_url);
    var file_to_upload =
        await http.MultipartFile.fromPath("practical_attachment", file!.path);
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_setHeaders());
    request.files.add(file_to_upload);
    request.fields['question_paper_id'] = qdid.toString();
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    return respStr;
  }

  Future uploadStudentPracticalAnswerFileToServer(file, spdid, apiUrl) async {
    var new_url = url + apiUrl;
    final uri = Uri.parse(new_url);
    var file_to_upload = await http.MultipartFile.fromPath(
        "student_practical_answer_attachment", file!.path);
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_setHeaders());
    request.files.add(file_to_upload);
    request.fields['solution_paperdetail_id'] = spdid.toString();
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    return respStr;
  }

  Future uploadQBFileToServer(file, qdid, apiUrl) async {
    var new_url = url + apiUrl;
    final uri = Uri.parse(new_url);
    var file_to_upload =
        await http.MultipartFile.fromPath("practical_attachment", file!.path);
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_setHeaders());
    request.files.add(file_to_upload);
    request.fields['question_bank_id'] = qdid.toString();
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    return respStr;
  }

  Future lecturerAttachmentDownload(apiUrl) async {
    var new_url = url + apiUrl;
    await getToken();
    return await http.get(Uri.parse(new_url), headers: _setHeaders());
  }

  _setHeaders() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer $token',
      };
}
