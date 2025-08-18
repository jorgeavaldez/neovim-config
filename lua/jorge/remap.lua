vim.g.mapleader = ' '

vim.keymap.set('', '<Space>', '<Nop>')

-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = 'Open file view' })

-- move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

vim.keymap.set("n", "<leader>ff", function()
    vim.lsp.buf.format()
end)

vim.keymap.set("n", "<leader>fc", ":call setreg('+', expand('%:.'))<CR>", { desc = "Copy file path" })

vim.keymap.set("n", "<C-k>", ":noh<CR>", { desc = "Clear search results" })
vim.keymap.set("n", "<leader>ce", ":e " .. vim.fn.expand("$HOME/.config/nvim/") .. "<CR>", { desc = "Open config dir" })

-- windows
vim.keymap.set("n", "<leader>wv", vim.cmd.vsplit)
vim.keymap.set("n", "<leader>ws", vim.cmd.split)
vim.keymap.set("n", "<leader>wh", "<C-w>h")
vim.keymap.set("n", "<leader>wl", "<C-w>l")
vim.keymap.set("n", "<leader>wj", "<C-w>j")
vim.keymap.set("n", "<leader>wk", "<C-w>k")
vim.keymap.set("n", "<leader>wr", "<C-w>r")
vim.keymap.set("n", "<leader>wq", ":q<CR>")
vim.keymap.set("n", "<leader>wm", ":wincmd _<Bar>wincmd <Bar><CR>", { desc = "Maximize buffer" })
vim.keymap.set("n", "<leader>wM", "<C-w>=", { desc = "Minimize buffer" })
vim.keymap.set("n", "<leader>wT", "<C-w>T", { desc = "Move window to new tab" })
vim.keymap.set("n", "<leader>wt", ":tab split<CR>", { desc = "Open buffer in new tab, maintain state" })

-- Tabs
vim.keymap.set("n", "<leader>tn", ":tabnext<CR>", { desc = "Next tab" })
vim.keymap.set("n", "<leader>tp", ":tabprevious<CR>", { desc = "Previous tab" })

-- buffers
vim.keymap.set("n", "<leader>bc", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bd", ":bp<bar>sp<bar>bn<bar>bd<CR>", { desc = "Close Buffer" })
vim.keymap.set("n", "<leader>bp", ":bp<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bn", ":bn<CR>", { desc = "Next Buffer" })

-- terminal
vim.keymap.set("n", "<leader>$", ":terminal<CR>")
-- vim.keymap.set("t", "<C-;><C-n>", "<C-\\><C-n>")

-- wf workflow manager
-- Track added files for listing
_G.wf_added_files = _G.wf_added_files or {}

-- Shared function for wf CLI operations
local function run_wf_command(args, command_name, track_type)
    local filepath = vim.fn.expand('%:p')
    if filepath == '' then
        local msg = "No file in current buffer"
        vim.notify(msg, vim.log.levels.WARN)
        require("fidget").notify(msg, vim.log.levels.WARN)
        return
    end

    local start_msg = command_name .. ": " .. vim.fn.fnamemodify(filepath, ':t')
    vim.notify(start_msg)
    require("fidget").notify(command_name .. "...")

    local output_lines = {}
    local cmd = vim.list_extend({ 'wf' }, args)

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    if line ~= "" then
                        table.insert(output_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, code)
            if code == 0 then
                local output = table.concat(output_lines, "\n")
                if output ~= "" then
                    vim.notify("wf " .. args[1] .. " result: " .. output)
                else
                    vim.notify("wf " .. args[1] .. " completed successfully")
                end
                require("fidget").notify("wf " .. args[1] .. " completed ✓", vim.log.levels.INFO)
                if track_type then
                    -- Extract ID from output (looks for #number pattern)
                    local id = output:match("#(%d+)")
                    table.insert(_G.wf_added_files, {
                        type = track_type,
                        file = filepath,
                        time = os.date("%H:%M:%S"),
                        id = id
                    })
                end
            else
                local error_msg = "wf " ..
                args[1] .. " failed (code: " .. code .. "): " .. vim.fn.fnamemodify(filepath, ':t')
                vim.notify(error_msg, vim.log.levels.ERROR)
                require("fidget").notify("wf " .. args[1] .. " failed (code: " .. code .. ")", vim.log.levels.ERROR)
            end
        end
    })
end

vim.keymap.set("n", "<leader>wfp", function()
    local filepath = vim.fn.expand('%:p')
    run_wf_command({ 'add-prompt', filepath, '--summarize' }, "Adding file to wf prompt", "prompt")
end, { desc = "Add current file as wf prompt" })

vim.keymap.set("n", "<leader>wfa", function()
    local filepath = vim.fn.expand('%:p')
    run_wf_command({ 'add-artifact', filepath, '--summarize' }, "Adding file to wf artifact", "artifact")
end, { desc = "Add current file as wf artifact" })

-- Command to list recently added wf files
vim.keymap.set("n", "<leader>wfl", function()
    if #_G.wf_added_files == 0 then
        vim.notify("No files added to wf yet")
        return
    end
    local qf_list = {}
    for i = #_G.wf_added_files, 1, -1 do
        local item = _G.wf_added_files[i]
        local id_str = item.id and ("#" .. item.id) or "no-id"
        table.insert(qf_list, {
            filename = item.file,
            text = string.format("[%s] %s %s", item.time, item.type, id_str)
        })
    end
    vim.fn.setqflist(qf_list, 'r')
    vim.cmd('copen')
    vim.notify("Loaded " .. #qf_list .. " wf files to quickfix list")
end, { desc = "List recently added wf files in quickfix" })

-- obsidian
vim.keymap.set(
    "n",
    "gf",
    function()
        if require("obsidian").util.cursor_on_markdown_link() then
            return "<cmd>ObsidianFollowLink<CR>"
        else
            return "gf"
        end
    end,
    { noremap = false, expr = true }
)

vim.keymap.set("n", "<leader>oN", ":ObsidianNew ", { desc = "New Obsidian Note with name" })
vim.keymap.set("n", "<leader>on", "<cmd>ObsidianNew<CR>")
vim.keymap.set("n", "<leader>o/", "<cmd>ObsidianSearch<CR>")
vim.keymap.set("n", "<leader>of", "<cmd>ObsidianQuickSwitch<CR>")
vim.keymap.set("n", "<leader>ob", "<cmd>ObsidianBacklinks<CR>")
vim.keymap.set("n", "<leader>oL", "<cmd>ObsidianLink")
vim.keymap.set("n", "<leader>oln", "<cmd>ObsidianLinkNew")
vim.keymap.set("n", "<leader>olN", "<cmd>ObsidianLinkNew<CR>")
vim.keymap.set("n", "<leader>ol", "<cmd>ObsidianLink<CR>")
vim.keymap.set("n", "<leader><CR>", "<cmd>ObsidianFollowLink<CR>")
