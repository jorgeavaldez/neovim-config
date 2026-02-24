return {
	{ "nvim-lua/plenary.nvim" },
	-- JJ (Jujutsu) plugins
	{
		"NicolasGB/jj.nvim",
		version = "*",
		config = function()
			require("jj").setup({})
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
}
