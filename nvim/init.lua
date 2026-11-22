-- :::Bootstrap lazy:::
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- :::Options:::
vim.cmd.colorscheme("unokai")

vim.opt.path:append("**")

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.updatetime = 250
vim.opt.undofile = true
vim.opt.confirm = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.g.mapleader = " "

-- ::Autocommands:::
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- source: https://www.reddit.com/r/neovim/comments/1lyuz6k/autocmd_to_restore_cursor_position_after_saving/
vim.api.nvim_create_autocmd("BufWinEnter", {
    desc = "Auto jump to last position",
    group = vim.api.nvim_create_augroup("auto-last-position", { clear = true }),
    callback = function(args)
        local position = vim.api.nvim_buf_get_mark(args.buf, [["]])
        local winid = vim.fn.bufwinid(args.buf)
        pcall(vim.api.nvim_win_set_cursor, winid, position)
    end,
})

-- :::Keybinds:::
-- clear highlights
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>e", vim.diagnostic.setqflist)

-- yank to system clipboard
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y')
vim.keymap.set({ "n", "v", "x" }, "<leader>Y", '"+Y', { remap = true })
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d')
vim.keymap.set({ "n", "v", "x" }, "<leader>D", '"+D')
vim.keymap.set({ "n", "v", "x" }, "<leader>p", '"+p')
vim.keymap.set({ "n", "v", "x" }, "<leader>P", '"+P')

-- 'C-^' works for some terminals but othertimes not
vim.keymap.set("n", "<C-b>", "<cmd>b#<cr>")

local function toggle_quickfix()
    local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
    if qf_winid > 0 then
        vim.cmd("cclose")
    else
        vim.cmd("copen")
    end
end
vim.keymap.set("n", "<Leader>c", toggle_quickfix, { desc = "Toggle Quickfix List" })

-- :::Plugins:::
-- source: https://gist.github.com/smnatale/5372e4ef64b96e62a961eafc71cb670d
require("lazy").setup({
    -- LSP
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        lazy = false,
        config = function()
            -- Auto install treesitter languages
            -- Source: https://www.reddit.com/r/neovim/comments/1sezoxf/nvimtreesitter_auto_install_parsers/
            vim.api.nvim_create_autocmd('FileType', {
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    local available_langs = require('nvim-treesitter').get_available()
                    local is_available = vim.tbl_contains(available_langs, lang)
                    if is_available then
                        local installed_langs = require('nvim-treesitter').get_installed()
                        local installed = vim.tbl_contains(installed_langs, lang)
                        if not installed then
                            require('nvim-treesitter').install(lang):wait()
                        end
                        vim.treesitter.start()
                        require('nvim-treesitter').indentexpr()
                    end
                end,
            })
        end
    },
    -- Telescope fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Telescope find files" })
            vim.keymap.set("n", "<leader>sg", builtin.live_grep)
            vim.keymap.set("n", "<leader>sb", builtin.buffers)
        end
    },
    -- Snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
    },
    -- Autocomplete
    {
        "Saghen/blink.cmp",
        version = "1.*",
        opts = {
            keymap = { preset = "super-tab" },
            fuzzy = { implementation = "lua" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
    },
    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {},
    },
    {
        "rose-pine/neovim",
        name = "rose-pine"
    },
})

vim.cmd('colorscheme rose-pine')

-- Disable neovim lua lsp errors
vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            diagnostics = {
                globals = {
                    "vim",
                    "require",
                },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
            },
            telemetry = {
                enable = false,
            },
        },
    },
})
