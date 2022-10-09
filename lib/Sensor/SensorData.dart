

class SensorData {
  DateTime time = DateTime.now();
  double? latitude;
  double? longitude;
  double? accelX;
  double? accelY;
  double? accelZ;
  double? light;
  double? temperature;
  double? proximity;
  double? humidity;

  SensorData(time, latitude, longitude, accelX, accelY, accelZ, light, temperature, proximity, humidity) {
    this.time = time;
    this.latitude = latitude;
    this.longitude = longitude;
    this.accelX = accelX;
    this.accelY = accelY;
    this.accelZ = accelZ;
    this.light = light;
    this.temperature = temperature;
    this.proximity = proximity;
    this.humidity = humidity;
  }
}