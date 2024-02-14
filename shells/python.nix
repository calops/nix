{pkgs, ...}: {
  languages.python = {
    enable = true;
    poetry.enable = true;
    venv.enable = true;
  };

  packages = with pkgs.python3Packages; [
    pip
  ];
}
