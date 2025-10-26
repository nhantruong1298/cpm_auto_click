
bool checkValidGPSDate(
    {required DateTime? gpsDate,
    required DateTime start,
    required DateTime end}) {
  if (gpsDate == null) return false;

  return gpsDate.compareTo(start) >= 0 && gpsDate.compareTo(end) <= 0;
}
