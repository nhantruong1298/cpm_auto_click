sealed class HomeViewState {
  const HomeViewState();
}

final class HomeViewInitial extends HomeViewState {}

final class HomeViewLoading extends HomeViewState {}

final class HomeViewSuccess extends HomeViewState {
  final List<String> tabs;
  final bool showConfirmOpenTabs;

  const HomeViewSuccess(this.tabs, {this.showConfirmOpenTabs = true});
}

final class HomeViewError extends HomeViewState {
  final String message;

  const HomeViewError(this.message);
}
