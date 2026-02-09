return {
	{ "nvim-lua/plenary.nvim" },
	-- JJ (Jujutsu) plugins
	{
		"NicolasGB/jj.nvim",
		version = "*",
		cmd = { "J", "Jdiff" },
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
		"evanphx/jjsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("jjsigns").setup()
		end,
	},
	{
		"zschreur/telescope-jj.nvim",
		lazy = true,
	},
}
