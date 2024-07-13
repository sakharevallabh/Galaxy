class AgeCalculator {
  static int calculateAge(DateTime givenDate) {
    DateTime today = DateTime.now();
    int age = today.year - givenDate.year;
    if (today.month < givenDate.month ||
        (today.month == givenDate.month && today.day < givenDate.day)) {
      age--;
    }
    return age;
  }
}
