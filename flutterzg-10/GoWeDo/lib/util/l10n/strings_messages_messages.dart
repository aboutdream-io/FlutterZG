// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'messages';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "_dayMonthYearFormat" : MessageLookupByLibrary.simpleMessage("dd.MM.yyyy"),
    "_dayMonthYearHourMinuteFormat" : MessageLookupByLibrary.simpleMessage("dd.MM.yyyy - HH:mm"),
    "_hourMinuteFormat" : MessageLookupByLibrary.simpleMessage("HH:mm"),
    "_monthNameFormat" : MessageLookupByLibrary.simpleMessage("MMMM"),
    "confirm" : MessageLookupByLibrary.simpleMessage("Confirm"),
    "done" : MessageLookupByLibrary.simpleMessage("Done"),
    "email" : MessageLookupByLibrary.simpleMessage("email"),
    "emailAddress" : MessageLookupByLibrary.simpleMessage("email address"),
    "emailNotValid" : MessageLookupByLibrary.simpleMessage("email address not valid"),
    "emailRegistration" : MessageLookupByLibrary.simpleMessage("Email registration"),
    "enterEmail" : MessageLookupByLibrary.simpleMessage("please enter email address"),
    "enterFirstName" : MessageLookupByLibrary.simpleMessage("please enter first name"),
    "enterLastName" : MessageLookupByLibrary.simpleMessage("please enter last name"),
    "enterPassword" : MessageLookupByLibrary.simpleMessage("please enter password"),
    "enterRepeatPassword" : MessageLookupByLibrary.simpleMessage("please enter repeat password"),
    "genericErrorMessage" : MessageLookupByLibrary.simpleMessage("Please try again"),
    "genericErrorTitle" : MessageLookupByLibrary.simpleMessage("Error"),
    "login" : MessageLookupByLibrary.simpleMessage("login"),
    "lostPassword" : MessageLookupByLibrary.simpleMessage("lost password?"),
    "name" : MessageLookupByLibrary.simpleMessage("name"),
    "noConnection" : MessageLookupByLibrary.simpleMessage("Please turn on your Internet connection for the application to work properly"),
    "password" : MessageLookupByLibrary.simpleMessage("password"),
    "passwordNotValid" : MessageLookupByLibrary.simpleMessage("password must contain at least 6 characters"),
    "register" : MessageLookupByLibrary.simpleMessage("register"),
    "registerWith" : MessageLookupByLibrary.simpleMessage("Register with"),
    "repeatPassword" : MessageLookupByLibrary.simpleMessage("repeat password"),
    "resetPasswordMessage" : MessageLookupByLibrary.simpleMessage("Open your e-mail client to successfully reset password"),
    "resetPasswordTitle" : MessageLookupByLibrary.simpleMessage("Password reset sent!"),
    "send" : MessageLookupByLibrary.simpleMessage("send"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "surname" : MessageLookupByLibrary.simpleMessage("surname")
  };
}
