local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
	local clone_obj = vim.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	}, { text = true })
	local wait = clone_obj["wait"]
	local clone_result
	if type(wait) == "function" then
		clone_result = wait(clone_obj)
	else
		clone_result = { code = 1, stderr = "vim.system wait() unavailable" }
	end

	local clone_code = tonumber(clone_result["code"]) or 1
	local clone_stderr = clone_result["stderr"] or "unknown error"
	if clone_code ~= 0 then
		error("Failed to clone lazy.nvim: " .. clone_stderr)
	end
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	---@diagnostic disable-next-line: assign-type-mismatch
	dev = {
		path = "~/proj",
	},
	spec = {
		{ import = "plugins" },
	},
	change_detection = {
		notify = false,
	},
})
