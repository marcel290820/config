-- Tokyo Night with a transparent background, so Ghostty's background and blur show through
return {
  "folke/tokyonight.nvim",
  opts = {
    style = "night",
    transparent = true,
    styles = { sidebars = "transparent", floats = "transparent" },
  },
}
