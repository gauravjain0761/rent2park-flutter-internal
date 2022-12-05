enum UserType { driver, host, none }

extension UserTypeNameExtension on UserType {

  String get humanReadableName {
    switch (this) {
      case UserType.driver:
        return 'Driver';
      case UserType.host:
        return 'Host';
      default:
        return 'None';
    }
  }
}

extension UserTypeExtension on String {
  UserType get userType {
    switch (this) {
      case 'Host':
        return UserType.host;
      case 'Driver':
        return UserType.driver;
      default:
        return UserType.none;
    }
  }
}
