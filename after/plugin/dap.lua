local pydap = require('dap-python')

pydap.setup('~/.virtualenvs/debugpy/bin/python')

local dapui = require("dapui")

dapui.setup()

vim.keymap.set("n", "<leader>md", dapui.toggle, { desc = "Toggle debugger" })
