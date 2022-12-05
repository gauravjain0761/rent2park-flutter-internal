extension DurationExtension on Duration {
  String get reservationFormattedDuration {
    var seconds = inSeconds;

    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;

    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;

    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
  /*  if (days != 0) {
      if (days >= 10)
        tokens.add('${days}d');
      else
        tokens.add('0${days}d');
    }*/

    if (tokens.isNotEmpty || hours != 0) {
      if (hours >= 10)
        tokens.add('${hours}h');
      else
        tokens.add('0${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      if (minutes >= 10)
        tokens.add('${minutes}m');
      else
        tokens.add('0${minutes}m');
    }
    return tokens.join(' : ');
  }
}
