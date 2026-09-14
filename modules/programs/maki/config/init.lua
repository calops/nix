-- Maki user config. This directory is symlinked out of the Nix store, so
-- edits here are picked up by /reload with no rebuild.
--
-- Plugins live in lua/<name>.lua and are loaded with require("<name>").
-- External packages are declared with maki.pack.add at the bottom of this file;
-- they load on their own and are pinned in pack-lock.json.
--
-- Docs: https://maki.sh/docs/configuration/
-- API:  https://maki.sh/docs/lua-api/

maki.setup({
  ui = {
    show_thinking = false,
  },
  -- provider = { default_model = "openai/gpt-5.3-codex" },
})

-- /review: inline-comment review of the working tree, sent to a new session.
-- Vendored verbatim from https://github.com/Asaf51/maki-review @ 4a38baa,
-- because that repo ships a single review.lua rather than the plugin/ +
-- plugin.toml layout maki.pack.add requires. Needs the `run` permission,
-- granted in plugin.toml.
require("review")

-- /blit <path?>: renders an image as half-block cells (Buf:blit). No argument
-- draws a generated test pattern.
require("blit_demo")

-- Herdr (https://herdr.dev): reports this pane's agent state (idle / working /
-- blocked) from maki's own event stream, so Herdr stops scraping the status bar
-- for it, plus the herdr-link/1 cross-agent gateway and /herdr.
-- Managed package: https://github.com/calops/herdr.maki
maki.pack.add({
  { src = "https://github.com/calops/herdr.maki" },
})
