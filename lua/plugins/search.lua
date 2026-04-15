local function current_buffer_dir_or_cwd()
	if vim.bo.filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		if ok then
			local oil_dir = oil.get_current_dir(0)
			if oil_dir and oil_dir ~= "" then
				return oil_dir
			end
		end
	end

	local buf_path = vim.api.nvim_buf_get_name(0)
	if buf_path == "" then
		return vim.fn.getcwd()
	end

	local dir = vim.fs.dirname(buf_path)
	if dir == nil or dir == "" then
		return vim.fn.getcwd()
	end

	return dir
end

return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		cmd = "Telescope",
		keys = {
			{
				"<leader>pf",
				function()
					require("telescope.builtin").find_files({
						find_command = {
							"rg",
							"--files",
							"--hidden",
							"--no-require-git",
							"-g",
							"!.git",
							"-g",
							"!.jj",
						},
					})
				end,
				desc = "Find files (incl. hidden)",
			},
			{
				"<leader>pF",
				function()
					require("telescope.builtin").find_files({
						cwd = current_buffer_dir_or_cwd(),
						find_command = {
							"rg",
							"--files",
							"--hidden",
							"--no-require-git",
							"-g",
							"!.git",
							"-g",
							"!.jj",
						},
					})
				end,
				desc = "Find files near current buffer",
			},
			{
				"<C-p>",
				function()
					local ok = pcall(function()
						require("telescope").extensions.jj.files()
					end)
					if not ok then
						require("telescope.builtin").git_files()
					end
				end,
				desc = "Find files (jj/git)",
			},
			{
				"<leader>/",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live grep in project",
			},
			{
				"<leader>ss",
				function()
					require("telescope.builtin").live_grep({ cwd = current_buffer_dir_or_cwd() })
				end,
				desc = "Live grep near current buffer",
			},
			{
				"<leader>*",
				function()
					require("telescope.builtin").grep_string()
				end,
				desc = "Grep word under cursor",
			},
			{
				"<leader>bb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "List buffers",
			},
			{
				"<leader>sd",
				function()
					require("telescope.builtin").lsp_document_symbols()
				end,
				desc = "Show symbols in document",
			},
			{
				"<leader>ps",
				function()
					require("telescope.builtin").lsp_dynamic_workspace_symbols()
				end,
				desc = "Workspace symbols",
			},
			{
				"gr",
				function()
					require("telescope.builtin").lsp_references()
				end,
				desc = "Go to references",
			},
			{
				"gi",
				function()
					require("telescope.builtin").lsp_implementations()
				end,
				desc = "Go to implementations",
			},
			{
				"<leader>Tt",
				function()
					require("telescope.builtin").colorscheme({ enable_preview = true })
				end,
				desc = "Theme picker",
			},
			{
				"<leader><leader>",
				function()
					require("telescope.builtin").commands()
				end,
				desc = "Command palette",
			},
			{
				"<leader>?",
				function()
					require("telescope.builtin").keymaps()
				end,
				desc = "Search keymaps",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"zschreur/telescope-jj.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local telescope_actions = require("telescope.actions")
			local ok_trouble, trouble = pcall(require, "trouble.sources.telescope")

			local mappings = {
				i = {},
				n = {
					["J"] = telescope_actions.results_scrolling_down,
					["K"] = telescope_actions.results_scrolling_up,
					["gg"] = telescope_actions.move_to_top,
					["G"] = telescope_actions.move_to_bottom,
				},
			}
			if ok_trouble then
				mappings.i["<c-t>"] = trouble.open
				mappings.n["<c-t>"] = trouble.open
			end

			telescope.setup({
				defaults = vim.tbl_deep_extend("force", require("telescope.themes").get_ivy({}), {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--no-require-git",
					},
					results_title = false,
					selection_caret = "▶ ",
					entry_prefix = "  ",
					mappings = mappings,
				}),
				pickers = {
					buffers = {
						mappings = {
							i = {
								["<c-d>"] = telescope_actions.delete_buffer + telescope_actions.move_to_top,
							},
						},
					},
				},
			})

			pcall(telescope.load_extension, "jj")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
		config = function()
			local nvim_treesitter = require("nvim-treesitter")
			local move = require("nvim-treesitter-textobjects.move")
			local select = require("nvim-treesitter-textobjects.select")
			local swap = require("nvim-treesitter-textobjects.swap")

			local function register_org_parser()
				require("nvim-treesitter.parsers").org = {
					install_info = {
						url = "https://github.com/milisims/tree-sitter-org",
						revision = "main",
						files = { "src/parser.c", "src/scanner.c" },
					},
					filetype = "org",
					tier = 2,
				}
			end

			local installing = {}
			local install_waiters = {}

			local function get_lang(bufnr)
				local filetype = vim.bo[bufnr].filetype
				local ok, lang = pcall(vim.treesitter.language.get_lang, filetype)
				if not ok or not lang or lang == "" then
					return nil
				end
				return lang
			end

			local function parser_installed(lang)
				return vim.tbl_contains(nvim_treesitter.get_installed("parsers"), lang)
			end

			local function ensure_parsers_installed(languages, on_done)
				if vim.fn.executable("tree-sitter") ~= 1 then
					return
				end

				local parsers = require("nvim-treesitter.parsers")
				local missing = {}
				local waiting_for_install = false
				for _, lang in ipairs(languages) do
					if parsers[lang] ~= nil and not parser_installed(lang) then
						waiting_for_install = true
						if on_done ~= nil then
							install_waiters[lang] = install_waiters[lang] or {}
							table.insert(install_waiters[lang], on_done)
						end
						if not installing[lang] then
							installing[lang] = true
							table.insert(missing, lang)
						end
					end
				end

				if #missing == 0 then
					if not waiting_for_install and on_done ~= nil then
						on_done()
					end
					return
				end

				local task = nvim_treesitter.install(missing)
				task:await(function()
					vim.schedule(function()
						for _, lang in ipairs(missing) do
							installing[lang] = nil
							local callbacks = install_waiters[lang] or {}
							install_waiters[lang] = nil
							if parser_installed(lang) then
								for _, callback in ipairs(callbacks) do
									callback()
								end
							end
						end
					end)
				end)
			end

			local function start_treesitter(bufnr, lang)
				local started = pcall(vim.treesitter.start, bufnr, lang)
				if started and vim.bo[bufnr].filetype == "org" then
					vim.bo[bufnr].syntax = "ON"
				end
			end

			register_org_parser()

			local group = vim.api.nvim_create_augroup("jorge_treesitter", { clear = true })

			vim.api.nvim_create_autocmd("User", {
				group = group,
				pattern = "TSUpdate",
				callback = register_org_parser,
			})

			nvim_treesitter.setup()

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				callback = function(args)
					local lang = get_lang(args.buf)
					if lang == nil then
						return
					end

					if parser_installed(lang) then
						start_treesitter(args.buf, lang)
						return
					end

					ensure_parsers_installed({ lang }, function()
						if not vim.api.nvim_buf_is_valid(args.buf) then
							return
						end

						if get_lang(args.buf) == lang and parser_installed(lang) then
							start_treesitter(args.buf, lang)
						end
					end)
				end,
			})

			require("nvim-treesitter-textobjects").setup({
				select = {
					lookahead = true,
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<c-v>",
					},
					include_surrounding_whitespace = true,
				},
				move = {
					set_jumps = true,
				},
			})

			local function map(modes, lhs, rhs, desc)
				vim.keymap.set(modes, lhs, rhs, { desc = desc })
			end

			map({ "x", "o" }, "af", function()
				select.select_textobject("@function.outer", "textobjects")
			end, "Select function")
			map({ "x", "o" }, "if", function()
				select.select_textobject("@function.inner", "textobjects")
			end, "Select inner function")
			map({ "x", "o" }, "ac", function()
				select.select_textobject("@class.outer", "textobjects")
			end, "Select class")
			map({ "x", "o" }, "ic", function()
				select.select_textobject("@class.inner", "textobjects")
			end, "Select inner class")
			map({ "x", "o" }, "as", function()
				select.select_textobject("@local.scope", "locals")
			end, "Select language scope")

			map("n", "<leader>J", function()
				swap.swap_next("@parameter.inner", "textobjects")
			end, "Swap next parameter")
			map("n", "<leader>K", function()
				swap.swap_previous("@parameter.inner", "textobjects")
			end, "Swap previous parameter")

			map({ "n", "x", "o" }, "]f", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, "Next function")
			map({ "n", "x", "o" }, "]c", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, "Next class")
			map({ "n", "x", "o" }, "]l", function()
				move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
			end, "Next loop")
			map({ "n", "x", "o" }, "]s", function()
				move.goto_next_start("@local.scope", "locals")
			end, "Next scope")
			map({ "n", "x", "o" }, "]z", function()
				move.goto_next_start("@fold", "folds")
			end, "Next fold")
			map({ "n", "x", "o" }, "]F", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, "Next function end")
			map({ "n", "x", "o" }, "]C", function()
				move.goto_next_end("@class.outer", "textobjects")
			end, "Next class end")
			map({ "n", "x", "o" }, "[f", function()
				move.goto_previous_start("@function.outer", "textobjects")
			end, "Previous function")
			map({ "n", "x", "o" }, "[c", function()
				move.goto_previous_start("@class.outer", "textobjects")
			end, "Previous class")
			map({ "n", "x", "o" }, "[s", function()
				move.goto_previous_start("@local.scope", "locals")
			end, "Previous scope")
			map({ "n", "x", "o" }, "[F", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, "Previous function end")
			map({ "n", "x", "o" }, "[C", function()
				move.goto_previous_end("@class.outer", "textobjects")
			end, "Previous class end")
			map({ "n", "x", "o" }, "]i", function()
				move.goto_next("@conditional.outer", "textobjects")
			end, "Next conditional")
			map({ "n", "x", "o" }, "[i", function()
				move.goto_previous("@conditional.outer", "textobjects")
			end, "Previous conditional")

			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},
	{
		"acarapetis/nvim-treesitter-jjconfig",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		lazy = false,
		opts = { ensure_installed = true },
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = true,
	},
	{
		"windwp/nvim-ts-autotag",
		lazy = true,
	},
}
