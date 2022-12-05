
enum Resource { initial, success, error, loading,noBankAccounts}

extension RessourceX on Resource {
  bool get isInitial => this == Resource.initial;

  bool get isSuccess => this == Resource.success;

  bool get isLoading => this == Resource.loading;

  bool get isError => this == Resource.error;

  bool get noBankCards => this == Resource.noBankAccounts;

}
