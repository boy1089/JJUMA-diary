

class SensorData {
  DateTime time = DateTime.now();
  double? latitude;
  double? longitude;
  double? accelX;
  double? accelY;
  double? accelZ;

  SensorData(time, latitude, longitude, accelX, accelY, accelZ) {
    this.time = time;
    this.latitude = latitude;
    this.longitude = longitude;
    this.accelX = accelX;
    this.accelY = accelY;
    this.accelZ = accelZ;
  }
}