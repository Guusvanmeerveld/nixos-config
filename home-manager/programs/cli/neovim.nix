{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.programs.cli.neovim;
in {
  imports = [inputs.nixvim.homeModules.nixvim];

  options = {
    custom.programs.cli.neovim = {
      enable = lib.mkEnableOption "Enable NeoVim text editor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      viAlias = true;
      defaultEditor = true;

      colorschemes.onedark.enable = true;

      # Wayland clipboard
      clipboard.providers.wl-copy.enable = true;

      plugins = {
        # Start screen
        alpha = {
          enable = true;
          theme = "dashboard";
        };

        web-devicons.enable = true;

        lightline.enable = true;

        # Make `nvim .` look prettier
        oil.enable = true;

        # Includes all parsers for treesitter
        treesitter.enable = true;

        # Git integration
        fugitive.enable = true;

        # Auto-tagging
        ts-autotag.enable = true;

        # Autopairs for parenthesis, brackets, etc.
        nvim-autopairs.enable = true;

        # Persistence
        persistence.enable = true;

        transparent.enable = true;

        # Search
        telescope = {
          enable = true;

          keymaps = {
            "<leader>p" = "find_files";
          };
        };

        # Tab bar
        barbar.enable = true;

        # Highlight language strings in nix files
        hmts.enable = true;

        # Notification manager
        notify.enable = true;

        # Display errors nicely inline with code
        trouble.enable = true;

        commentary.enable = true;

        # File tree
        neo-tree = {
          enable = true;

          settings = {
            auto_clean_after_session_restore = true;
            close_if_last_window = true;

            buffers = {
              bind_to_cwd = false;
              follow_current_file = {
                enabled = true;
              };
            };

            window = {
              width = 40;
              height = 15;
              auto_expand_width = false;
              mappings = {
                "<space>" = "none";
              };
            };
          };
        };

        # Linting
        lint.enable = true;

        # Language servers
        lsp = {
          enable = true;

          servers = {
            # Rust
            # rust-analyzer = {
            #   enable = true;
            #   installRustc = true;
            #   installCargo = true;
            # };
          };
        };
      };

      # Set mapleader to space
      globals.mapleader = " ";

      opts = {
        number = true;
        relativenumber = true;

        signcolumn = "yes";

        ignorecase = true;
        smartcase = true;

        # Tab defaults (might get overwritten by an LSP server)
        tabstop = 4;
        shiftwidth = 4;
        softtabstop = 0;
        expandtab = true;
        smarttab = true;

        # Show line and column when searching
        ruler = true;

        mouse = "a";

        # Highlight the current line
        cursorline = true;

        termguicolors = true;

        clipboard = "unnamedplus";
      };
    };
  };
}
