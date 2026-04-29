local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then return end

configs.setup({
  ensure_installed = {
    -- Neovim essentials
    "lua", "vim", "vimdoc",
    -- Web
    "html", "css", "javascript", "typescript", "tsx",
    -- Languages
    "ruby", "go", "rust", "python", "elm", "clojure",
    -- Config / data
    "json", "yaml", "toml", "hcl", "terraform",
    -- Shell
    "bash",
    -- Prose
    "markdown", "markdown_inline",
    -- Infra
    "dockerfile", "tmux",
    -- Git
    "git_config", "gitcommit", "gitignore",
    -- Misc
    "jsonnet",
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
