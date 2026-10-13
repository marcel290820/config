-- Languages without a LazyVim extra: shell, HTML, CSS
return {
  {
    "neovim/nvim-lspconfig",
    opts = { servers = { bashls = {}, html = {}, cssls = {} } },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss" } },
  },
  -- jdtls needs Java 21+; run it on Homebrew's keg-only openjdk@21 and leave the system Java alone
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      table.insert(opts.cmd, "--java-executable=" .. vim.fn.expand("$HOMEBREW_PREFIX/opt/openjdk@21/bin/java"))
    end,
  },
}
