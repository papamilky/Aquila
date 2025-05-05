{
  pkgs,
  inputs,
  config,
  ...
}: {
  users.users.milky = {
    shell = pkgs.zsh;
    isNormalUser = true;
    description = "milky";
    extraGroups = ["networkmanager" "wheel" "cdrom"];
  };

  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs; [
    qmk
  ];

  home-manager.users.milky = {...}: {
    programs.git = {
      enable = true;
      userName = "PapaMilky";
      userEmail = "milkyfromhr@outlook.com";
    };

    programs = {
      cava = {
        enable = true;
        settings = {
          input.method = "pulse";
          output = {
            channels = "mono";
            orientation = "horizontal";
          };
        };
      };
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        plugins = [
          {
            name = "zsh-powerlevel10k";
            src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
            file = "powerlevel10k.zsh-theme";
          }
        ];

        oh-my-zsh = {
          enable = true;
          plugins = ["sudo" "git"];
        };
        initExtraBeforeCompInit = ''
          P10K_INSTANT_PROMPT="''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
          if [[ -r "$P10K_INSTANT_PROMPT" ]]; then
            source "$P10K_INSTANT_PROMPT"
          fi
          source ~/.p10k.zsh
          bindkey "''${key[Up]}" up-line-or-search
        '';
      };
    };
    home.file.".p10k.zsh".text = builtins.readFile ./configs/milky-p10k.zsh;

    home.username = "milky";
    home.homeDirectory = "/home/milky";
    home.stateVersion = "23.11";

    home.sessionVariables = {
      QML2_IMPORT_PATH = "${pkgs.kdePackages.kirigami}/lib/qt-5.15.16/qml:$QML2_IMPORT_PATH";
    };

    home.packages = with pkgs; [
      ## Shell
      zsh-powerlevel10k
      meslo-lgs-nf
    ];
  };
}
