
// ignore_for_file: camel_case_types

class regex {
  bool isDoubleOnly(String text) {
    return RegExp(r'^[0-9.]+$').hasMatch(text);
  }

  //check if email is in valid format
  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  //check if username is in valid format
  bool isUserNameValid(String text) {
    return RegExp(r"^(?=[a-zA-Z0-9._ ]{0,20}$)(?!.*[_.]{2})[^_.].*[^_.]$")
        .hasMatch(text);
  }

  bool isCharacterOnly(String text) {
    return RegExp(r'^[a-zA-Z ]+$').hasMatch(text);
  }

  bool isNumberOnly(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }
}
