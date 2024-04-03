{pkgs, ...}: {
  users.users.rlabeyrie = {
    home = "/Users/rlabeyrie";
    shell = pkgs.fish;
  };
}
