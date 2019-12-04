class RegisterDeviceData {
  RegisterDeviceData.fromApi(Map<String, dynamic> apiRegisterDeviceData):
      this.id = apiRegisterDeviceData['id'],
      this.registrationId = apiRegisterDeviceData['registration_id'],
      this.deviceId = apiRegisterDeviceData['device_id'];

  int id;
  String registrationId;
  String deviceId;

  Map<String, dynamic> toMap(){
    return <String, dynamic>{
      'id': id,
      'registration_id': registrationId,
      'device_id': deviceId
    };
  }
}
