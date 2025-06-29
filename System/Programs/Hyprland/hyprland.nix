{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.aquila.system.services.hyprland;
in {
  options.aquila.system.services.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland For System";
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      extra-substituters = [
        "https://hyprland.cachix.org"
        "https://walker-git.cachix.org"
      ];
      extra-trusted-substituters = [
        "https://hyprland.cachix.org"
        "https://walker-git.cachix.org"
      ];
      extra-trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];
    };

    home-manager.users.milky = {
      imports = [
        ./uwsm.nix
        inputs.walker.homeManagerModules.default
      ];

      home.packages =
        (with inputs; [
          breeze-cursor.packages.${pkgs.system}.default
          quickshell.packages."${pkgs.system}".default
        ])
        ++ (with pkgs; [
          libqalculate
          anyrun

          eww
          slurp
          swww
          nautilus

          gallery-dl
          hyprpicker
          wallust
          kdePackages.kirigami
          kdePackages.qtshadertools
          kdePackages.qt5compat
        ]);

      nix.settings = {
        extra-substituters = [
          "https://hyprland.cachix.org"
        ];
        extra-trusted-substituters = [
          "https://hyprland.cachix.org"
        ];
        extra-trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ];
      };

      home.uwsm.env = {
        XCURSOR_SIZE = "24";
        XCURSOR_PATH = "${inputs.breeze-cursor.packages.${pkgs.system}.default}/share/icons";
        XCURSOR_THEME = "breeze5-cursor";
      };

      gtk = {
        enable = true;
        theme = {
          name = "Materia-dark";
          package = pkgs.materia-theme;
        };
        cursorTheme = {
          name = "breeze5-cursor";
          package = inputs.breeze-cursor.packages.${pkgs.system}.default;
          size = 24;
        };
        iconTheme = {
          name = "oomox-gruvbox-dark";
          package = pkgs.gruvbox-dark-icons-gtk;
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk";
        style.name = "adwaita-dark";
        style.package = pkgs.adwaita-qt;
      };

      home.file.".config/hypr/hyprlock.conf".text = builtins.readFile ./milky-hyprlock.conf;

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

        systemd.enable = false;
        settings = {
          # Enviroment Vars
          env = [
            "HYPRCURSOR_THEME,breeze5-cursor"
            "HYPRCURSOR_SIZE,32"
          ];

          cursor = {
            enable_hyprcursor = true;
            sync_gsettings_theme = true;
          };

          monitor = [
            "DP-2, 2560x1440@75, 0x0, 1"
          ];

          input = {
            follow_mouse = 0;
            sensitivity = -0.65;
            accel_profile = "flat";
          };

          general = {
            layout = "dwindle";
            gaps_in = 3;
            gaps_out = 6;
            border_size = 0;
            allow_tearing = true;
            "col.inactive_border" = "rgba(595959aa)";
            "col.active_border" = "rgba(33ccffee)";
            snap.enabled = true;
          };

          dwindle = {
            pseudotile = "yes";
            preserve_split = "yes";
            force_split = 2;
          };

          debug = {
            disable_logs = false;
          };

          master = {
            new_on_top = "true";
          };

          binds = {
            allow_workspace_cycles = true;
            # hide_special_on_workspace_change = true;
          };

          decoration = {
            rounding = 5;
            active_opacity = 1;
            inactive_opacity = 1;

            blur = {
              enabled = true;
              size = 6;
              passes = 1;
            };
          };

          animations = {
            enabled = "yes";

            bezier = [
              "easeInOutCubic, 0.65, 0, 0.35, 1"
            ];

            animation = [
              "windows, 1, 1, default"
              "windowsOut, 1, 1, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 4, 1, default"
              "workspaces, 1, 3, easeInOutCubic, slide"
            ];
          };

          windowrulev2 = [
            "bordersize 0, floating:0, onworkspace:w[tv1]"
            "bordersize 0, floating:0, onworkspace:f[1]"
            "rounding 0, floating:0, onworkspace:w[tv1]"
            "rounding 0, floating:0, onworkspace:f[1]"

            "float, initialClass:steam, initialTitle:negative:Steam"
            "float, initialClass:firefox, initialTitle:^(Extension:).*$"
            "immediate, initialClass:^(.*Minecraft.*)$"
            "renderunfocused, initialClass:^(.*Minecraft.*)$"
            "immediate, initialClass:^(steam_app*)$"
            "renderunfocused, initialClass:^(steam_app*)$"
          ];

          workspace = [
            "w[t1], gapsout:0, gapsin:0"
            "w[tg1], gapsout:0, gapsin:0"
            "f[1], gapsout:0, gapsin:0"
          ];

          layerrule = [
            # "blur, quickshell"
            # "ignorezero, quickshell"
          ];

          # Let Mod be the Super key (Windows key)
          "$mod" = "SUPER";
          "$alt" = "ALT";
          "$ctrl" = "CONTROL";

          exec-once = [
            "uwsm app -- wl-paste --type text --watch cliphist store" # Stores only text data
            "uwsm app -- wl-paste --type image --watch cliphist store" # Stores only image data

            "uwsm app -- dunst" # Notification Server
            "uwsm app -- quickshell -d" # Quickshell
          ];

          bind =
            [
              ", SUPER_L, pass, class:^(wev)$"
              "$alt, F4, killactive,"
              "$mod, Q, killactive,"

              "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify \"Screenshot of the region taken\" -t 1000" # screenshot of a region
              ", Print, exec, grim - | wl-copy && wl-paste > ~/Pictures/Screenshots/Screenshot-$(date +%F_%T).png | dunstify \"Screenshot of the region taken\" -t 1000" # screenshot of the whole screen

              "$mod, space, exec, qs ipc call ControlCenter toggleLauncherVisible"
              "$mod, V, exec, uwsm app -- walker --modules clipboard"
              "$mod, E, exec, uwsm app -- nautilus"
              "$mod $alt, R, submap, resize"
              "$mod, M, exec, uwsm stop"

              ", F11, fullscreen, 0"

              "$ctrl $alt, T, exec, uwsm app -- kitty" #

              "$mod, grave, exec, qs ipc call Overview toggleVisible"

              # Toggle Floating
              "$mod, F, togglefloating,"

              # Move focus with mod + arrow keys
              "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "$mod, up, movefocus, u"
              "$mod, down, movefocus, d"

              # "Vanilla" Hyprland Conf
              # Lock
              "$mod, P, exec, loginctl lock-session"

              # Mod Tab
              "$mod, TAB, workspace, previous'"
              "$mod SHIFT, TAB, movetoworkspace, previous'"

              # Alt Tab Functionality
              "$alt, Tab, focuscurrentorlast," # change focus to last window

              # Movement Functionality
              "$mod, h, workspace, -1"
              "$mod, l, workspace, +1"
              "$mod SHIFT, h, movetoworkspace, -1"
              "$mod SHIFT, l, movetoworkspace, +1"

              # Special Workspace
              "$mod, S, togglespecialworkspace, magic"
              "$mod SHIFT, S, movetoworkspace, special:magic"

              # OBS
              "$mod SHIFT, F10, pass, class:^(com\.obsproject\.Studio)$"
            ]
            ++ (
              # workspaces
              builtins.concatLists (builtins.genList (
                  i: let
                    ws = i + 1;
                  in [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
                  ]
                )
                6)
            );
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
          bindl = [
            # Knob
            ", XF86AudioRaiseVolume, exec, qs ipc call Volume setVolume +5" # Increase Volume
            ", XF86AudioLowerVolume, exec, qs ipc call Volume setVolume -5" # Decrese Volume
            ", XF86AudioMute,        exec, qs ipc call Volume toggleMute" # Mute Toggle
            # FN Knob
            ", XF86AudioPlay,        exec, qs ipc call Media  togglePause" # Pause Song
            ", XF86AudioNext,        exec, qs ipc call Media  next" # Next Song
            ", XF86AudioPrev,        exec, qs ipc call Media  previous" # Previous Song
            # Mic Mute
            ", XF86AudioMicMute,     exec, qs ipc call Volume toggleMic" # Toggle Microphone Mute
          ];
        };
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };
    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QML2_IMPORT_PATH = "/home/milky/quickshell-plugins/";
    };

    environment.systemPackages = with pkgs; [
      hyprcursor
      hypridle
      hyprlock

      hyprpolkitagent
    ];
  };
}
