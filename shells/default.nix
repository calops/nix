{pkgs, ...}: {
  "x86_64-linux".rust = pkgs.mkShell {
    buildInputs = [
      pkgs.rust-bin.beta.latest.default
    ];
  };
}
