{
  home = {
    username = "user";
    homeDirectory = "/home/user";
  };

  my.roles = {
    terminal = {
      enable = true;
      ssh.hosts = {
        charybdis = {
          hostname = "192.168.1.10";
          user = "rlabeyrie";
          port = 23;
        };
        charybdis-remote = {
          hostname = "charybdis.stockly.tech";
          user = "rlabeyrie";
          port = 23;
        };
      };
    };
    graphical = {
      enable = true;
      fonts.hinting = "HorizontalLcd";
      monitors = {
        primary.name = "HDMI-0";
        secondary = {
          name = "eDP-1";
          position = "left";
        };
      };
    };
  };
}
