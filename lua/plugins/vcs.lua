return {
	{ "nvim-lua/plenary.nvim" },
	-- JJ (Jujutsu) plugins
	{
		"NicolasGB/jj.nvim",
		version = "*",
		config = function()
			require("jj").setup({
				diff = {
					backend = "diffview",
				},
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
