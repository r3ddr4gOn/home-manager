{
  config,
  pkgs,
  lib,
  nixGL,
  local,
  ...
}:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  nixGL = {
    packages = nixGL.packages; # you must set this or everything will be a noop
    defaultWrapper = "mesa"; # choose from nixGL options depending on GPU
    installScripts = [ "mesa" ];
  };

  # nixpkgs.overlays = [
  #   (final: prev: {
  #     zoxide = prev.zoxide.overrideAttrs {
  #       version = "0.9.8-workxide-devel";
  #       src = /work/workxide;
  #       cargoHash = "";
  #       # src = prev.fetchFromGitHub {
  #       #   owner = "r3ddr4gOn";
  #       #   repo = "workxide";
  #       #   rev = "8060b7ad6b2f66cf0f942d296de57e8d8be381f4";
  #       #   hash = "sha256-rrmAUnsh+kjzBl0DJkhKLtHfeeIF73lUMg51RjK8mdU=";
  #       # };
  #     };
  #   })
  # ];

  home = {
    username = local.username;
    homeDirectory = "/home/${local.username}";
    sessionPath = [ "/home/${local.username}/.nix-profile/bin" ];
    stateVersion = "25.05"; # should be changed manually after reading the home-manager upgrade notes
    packages = with pkgs; [
      bat
      choose
      delta
      devenv
      duf
      dust
      eza
      fd
      fzf
      jq
      kdiff3
      lazygit
      lsd
      markdown-oxide
      meld
      mpls
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      neovim
      nixfmt-rfc-style
      nushell
      obsidian
      procs
      rclone
      ripgrep
      ruff
      sd
      serpl
      silver-searcher
      skim
      starship
      taplo
      tldr
      ty
      uv
      yazi
      zellij
      zsh-forgit
      zsh-fzf-tab
    ];
  };

  systemd.user.sessionVariables = {
    CARAPACE_HIDDEN = 1;
    CARAPACE_LENIENT = 1;
    EDITOR = "hx";
    XDG_DATA_DIRS = "/home/${local.username}/.nix-profile/share\${XDG_DATA_DIRS:+:}\$XDG_DATA_DIRS";
    SKIM_DEFAULT_COMMAND = "fd -u --type f"; # TODO: integrate with git-recursive on ks
    WORKSPACES_ROOT = "/work"; # Used by cdw/cdf aliases
  };

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.alacritty = {
    enable = true;
    package = config.lib.nixGL.wrap pkgs.alacritty;
    settings = {
      font = {
        size = 12.0;
        builtin_box_drawing = false;
        normal = {
          family = "JetBrainsMonoNL Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMonoNL Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMonoNL Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMonoNL Nerd Font Mono";
          style = "Bold Italic";
        };
      };
      scrolling.history = 100000;
      keyboard.bindings = [
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
      ];
      colors = {
        primary = {
          # background = "#0a0a0a";
          foreground = "#d4d4d4";
        };
        normal = {
          black = "#000000";
          red = "#f44747";
          green = "#4ec9b0";
          yellow = "#ffcc02";
          blue = "#569cd6";
          magenta = "#c586c0";
          cyan = "#4fc1ff";
          white = "#cccccc";
        };
        bright = {
          black = "#666666";
          red = "#f44747";
          green = "#4ec9b0";
          yellow = "#ffcc02";
          blue = "#569cd6";
          magenta = "#c586c0";
          cyan = "#4fc1ff";
          white = "#ffffff";
        };
      };
      env.TERM = "alacritty";
      general.live_config_reload = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    initExtra = ''
      source ~/.config/bash/init.sh
    '';
  };

  xdg.configFile."bash".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/bash";

  xdg.configFile."blesh".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/blesh";

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    initContent = ''
      source ~/.config/zsh/init.sh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh
    '';
    oh-my-zsh = {
      enable = true;
      extraConfig = ''
        zstyle ':omz:plugins:eza' 'dirs-first' yes
        zstyle ':omz:plugins:eza' 'git-status' yes
        zstyle ':omz:plugins:eza' 'header' yes
        zstyle ':omz:plugins:eza' 'show-group' yes
        zstyle ':omz:plugins:eza' 'size-prefix' binary
      '';
      plugins = [
        "eza"
        "git-escape-magic"
      ];
    };
  };

  xdg.configFile."zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/zsh";

  programs.carapace = {
    enable = true;
    enableBashIntegration = false;
    enableZshIntegration = false;
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      dialect = "uk";
      timezone = "local";
      auto_sync = false;
      update_check = false;
      search_mode = "skim";
      filter_mode = "global";
      style = "compact";
      inline_height = 25;
      invert = false;
      show_preview = true;
      exit_mode = "return-original";
      #history_format = "{command}"; # FIXME: doesn't work
      max_preview_height = 4;
      show_help = false;
      secrets_filter = true;
      enter_accept = true;
      stats.ignored_commands = [
        "cd"
        "ls"
        "ll"
        "la"
      ];
      keys = {
        scroll_exits = false;
        exit_past_line_start = false;
        accept_past_line_end = false;
      };
      preview.strategy = "auto";
      daemon.enabled = false;
      search.filters = [
        "global"
        "session"
        "directory"
      ];
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    options = [
      "--no-cmd"
    ];
  };

  programs.direnv.enable = true;

  programs.powerline-go = {
    enable = true;
    modules = [
      "jobs"
      "exit"
      "host"
      "cwd"
      "git"
    ];
    newline = true;
    settings = {
      numeric-exit-codes = true;
      hostname-only-if-ssh = true;
      error = "$?";
      jobs = "$(( $(jobs -p -r | wc -l) + $(jobs -p -s | wc -l) ))";
    };
  };

  # programs.starship = {
  #   enable = true;
  #   enableBashIntegration = true;
  #   enableZshIntegration = true;
  #   settings = {
  #     add_newline = true;
  #     format = lib.concatStrings [
  #       "$jobs"
  #       "$directory"
  #       "$git_branch"
  #       "$git_status"
  #       "$line_break"
  #       "$character"
  #     ];
  #     palette = "catppuccin_mocha";
  #     palettes.catppuccin_mocha = {
  #       rosewater = "#f5e0dc";
  #       flamingo = "#f2cdcd";
  #       pink = "#f5c2e7";
  #       mauve = "#cba6f7";
  #       red = "#f38ba8";
  #       maroon = "#eba0ac";
  #       peach = "#fab387";
  #       yellow = "#f9e2af";
  #       green = "#a6e3a1";
  #       teal = "#94e2d5";
  #       sky = "#89dceb";
  #       sapphire = "#74c7ec";
  #       blue = "#89b4fa";
  #       lavender = "#b4befe";
  #       text = "#cdd6f4";
  #       subtext1 = "#bac2de";
  #       subtext0 = "#a6adc8";
  #       overlay2 = "#9399b2";
  #       overlay1 = "#7f849c";
  #       overlay0 = "#6c7086";
  #       surface2 = "#585b70";
  #       surface1 = "#45475a";
  #       surface0 = "#313244";
  #       base = "#1e1e2e";
  #       mantle = "#181825";
  #       crust = "#11111b";
  #     };
  #     scan_timeout = 3;
  #     jobs = {
  #       symbol = "✦";
  #       style = "bold cyan";
  #       number_threshold = 1;
  #       disabled = false;
  #     };
  #     git_branch = {
  #       symbol = " ";
  #       style = "bold purple";
  #     };
  #     git_status.style = "bold purple";
  #     character = {
  #       success_symbol = "[](bold green)";
  #       error_symbol = "[✗](bold red)";
  #     };
  #   };
  # };

  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "gruvbox";
      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      editor.file-picker = {
        hidden = false;
      };
      editor.lsp = {
        display-inlay-hints = true;
      };
      keys.normal = {
        "del" = "delete_char_forward";
        C-s = ":w";
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
        X = "extend_line_up";
        C-k = [
          "extend_to_line_bounds"
          "delete_selection"
          "move_line_up"
          "paste_before"
        ];
        C-j = [
          "extend_to_line_bounds"
          "delete_selection"
          "paste_after"
        ];
        A-g.b = ":sh git blame -L %{cursor_line},+1 %{buffer_name}";
        A-g.s = ":sh git status --porcelain";
        A-g.l = ":sh git log --oneline -10 %{buffer_name}";
        tab.x = ":sh bash -c '%{selection}'";
        tab.b = ":sh bash -c '%{selection}'";
        tab.h = ":toggle-option file-picker.hidden";
        tab.i = ":toggle-option file-picker.git-ignore";
        tab.l = ":o ~/.config/helix/languages.toml";
        tab.c = ":config-open";
      };
    };
    languages = {
      language = [
        {
          name = "bash";
          indent = {
            tab-width = 4;
            unit = "\t";
          };
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
        }
        {
          name = "yaml";
          scope = "source.gdp";
          indent = {
            tab-width = 2;
            unit = " ";
          };
        }
      ];
    };
  };

  programs.git = {
    enable = true;
    userName = "Rouven Rastetter";
    userEmail = "rouven.rastetter@firaweb.de";
    aliases = {
      co = "checkout";
      cp = "cherry-pick";
      cpc = "cherry-pick --continue";
      cpa = "cherry-pick --abort";
      ci = "commit";
      cim = "commit -m";
      cir = "commit --reuse-message=HEAD@{1}";
      cif = "commit --fixup";
      conb = "branch --contains";
      cont = "tag --contains";
      d = "diff";
      dno = "diff --name-only";
      dc = "diff --cached"; # same as ds?
      ds = "diff --staged";
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
      l = "log --oneline --graph --decorate --topo-order";
      la = "l --all";
      p = "push";
      pf = "push --force-with-lease";
      rb = "rebase";
      rbi = "rebase --interactive";
      rbif = "!GIT_SEQUENCE_EDITOR=true git rebase --interactive --autosquash";
      rbc = "rebase --continue";
      rba = "rebase --abort";
      rio = "!git rebase --interactive $(git symbolic-ref refs/remotes/origin/HEAD --short)";
      ro = "rebase origin/master";
      rs = "reset";
      rsh = "reset --hard";
      st = "status";
      stnu = "status --untracked-files=no";
    };
    extraConfig = {
      advice.detachedHead = false;
      core = {
        sparsecheckout = true;
        whitespace = "trailing-space,space-before-tab";
      };
      color.ui = true;
      # credential = {
      #   helper = "/usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret";
      # };
      # init = {
      #   templatedir = "~/.git-templates/";
      #   defaultBranch = "master";
      # };
      merge.conflictStyle = "zdiff3";
      mergetool = {
        prompt = false;
        keepBackup = false;
      };
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      pull.rebase = true;
      rebase.autosquash = true;
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      # safe = [ { directory = "/work"; } ];
    };
    delta = {
      enable = true;
      options = {
        dark = true;
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-decoration-style = "none";
          file-style = "bold yellow ul";
        };
        features = "decorations";
        line-numbers = true;
        navigate = true;
        side-by-side = true;
        whitespace-error-style = "22 reverse";
      };
    };
    ignores = [ ".envrc" ];
    lfs.enable = true;
  };

  xdg.configFile."moxide/settings.toml".source = tomlFormat.generate "settings.toml" {
    new_file_folder_path = "/home/${local.username}/notes/devel/";
    daily_notes_folder = "/home/${local.username}/notes/devel/daily/";
    include_md_extension_md_link = true;
    include_md_extension_wikilink = true;
  };
}
