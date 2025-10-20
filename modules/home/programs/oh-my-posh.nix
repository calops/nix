{
  config,
  ...
}:
let
  palette = config.my.colors.palette.asHexWithHashtag;

  defaultSegmentOpts = {
    background = palette.surface0;
    style = "diamond";
  };

  defaultRightSegmentOpts = defaultSegmentOpts // {
    leading_diamond = " ";
    trailing_diamond = "";
  };

  defaultLeftSegmentOpts = defaultSegmentOpts // {
    leading_diamond = "";
    trailing_diamond = " ";
  };

  mkRightSegment = opts: defaultRightSegmentOpts // opts;
  mkLeftSegment = opts: defaultLeftSegmentOpts // opts;
in
{
  config = {
    programs.oh-my-posh = {
      enable = true;
      settings = {
        version = 3;
        final_space = false;
        shell_integration = true;
        async = true;
        blocks = [
          {
            alignment = "left";
            type = "prompt";
            newline = true;
            segments = builtins.map mkLeftSegment [
              {
                type = "session";
                foreground = palette.text;
                foreground_templates = [
                  "{{if .SSHSession }}${palette.peach}{{end}}"
                  "{{if .Root }}${palette.red}{{end}}"
                ];
                template = builtins.concatStringsSep "" [
                  "{{ if or .SSHSession .Root }} {{ .UserName }}{{ end }}"
                  "{{ if .SSHSession }}  {{ .Hostname }}{{end}}"
                ];
              }
              {
                type = "path";
                foreground = palette.turquoise;
                properties = {
                  style = "agnoster_full";
                  right_format = "<${palette.mint}><b>%s</b></>";
                  gitdir_format = "<${palette.teal}><b>%s</b></>";
                };
                template = " {{ .Path }}";
              }
              {
                type = "git";
                foreground = palette.turquoise;
                foreground_templates = [
                  "{{ if or (.Working.Changed) (.Staging.Changed) }}${palette.tangerine}{{ end }}"
                  "{{ if and (gt .Ahead 0) (gt .Behind 0) }}${palette.cherry}{{ end }}"
                  "{{ if gt .Ahead 0 }}${palette.violet}{{ end }}"
                  "{{ if gt .Behind 0 }}${palette.mauve}{{ end }}"
                ];
                properties = {
                  branch_template = "{{ trunc 25 .Branch }}";
                  fetch_status = true;
                  fetch_upstream_icon = true;
                  git_icon = "";
                  branch_icon = "";
                  branch_identical_icon = "";
                  branch_ahead_icon = " ";
                  branch_behind_icon = " ";
                  branch_gone_icon = "";
                  github_icon = "";
                };
                template = builtins.concatStringsSep "" [
                  "{{ .UpstreamIcon }} {{ .HEAD }}"
                  "{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}"
                  "{{ if gt .StashCount 0 }} <${palette.purple}> {{ .StashCount }}</>{{ end }}"
                  "{{ if .Staging.Changed }} <${palette.green}> {{ add add add .Staging.Added .Staging.Modified .Staging.Deleted }}</>{{ end }}"
                  "{{ if .Working.Changed }} <${palette.sand}> {{ add add add .Working.Untracked .Working.Modified .Working.Deleted }}</>{{ end }}"
                ];
              }
            ];
          }
          {
            alignment = "right";
            type = "prompt";
            segments = builtins.map mkRightSegment [
              {
                type = "nix-shell";
                foreground = palette.blue;
                template = "{{ if .Env.name }} {{ if eq .Type \"pure\" }} {{ end }}{{ .Env.name }}{{ end }}";
              }
              {
                type = "python";
                foreground = palette.yellow;
                template = builtins.concatStringsSep "" [
                  " {{ .Full }}"
                  "{{ if .Venv }} ({{ .Venv }}){{ end }}"
                ];
              }
              {
                type = "lua";
                foreground = palette.teal;
                template = " {{ .Major }}.{{ .Minor }}";
              }
            ];
          }
          {
            alignment = "left";
            type = "prompt";
            newline = true;
            segments = [
              {
                type = "shell";
                properties.mapped_shell_names = {
                  fish = " ";
                  nu = " ";
                };
              }
              {
                type = "executiontime";
                foreground = palette.overlay0;
                properties = {
                  style = "austin";
                  threshold = 300;
                };
                template = " {{ .FormattedMs }} ";
              }
              {
                type = "status";
                foreground = palette.red;
                template = " {{ .String }} ";
              }
              {
                type = "text";
                foreground = palette.green;
                template = "❯ ";
              }
            ];
          }
        ];
      };
    };
  };
}
