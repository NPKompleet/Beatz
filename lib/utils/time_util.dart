class TimeUtil {
  /// Converts the duration in milliseconds to the format
  /// HH:mm:ss if duration is more than hour else
  /// use mm:ss
  static String convertTimeToString(int duration) {
    int seconds = duration ~/ 1000;
    String time = Duration(seconds: seconds).toString().split(".")[0];
    if (seconds / 3600 >= 60) {
      return time;
    }
    final list = time.split(":");
    return "${list[1]}:${list[2]}";
  }
}
