{ lib }:
{
  mkGraphicalSessionService =
    { description, command }:
    {
      Unit = {
        Description = description;
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = command;
        Restart = "on-failure";
        KillMode = "mixed";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

  replaceTrayIcons =
    pkg:
    {
      pkgs,
      icons,
      iconTheme ? pkgs.papirus-icon-theme,
      themePath ? "share/icons",
    }:
    pkgs.symlinkJoin {
      inherit (pkg) name pname meta;
      paths = [ pkg ];
      nativeBuildInputs = [
        pkgs.superrsvg
        pkgs.asar
      ];
      postBuild = ''
        set -euo pipefail
        shopt -s nullglob

        ICON_THEME="${iconTheme}/${themePath}"

        get_icon() {
          local name="$1"
          local svg=$(find "$ICON_THEME" -name "$name.svg" | head -n 1)
          if [ -z "$svg" ]; then
            echo "Icon $name not found in theme $ICON_THEME!" >&2
            exit 1
          fi
          echo "$svg"
        }

        declare -A unpacked_asars

        ${lib.concatMapStringsSep "\n" (
          icon:
          let
            size = toString (icon.size or 24);
            target = icon.file;
            iconName = icon.icon;
            asar = icon.asar or "";
          in
          if asar != "" then
            ''
              asar_path="$out/${asar}"
              if [ ! -v "unpacked_asars['${asar}']" ]; then
                if [ -L "$asar_path" ]; then
                  rm "$asar_path"
                else
                  echo "Warning: ASAR $asar_path not found as symlink!" >&2
                fi

                tmp_asar="$(mktemp -d)"
                export unpacked_asars['${asar}']="$tmp_asar"

                asar extract "${pkg}/${asar}" "$tmp_asar"
              fi

              tmp_asar="''${unpacked_asars['${asar}']}"
              svg_path=$(get_icon "${iconName}")

              mkdir -p "$(dirname "$tmp_asar/${target}")"
              rsvg-convert -w ${size} -h ${size} -f png "$svg_path" > "$tmp_asar/${target}"
              echo "Replaced ${target} in ${asar} with ${iconName}"
            ''
          else
            ''
              target_path="$out/${target}"
              if [ -L "$target_path" ]; then
                rm "$target_path"
              fi

              svg_path=$(get_icon "${iconName}")
              mkdir -p "$(dirname "$target_path")"

              rsvg-convert -w ${size} -h ${size} -f png "$svg_path" > "$target_path"
              echo "Replaced ${target} with ${iconName}"
            ''
        ) icons}
        for asar in "''${!unpacked_asars[@]}"; do
          tmp_asar="''${unpacked_asars[$asar]}"
          asar pack "$tmp_asar" "$out/$asar"
          rm -r "$tmp_asar"
          echo "Repacked $asar"
        done
      '';
    };
}
