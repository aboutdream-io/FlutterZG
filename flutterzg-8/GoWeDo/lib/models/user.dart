class User {
  User.fromApi(Map<String, dynamic> apiUser):
    id = apiUser['id'],
    clientId = apiUser['client_id'],
    firstName = apiUser['first_name'],
    lastName = apiUser['last_name'],
    email = apiUser['email'],
    street = apiUser['street'],
    city = apiUser['city'],
    postCode = apiUser['post_code'],
    country = apiUser['country'],
    phoneNumber = apiUser['numbers'] != null && apiUser['numbers'][0] != null ? apiUser['numbers'][0]['phone_number'] : apiUser['phone_number'];

  final int id;
  final int clientId;
  String firstName;
  String lastName;
  String email;
  String street;
  String city;
  String postCode;
  String country;
  String phoneNumber;

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'id': id,
      'client_id': clientId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'street': street,
      'city': city,
      'post_code': postCode,
      'country': country,
      'phone_number': phoneNumber
    };
  }
}
