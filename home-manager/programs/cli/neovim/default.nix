{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.custom.programs.cli.neovim;

  configModule = {
    config.vim = {
      autocomplete.blink-cmp.enable = true;

      binds = {
        whichKey.enable = true;
        hardtime-nvim.enable = true;
      };

      clipboard = {
        enable = true;
        registers = "unnamedplus";

        providers.wl-copy.enable = true;
      };

      extraPlugins = with pkgs.vimPlugins; {
        eunuch.package = vim-eunuch;
      };

      formatter.conform-nvim.enable = true;

      filetree = {
        neo-tree = {
          enable = true;

          setupOpts = {
            enable_cursor_hijack = true;
            git_status_async = true;
            filesystem.follow_current_file.enabled = true;
          };
        };
      };

      git = {
        gitsigns.enable = true;
        neogit.enable = true;
      };

      languages = {
        enableTreesitter = true;
        enableFormat = true;

        rust.enable = true;
        typescript.enable = true;
        nix = {
          enable = true;
          lsp.servers = ["nixd"];
        };
        python.enable = true;
        json.enable = true;
        yaml.enable = true;
        tex.enable = true;
      };

      luaConfigPre = builtins.readFile ./utils.lua;

      lsp = {
        enable = true;
        formatOnSave = true;
      };

      maps = {
        normal = {
          "<leader>w" = {
            action = ":write<CR>";
            desc = "Write the buffer to disk";
          };

          "<leader>W" = {
            action = ":SudoWrite<CR>";
            desc = "Write the buffer to disk as sudo";
          };

          "<leader>bd" = {
            # Use custom bufremove implementation from lazyvim
            # Defined in utils.lua file
            action = "bufremove";
            lua = true;
            desc = "Close buffer";
          };

          "<leader>q" = {
            action = ":qa<CR>";
            desc = "Quit application";
          };

          # Neotree
          "<leader>e" = {
            action = ":Neotree toggle<CR>";
            desc = "Toggle Neotree";
          };
        };

        terminal = {
          "<Esc>j" = {
            action = "<C-\\><C-n>";
            desc = "Go back to normal mode";
          };
        };
      };

      mini = {
        icons.enable = true;
        comment.enable = true;
        splitjoin.enable = true;
        starter.enable = true;
        move.enable = true;
        pairs.enable = true;
      };

      notify.nvim-notify = {
        enable = true;
        setupOpts = {
          timeout = 5000;
          background_colour = "#000000";
        };
      };

      preventJunkFiles = true;

      utility = {
        direnv.enable = true;
        multicursors.enable = true;
        images.image-nvim = {
          enable = true;
          setupOpts.backend = "kitty";
        };
        outline.aerial-nvim.enable = true;
      };

      session.nvim-session-manager.enable = true;

      syntaxHighlighting = true;

      statusline.lualine.enable = true;

      tabline.nvimBufferline.enable = true;

      telescope.enable = true;

      terminal.toggleterm.enable = true;

      theme = {
        enable = true;

        name = "onedark";
        transparent = true;
      };

      treesitter = {
        enable = true;
      };

      options = let
        indent = 2;
      in {
        #  General
        breakindent = true;
        encoding = "utf-8";
        fileencoding = "utf-8";
        grepformat = "%f:%l:%c:%m";
        grepprg = "rg --vimgrep --smart-case";
        history = 500;
        inccommand = "split";
        lazyredraw = false; # deprecated; use eventignore when needed
        mouse = "a";
        redrawtime = 1500;
        sessionoptions = "curdir,folds,globals,help,tabpages,terminal,winsize";
        showmode = false;
        sidescrolloff = 3;
        timeoutlen = 250;
        ttimeoutlen = 10;
        updatetime = 100;

        #  Indentation
        autoindent = true;
        expandtab = true;
        shiftround = true;
        shiftwidth = indent;
        smartindent = true;
        softtabstop = indent;
        tabstop = indent;

        # Search
        hlsearch = true;
        ignorecase = true;
        smartcase = true;
        # wildignore = ["*/node_modules/*" "*/.git/*" "*/vendor/*" "*/.hg/*" "*/.svn/*"];
        wildmenu = true;

        # UI
        cmdheight = 0;
        # completeopt = ["menu" "menuone" "noselect"];
        cursorline = true;
        laststatus = 3; # global statusline (more performant than 2);
        number = true;
        pumheight = 10;
        scrolloff = 18;
        showtabline = 2;
        signcolumn = "yes";
        # shortmess:append({ c = true, W = true, I = true });
        splitbelow = true;
        splitkeep = "cursor";
        splitright = true;
        winborder = "rounded";
        winminwidth = 5;
        wrap = true;

        # List chars
        list = true;
        # listchars = {
        #   tab = "┊ ";
        #   trail = "·";
        #   extends = "»";
        #   precedes = "«";
        #   nbsp = "×";
        # };

        # Backspace
        # backspace = ["eol" "start" "indent"];

        # Completion
        complete = ".,w,b,kspell";
      };

      visuals = {
        blink-indent = {
          enable = true;

          setupOpts = {
            static = {
              char = "┆";
            };

            scope = {
              char = "┆";
            };
          };
        };
      };

      undoFile.enable = true;
    };
  };

  customNeovim = inputs.nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [configModule];
  };
in {
  options = {
    custom.programs.cli.neovim = {
      enable = lib.mkEnableOption "Enable NeoVim text editor";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [customNeovim.neovim];
  };
}
