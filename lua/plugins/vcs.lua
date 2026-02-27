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
}
