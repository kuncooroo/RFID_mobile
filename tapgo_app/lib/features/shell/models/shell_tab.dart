/// Bottom-nav tabs owned by the main shell.
enum ShellTab {
  home,
  orders,
  favorites,
  profile;

  int get branchIndex => index;

  static ShellTab fromIndex(int index) {
    if (index < 0 || index >= values.length) return ShellTab.home;
    return values[index];
  }
}
