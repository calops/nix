{
  den.aspects.programs.provides.herdr = {
    homeManager =
      {
        config,
        colors,
        inputs',
        ...
      }:
      let
        palette = colors.palette.asHexWithHashtag;
      in
      {
        programs.herdr = {
          enable = true;
          package = inputs'.llm-agents.packages.herdr;
          settings = {
            onboarding = false;

            # Theme — follow terminal colors, override panel background
            theme.name = "terminal";
            theme.custom.panel_bg = palette.crust;

            # Notifications via system (OS notification service)
            ui.toast.delivery = "system";

            # Sound alerts when agents change state
            ui.sound.enabled = true;

            # Worktrees under XDG state directory
            worktrees.directory = "${config.xdg.stateHome}/herdr/worktrees";

            # Experimental Kitty graphics protocol
            experimental.kitty_graphics = true;

            # Vim-style split borders — shared dividers, no gaps
            ui.pane_gaps = false;

            # ── Keybindings (all defaults, explicit for customization) ──

            # Prefix
            keys.prefix = "ctrl+b";

            # Global actions
            keys.help = "prefix+?";
            keys.settings = "prefix+s";
            keys.detach = "prefix+q";
            keys.reload_config = "prefix+shift+r";
            keys.open_notification_target = "prefix+o";
            keys.remote_image_paste = "ctrl+v";

            # Workspace management
            keys.new_workspace = "prefix+shift+n";
            keys.new_worktree = "prefix+shift+g";
            keys.rename_workspace = "prefix+shift+w";
            keys.close_workspace = "prefix+shift+d";
            keys.workspace_picker = "prefix+w";
            keys.goto = "prefix+g";

            # Unset by default — bind to activate:
            # keys.open_worktree = ...;
            # keys.remove_worktree = ...;
            # keys.previous_workspace = ...;
            # keys.next_workspace = ...;

            # Navigate mode (prefix+g then these keys)
            keys.navigate_workspace_up = "up";
            keys.navigate_workspace_down = "down";
            keys.navigate_pane_left = "h";
            keys.navigate_pane_down = "j";
            keys.navigate_pane_up = "k";
            keys.navigate_pane_right = "l";

            # Tab management
            keys.new_tab = "prefix+c";
            keys.rename_tab = "prefix+shift+t";
            keys.previous_tab = "prefix+p";
            keys.next_tab = "prefix+n";
            keys.switch_tab = "prefix+1..9";
            keys.close_tab = "prefix+shift+x";

            # Unset by default — bind to activate:
            # keys.switch_workspace = ...;

            # Pane management
            keys.rename_pane = "prefix+shift+p";
            keys.edit_scrollback = "prefix+e";
            keys.copy_mode = "prefix+[";
            keys.split_vertical = "prefix+v";
            keys.split_horizontal = "prefix+minus";
            keys.close_pane = "prefix+x";
            keys.zoom = "prefix+z";
            keys.resize_mode = "prefix+r";
            keys.toggle_sidebar = "prefix+b";
            keys.cycle_pane_next = "prefix+tab";
            keys.cycle_pane_previous = "prefix+shift+tab";

            # Pane focus
            keys.focus_pane_left = "prefix+h";
            keys.focus_pane_down = "prefix+j";
            keys.focus_pane_up = "prefix+k";
            keys.focus_pane_right = "prefix+l";

            # Pane swapping
            keys.swap_pane_left = "prefix+shift+h";
            keys.swap_pane_down = "prefix+shift+j";
            keys.swap_pane_up = "prefix+shift+k";
            keys.swap_pane_right = "prefix+shift+l";

            # Agent focus — unset by default:
            # keys.previous_agent = ...;
            # keys.next_agent = ...;
            # keys.focus_agent = "prefix+alt+1..9";

            # Indexed shortcuts — unset by default:
            # keys.indexed.tabs = ...;       # modifier for tab shortcuts 1-9
            # keys.indexed.workspaces = ...; # modifier for workspace shortcuts 1-9
            # keys.indexed.agents = ...;     # modifier for agent shortcuts 1-9

            # Cross-workspace pane focus — unset by default:
            # keys.last_pane = ...;
          };
        };
      };
  };
}
