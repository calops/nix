return {
	{
		"milanglacier/minuet-ai.nvim",
		event = "InsertEnter",
		opts = {
			provider = "openai_compatible",
			request_timeout = 2.5,
			throttle = 200,
			debounce = 200,
			virtualtext = {
				auto_trigger_ft = {},
				keymap = {
					accept = "<M-Cr>",
					accept_line = "<M-l>",
					accept_n_lines = "<M-z>",
					prev = "<M-[>",
					next = "<M-space>",
					dismiss = "<M-e>",
				},
			},
			provider_options = {
				openai_compatible = {
					api_key = function()
						local handle = io.popen('op-credential --raw "OpenCode GO" 2>/dev/null')
						if handle then
							local result = handle:read("*a")
							handle:close()
							return (result or ""):gsub("%s+$", "")
						end
						return ""
					end,
					end_point = "https://opencode.ai/zen/go/v1/chat/completions",
					model = "deepseek-v4-flash",
					name = "Opencode",
					optional = {
						max_tokens = 56,
						top_p = 0.9,
						thinking = { type = "disabled" },
					},
				},
			},
		},
	},
	{
		"folke/sidekick.nvim",
		event = "VeryLazy",
		config = function(_, opts)
			-- ── Herdr mux backend ──────────────────────────────────────
			local Herdr = {}
			Herdr.__index = Herdr

			local function herdr_json(args)
				local cmd = { "herdr" }
				vim.list_extend(cmd, args)
				local out = vim.trim(vim.fn.system(cmd))
				if vim.v.shell_error ~= 0 or out == "" then
					return nil
				end
				local ok, result = pcall(vim.fn.json_decode, out)
				return ok and result or nil
			end

			Herdr.priority = 50
			Herdr.external = false

			function Herdr:init()
				if vim.env.HERDR_PANE_ID then
					self.external = true
				end
			end

			function Herdr:start()
				local Util = require("sidekick.util")
				local result = herdr_json {
					"workspace",
					"create",
					"--cwd",
					self.cwd,
					"--label",
					self.tool.name,
					"--no-focus",
				}
				if not result or not result.result or not result.result.root_pane then
					Util.error("herdr: failed to create workspace for " .. self.tool.name)
					return nil
				end

				local pane_id = result.result.root_pane.pane_id
				local ws_id = result.result.workspace.workspace_id

				-- Build a shell-safe command string
				local parts = {}
				for _, a in ipairs(self.tool.cmd) do
					parts[#parts + 1] = vim.fn.shellescape(a)
				end
				local cmd_str = table.concat(parts, " ")
				herdr_json { "pane", "run", pane_id, cmd_str }

				self.id = pane_id
				self.herdr_pane_id = pane_id
				self.mux_session = ws_id
				self.started = true
				self.mux_backend = "herdr"

				Util.info(("Started **%s** in herdr workspace"):format(self.tool.name))
				return nil -- external session — use herdr CLI directly, no nvim terminal
			end

			function Herdr:attach() return nil end

			function Herdr:send(text)
				if not self.herdr_pane_id then
					return
				end
				vim.fn.system { "herdr", "pane", "send-text", self.herdr_pane_id, text }
			end

			function Herdr:submit()
				if not self.herdr_pane_id then
					return
				end
				vim.fn.system { "herdr", "pane", "send-keys", self.herdr_pane_id, "enter" }
			end

			function Herdr:is_running()
				if not self.herdr_pane_id then
					return false
				end
				return herdr_json { "pane", "get", self.herdr_pane_id } ~= nil
			end

			function Herdr.sessions()
				local Config = require("sidekick.config")
				local Util = require("sidekick.util")
				local tools = Config.tools()

				local result = herdr_json { "pane", "list" }
				if not result or not result.result then
					return {}
				end

				local ret = {}
				local Procs = require("sidekick.cli.procs")
				local procs = Procs.new()

				for _, pane in ipairs(result.result) do
					local info = herdr_json { "pane", "process-info", "--pane", pane.pane_id }
					if info and info.result and info.result.pid then
						local pid = info.result.pid
						procs:walk(pid, function(proc)
							for _, tool in pairs(tools) do
								if tool:is_proc(proc) then
									ret[#ret + 1] = {
										id = pane.pane_id,
										cwd = proc.cwd or pane.cwd or vim.fn.getcwd(),
										tool = tool,
										herdr_pane_id = pane.pane_id,
										mux_session = pane.workspace_id,
										pids = Procs.pids(pid),
									}
									return true
								end
							end
						end)
					end
				end

				return ret
			end

			-- Register before session.setup() runs (it's lazy, called on first use).
			-- session.register() sets the correct metatable chain.
			if vim.fn.executable("herdr") == 1 then
				local ok, session = pcall(require, "sidekick.cli.session")
				if ok then
					session.register("herdr", Herdr)
				end
			end

			require("sidekick").setup(opts)
		end,
		keys = {
			{
				"<c-;>",
				function() require("sidekick.cli").toggle { focus = true } end,
				desc = "Sidekick Toggle CLI",
				mode = { "n", "v", "t" },
			},
			{
				"<leader>ap",
				function() require("sidekick.cli").prompt() end,
				desc = "Sidekick Ask Prompt",
				mode = { "n", "v" },
			},
			{
				"<leader>at",
				function() require("sidekick.cli").send { msg = "{this}" } end,
				mode = { "x", "n" },
				desc = "Send this",
			},
		},
		opts = {
			cli = {
				win = {
					layout = "float",
					float = { border = "rounded" },
				},
				mux = {
					backend = "herdr",
					enabled = true,
				},
				tools = {
					oh_my_pi = {
						cmd = { "omp" },
						is_proc = "\\<omp\\>",
						native_scroll = false,
					},
				},
			},
		},
	},
}
