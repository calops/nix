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
			Herdr.priority = 50

			local function herdr_json(args)
				local out = vim.trim(vim.fn.system(vim.list_extend({ "herdr" }, args)))
				if vim.v.shell_error ~= 0 or out == "" then
					return nil
				end
				local ok, result = pcall(vim.fn.json_decode, out)
				return ok and result or nil
			end

			local function attach_cmd(self)
				if self.herdr_terminal_id then
					return { cmd = { "herdr", "terminal", "attach", self.herdr_terminal_id } }
				end
			end

			function Herdr:init()
				self.is_running = function(s)
					return s.herdr_pane_id and herdr_json { "pane", "get", s.herdr_pane_id } ~= nil
				end
			end

			function Herdr:start()
				local Util = require("sidekick.util")
				local r =
					herdr_json { "workspace", "create", "--cwd", self.cwd, "--label", self.tool.name, "--no-focus" }
				if not (r and r.result and r.result.root_pane) then
					Util.error("herdr: failed to create workspace")
					return nil
				end

				local pid = r.result.root_pane.pane_id
				self.id = pid
				self.herdr_pane_id = pid
				self.mux_session = r.result.workspace.workspace_id
				self.started = true
				self.mux_backend = "herdr"

				local cmd = table.concat(vim.tbl_map(vim.fn.shellescape, self.tool.cmd), " ")
				herdr_json { "pane", "run", pid, cmd }

				local pi = herdr_json { "pane", "get", pid }
				if pi and pi.result and pi.result.pane then
					self.herdr_terminal_id = pi.result.pane.terminal_id
				end

				Util.info(("Started **%s** in herdr workspace"):format(self.tool.name))
				return attach_cmd(self)
			end

			function Herdr:attach() return attach_cmd(self) end

			function Herdr:send(text)
				if self.herdr_pane_id then
					vim.fn.system { "herdr", "pane", "send-text", self.herdr_pane_id, text }
				end
			end

			function Herdr:submit()
				if self.herdr_pane_id then
					vim.fn.system { "herdr", "pane", "send-keys", self.herdr_pane_id, "enter" }
				end
			end

			function Herdr.sessions()
				local tools = require("sidekick.config").tools()
				local r = herdr_json { "pane", "list" }
				if not (r and r.result and r.result.panes) then
					return {}
				end

				local ret = {}
				local Procs = require("sidekick.cli.procs")
				local procs = Procs.new()

				for _, pane in ipairs(r.result.panes) do
					local pi = herdr_json { "pane", "process-info", "--pane", pane.pane_id }
					if pi and pi.result and pi.result.process_info then
						local info = pi.result.process_info
						local pid = (
							info.foreground_processes
							and info.foreground_processes[1]
							and info.foreground_processes[1].pid
						) or info.shell_pid
						if pid then
							local cwd = (
								info.foreground_processes
								and info.foreground_processes[1]
								and info.foreground_processes[1].cwd
							) or pane.cwd
							procs:walk(pid, function(proc)
								for _, tool in pairs(tools) do
									if tool:is_proc(proc) then
										ret[#ret + 1] = {
											id = pane.pane_id,
											cwd = cwd,
											tool = tool,
											herdr_pane_id = pane.pane_id,
											herdr_terminal_id = pane.terminal_id,
											mux_session = pane.workspace_id,
											pids = Procs.pids(pid),
										}
										return true
									end
								end
							end)
						end
					end
				end

				return ret
			end

			if vim.fn.executable("herdr") == 1 then
				local ok, session = pcall(require, "sidekick.cli.session")
				if ok then
					session.register("herdr", Herdr)
				end
			end

			-- Validation runs inside vim.schedule() in Config.setup() —
			-- patch must stay active until that async callback fires.
			local config = require("sidekick.config")
			local _validate = config.validate
			config.validate = function(key, t)
				if key == "cli.mux.backend" then
					t = vim.list_extend(vim.deepcopy(t), { "herdr" })
				end
				return _validate(key, t)
			end
			require("sidekick").setup(opts)
			vim.schedule(function() config.validate = _validate end)
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
