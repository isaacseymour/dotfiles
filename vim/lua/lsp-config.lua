local lspconfig = require("lspconfig")

-- Basic TypeScript/JavaScript setup
lspconfig.ts_ls.setup({
  on_attach = function(client, bufnr)
    -- Basic LSP keybindings
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  end,
})
