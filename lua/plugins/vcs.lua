return {
	{ "nvim-lua/plenary.nvim" },
	-- JJ (Jujutsu) plugins
	{
		"NicolasGB/jj.nvim",
		version = "*",
		config = function()
			local jj = require("jj")
			jj.setup({
				diff = {
					backend = "diffview",
				},
			})

			local function reapply_jj_highlights()
				require("jj.cmd.log").init_log_highlights()

				local editor_hl = jj.config and jj.config.highlights and jj.config.highlights.editor
				if editor_hl and editor_hl.renamed then
					vim.api.nvim_set_hl(0, "jjRenamed", editor_hl.renamed)
				end
			end

			local group = vim.api.nvim_create_augroup("JjNvimHighlights", { clear = true })
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = group,
				callback = reapply_jj_highlights,
			})
		end,
	},
	{
		"sindrets/diffview.nvim",
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
			"DiffviewFileHistory",
		},
		config = function()
			local diffview_jj = require("jorge.diffview_jj")

			require("diffview").setup({
				hooks = diffview_jj.hooks(),
			})
			diffview_jj.setup()
		end,
	},
	{
		"julienvincent/hunk.nvim",
		cmd = { "DiffEditor" },
		dependencies = { "MunifTanjim/nui.nvim" },
		config = function()
			require("hunk").setup()
		end,
	},
	{
		"zschreur/telescope-jj.nvim",
		lazy = true,
	},
	{
		"rafikdraoui/jj-diffconflicts",
		cmd = { "JJDiffConflicts" },
	},

	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		opts = {
			-- or "fzf-lua" or "snacks" or "default"
			picker = "telescope",
			-- bare Octo command opens picker of commands
			enable_builtin = true,
		},
		keys = {
			{
				"<leader>Gi",
				"<CMD>Octo issue list<CR>",
				desc = "List GitHub Issues",
			},
			{
				"<leader>Gp",
				"<CMD>Octo pr list<CR>",
				desc = "List GitHub PullRequests",
			},
			{
				"<leader>Gd",
				"<CMD>Octo discussion list<CR>",
				desc = "List GitHub Discussions",
			},
			{
				"<leader>Gn",
				"<CMD>Octo notification list<CR>",
				desc = "List GitHub Notifications",
			},
			{
				"<leader>Gs",
				function()
					require("octo.utils").create_base_search_command({ include_current_repo = true })
				end,
				desc = "Search GitHub",
			},
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			-- OR "ibhagwan/fzf-lua",
			-- OR "folke/snacks.nvim",
			"nvim-tree/nvim-web-devicons",
		},
	},
}
