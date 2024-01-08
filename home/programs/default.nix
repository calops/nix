{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./cli
    ./gui
  ];
}
