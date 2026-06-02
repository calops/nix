{
  den,
  lib,
  ...
}:
{
  systems = builtins.attrNames den.hosts;

  den.schema.flake-system.includes = [
    {
      into.host = { system }: lib.attrValues (den.hosts.${system} or { }) |> (host: { inherit host; });
    }
  ];

  perSystem =
    { pkgs, ... }:
    let
      update-flake = pkgs.writeShellApplication {
        name = "update-flake";
        runtimeInputs = [
          pkgs.gh
          pkgs.jq
        ];
        text =
          # shell
          ''
            set -euo pipefail

            PR=$(gh pr list --head update-flake-inputs --state open --json number,isDraft,title,url --jq '.[0]' 2>/dev/null || echo "")

            if [ -z "$PR" ] || [ "$PR" = "null" ]; then
              echo "No pending flake update PR found."
              exit 0
            fi

            PR_NUM=$(echo "$PR" | jq -r '.number')
            PR_DRAFT=$(echo "$PR" | jq -r '.isDraft')
            PR_TITLE=$(echo "$PR" | jq -r '.title')
            PR_URL=$(echo "$PR" | jq -r '.url')

            if [ "$PR_DRAFT" = "true" ]; then
              echo "Found draft PR #$PR_NUM: $PR_TITLE"
              echo "$PR_URL"
              echo "Cannot merge a draft PR. Wait for CI to mark it ready."
              exit 1
            fi

            echo "Merging PR #$PR_NUM: $PR_TITLE"
            echo "$PR_URL"
            gh pr merge "$PR_NUM" --squash --delete-branch
            echo "Flake update merged successfully."
          '';
      };
    in
    {
      formatter = pkgs.nixfmt;

      devShells.default = pkgs.mkShell {
        name = "calops-flake";

        NIX_CONFIG = ''
          extra-experimental-features = flakes nix-command pipe-operators
          extra-substituters = https://cache.nixos.org https://calops.cachix.org https://nix-community.cachix.org https://anyrun.cachix.org https://niri.cachix.org https://nix-darwin.cachix.org
          extra-trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= calops.cachix.org-1:6RTG80il2oS2ECFeG2QubG+mvD9OJc1s6Lm9JGAFcM0= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s= niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964= nix-darwin.cachix.org-1:LxMyKzQk7Uqkc1Pfq5uhm9GSn07xkERpy+7cpwc006A=
        '';

        buildInputs = [
          pkgs.gh
          update-flake
        ];
      };
    };
}
