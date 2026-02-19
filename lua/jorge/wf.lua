-- WF Workflow Manager Plugin
-- Custom Neovim plugin for integrating with the `wf` CLI tool

local M = {}

-- Track added files for listing (module-level state)
M.added_files = {}

-- Shared function for wf CLI operations
local function run_wf_command(args, command_name, track_type)
	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		local msg = "No file in current buffer"
		vim.notify(msg, vim.log.levels.WARN)
		require("fidget").notify(msg, vim.log.levels.WARN)
		return
	end

	local start_msg = command_name .. ": " .. vim.fn.fnamemodify(filepath, ":t")
	vim.notify(start_msg)
	require("fidget").notify(command_name .. "...")

	local cmd = vim.list_extend({ "wf" }, args)

	vim.system(cmd, { text = true }, function(result)
		local code = tonumber(result["code"]) or 1
		local stdout = vim.trim(result["stdout"] or "")
		local stderr = vim.trim(result["stderr"] or "")

		vim.schedule(function()
			if code == 0 then
				local output = stdout
				if output ~= "" then
					vim.notify("wf " .. args[1] .. " result: " .. output)
				else
					vim.notify("wf " .. args[1] .. " completed successfully")
				end
				require("fidget").notify("wf " .. args[1] .. " completed ✓", vim.log.levels.INFO)
				if track_type then
					-- Extract ID from output (looks for #number pattern)
					local id = output:match("#(%d+)")
					table.insert(M.added_files, {
						type = track_type,
						file = filepath,
						time = os.date("%H:%M:%S"),
						id = id,
					})
				end
			else
				local error_msg = "wf "
					.. args[1]
					.. " failed (code: "
					.. code
					.. "): "
					.. vim.fn.fnamemodify(filepath, ":t")
				if stderr ~= "" then
					error_msg = error_msg .. "\n" .. stderr
				end
				vim.notify(error_msg, vim.log.levels.ERROR)
				require("fidget").notify("wf " .. args[1] .. " failed (code: " .. code .. ")", vim.log.levels.ERROR)
			end
		end)
	end)
end

-- Public API functions
function M.add_prompt()
	local filepath = vim.fn.expand("%:p")
	run_wf_command({ "add-prompt", filepath, "--summarize" }, "Adding file to wf prompt", "prompt")
end

function M.add_artifact()
	local filepath = vim.fn.expand("%:p")
	run_wf_command({ "add-artifact", filepath, "--summarize" }, "Adding file to wf artifact", "artifact")
end

function M.list_files()
	if #M.added_files == 0 then
		vim.notify("No files added to wf yet")
		return
	end
	local qf_list = {}
	for i = #M.added_files, 1, -1 do
		local item = M.added_files[i]
		local id_str = item.id and ("#" .. item.id) or "no-id"
		table.insert(qf_list, {
			filename = item.file,
			text = string.format("[%s] %s %s", item.time, item.type, id_str),
		})
	end
	vim.fn.setqflist(qf_list, "r")
	vim.cmd("copen")
	vim.notify("Loaded " .. #qf_list .. " wf files to quickfix list")
end

-- Setup function to register keymaps
function M.setup()
	vim.keymap.set("n", "<leader>wfp", M.add_prompt, { desc = "Add current file as wf prompt" })
	vim.keymap.set("n", "<leader>wfa", M.add_artifact, { desc = "Add current file as wf artifact" })
	vim.keymap.set("n", "<leader>wfl", M.list_files, { desc = "List recently added wf files in quickfix" })
end

return M
