
vim.pack.add({
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/mfussenegger/nvim-dap-python",
  {
    src = "https://github.com/igorlfs/nvim-dap-view",
    version = vim.version.range("1.*"),
  },
})

-- Automatically install debug adapters with Mason
local registry = require("mason-registry")

registry.refresh(function()
  for _, name in ipairs({ "debugpy", "codelldb" }) do
    local package = registry.get_package(name)

    if not package:is_installed() and not package:is_installing() then
      package:install()
    end
  end
end)

-- Set up nvim-dap
local dap = require("dap")

-- Python (uses Mason's debugpy and detects uv's .venv)
local dap_python = require("dap-python")
dap_python.setup("debugpy-adapter")
dap_python.test_runner = "pytest"

-- Rust (uses Mason's CodeLLDB)
dap.adapters.codelldb = {
  type = "executable",
  command = "codelldb",
}

dap.configurations.rust = {
  {
    name = "Launch Rust binary",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input(
        "Executable: ",
        vim.fn.getcwd() .. "/target/debug/",
        "file"
      )
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
  },
}

-- Set up debugger UI
require("dap-view").setup({
  auto_toggle = true,
})

-- Keybindings
local map = vim.keymap.set

map("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: Breakpoint" })
map("n", "<F10>", dap.continue, { desc = "Debug: Continue" })
map("n", "<F11>", dap.step_over, { desc = "Debug: Step over" })
map("n", "<F12>", dap.step_into, { desc = "Debug: Step into" })
map("n", "<S-F12>", dap.step_out, { desc = "Debug: Step out" })

map("n", "<leader>dq", dap.terminate, { desc = "Debug: Terminate" })
map("n", "<leader>dv", "<cmd>DapViewToggle<CR>", { desc = "Debug: Toggle UI" })
map("n", "<leader>dh", "<cmd>DapViewHover<CR>", { desc = "Debug: Hover" })

-- Jump to the current paused execution location
map("n", "<leader>df", dap.focus_frame, {
  desc = "Debug: Focus current frame",
})

-- Jump into debugger scopes
map("n", "<leader>ds", "<cmd>DapViewJump scopes<CR>", {
  desc = "Debug: Focus scopes",
})

-- Jump into debugger breakpoints
map("n", "<leader>db", "<cmd>DapViewJump breakpoints<CR>", {
  desc = "Debug: Focus breakpoints",
})

-- Python pytest debugging
map("n", "<leader>dt", dap_python.test_method, {
  desc = "Debug: Python test under cursor",
})

map("n", "<leader>dc", dap_python.test_class, {
  desc = "Debug: Python test class",
})

