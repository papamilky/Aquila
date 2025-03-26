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
    home-manager.users.milky = {
      home.packages =
        (with inputs; [
          rose-pine-hyprcursor.packages.${pkgs.system}.default
          quickshell.packages."${pkgs.system}".default
        ])
        ++ (with pkgs; [
          anyrun
          eww

          gallery-dl
          hyprpicker
          wallust
          kdePackages.kirigami
          kdePackages.qtshadertools
          kdePackages.qt5compat
        ]);

      nix.settings = {
        extra-substituters = ["https://hyprland.cachix.org"];
        extra-trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };

      home.file.".config/hypr/hyprlock.conf".text = builtins.readFile ./milky-hyprlock.conf;

      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        plugins = [];

        systemd.enable = false;
        extraConfig = "
            ###
            ### RESIZE SUBMAP START
            submap=resize
            bind=,catchall,submap,reset
            binde=,right,resizeactive,10 0
            binde=,left,resizeactive,-10 0
            binde=,up,resizeactive,0 -10
            binde=,down,resizeactive,0 10
            bind=,escape,submap,reset 
            submap=reset

            ### RESIZE SUBMAP END
            ###
          ";

        settings = {
          # Enviroment Vars
          env = [
            "XCURSOR_SIZE,26"
            "HYPRCURSOR_THEME,rose-pine-hyprcursor"
            "HYPRCURSOR_SIZE,26"
          ];

          cursor = {
            enable_hyprcursor = true;
            sync_gsettings_theme = true;
          };

          plugin = {
          };

          monitor = [
            "DP-2, 2560x1440@75, 0x0, 1"
          ];

          input = {
            follow_mouse = 2;
            sensitivity = 0;
            accel_profile = "adaptive";
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
          };
          debug = {
            disable_logs = false;
          };

          master = {
            new_on_top = "true";
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
              "myBezier, 0.05, 0.9, 0.1, 1"
              "easeInOutCubic, 0.65, 0, 0.35, 1"
            ];

            animation = [
              "windows, 1, 7, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 4, 1, default"
              "workspaces, 1, 3, easeInOutCubic, slide"
            ];
          };

          windowrulev2 = [
            "float, initialClass:steam, initialTitle:negative:Steam"
            "float, initialClass:firefox, title:^(Extension:).*$"
            "immediate, class:^(.*Minecraft.*)$"
          ];

          layerrule = [
            "blur, quickshell"
            "ignorezero, quickshell"
          ];

          # Let Mod be the Super key (Windows key)
          "$mod" = "SUPER";
          "$alt" = "ALT";
          "$ctrl" = "CONTROL";

          exec-once = [
            "uwsm app -- wl-paste --type text --watch cliphist store" # Stores only text data
            "uwsm app -- wl-paste --type image --watch cliphist store" # Stores only image data

            "uwsm app -- swww-daemon" # Wallpaper Engine
            "uwsm app -- dunst" # Notification Server
            "uwsm app -- quickshell -d" # Notification Server
          ];

          bind =
            [
              "$alt, F4, killactive,"
              "$mod, Q, killactive,"
              ", Print, exec, uwsm app -- grimblast copy screen"
              "SUPER, space, exec, uwsm app -- pkill anyrun || anyrun"
              "$mod, V, exec, uwsm app -- pkill wofi || cliphist list | wofi --dmenu | cliphist decode | wl-copy"
              "$mod, E, exec, uwsm app -- nautilus"
              "$mod $alt, R, submap, resize"
              "$mod, M, exec, uwsm stop"

              ", F11, fullscreen, 0"

              "$ctrl $alt, T, exec, uwsm app -- kitty" #

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

              # Hyprspace
              "$mod, B, exec, overview:toggle"

              # OBS
              "$mod SHIFT, F10, pass, class:^(com\.obsproject\.Studio)$"

              # # HyprKool Related Conf
              # # Switch activity
              # "$mod, TAB, exec, hyprkool next-activity -c"

              # # Move active window to a different acitvity
              # "$mod CTRL, TAB, exec, hyprkool next-activity -c -w"

              # "$mod, b, exec, hyprkool toggle-overview"

              # # Relative workspace jumps
              # "$mod, h, exec, hyprkool move-left -c"
              # "$mod, l, exec, hyprkool move-right -c"
              # "$mod, j, exec, hyprkool move-down -c"
              # "$mod, k, exec, hyprkool move-up -c"

              # "$mod CTRL ALT, left, exec, hyprkool move-left -c"
              # "$mod CTRL ALT, right, exec, hyprkool move-right -c"
              # "$mod CTRL ALT, up, exec, hyprkool move-up -c"
              # "$mod CTRL ALT, down, exec, hyprkool move-down -c"

              # # Move active window to a workspace
              # "$mod SHIFT, h, exec, hyprkool move-left -c -w"
              # "$mod SHIFT, l, exec, hyprkool move-right -c -w"
              # "$mod SHIFT, j, exec, hyprkool move-down -c -w"
              # "$mod SHIFT, k, exec, hyprkool move-up -c -w"

              # "$mod CTRL ALT SHIFT, left, exec, hyprkool move-left -c -w"
              # "$mod CTRL ALT SHIFT, right, exec, hyprkool move-right -c -w"
              # "$mod CTRL ALT SHIFT, up, exec, hyprkool move-up -c -w"
              # "$mod CTRL ALT SHIFT, down, exec, hyprkool move-down -c -w"

              # # toggle special workspace
              # "$mod, SPACE, exec, hyprkool toggle-special-workspace -n minimized"
              # # move active window to special workspace without switching to that workspace
              # "$mod, s, exec, hyprkool toggle-special-workspace -n minimized -w -s"
            ]
            ++ (
              # workspaces
              builtins.concatLists (builtins.genList (
                  i: let
                    ws = i + 1;
                  in [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"

                    # Hyprkool Conf
                    # "$mod, code:1${toString i}, exec, hyprkool switch-named-focus -n ${toString ws}"
                    # "$mod SHIFT, code:1${toString i}, exec, hyprkool switch-named-focus -n ${toString ws} -w"
                    # "$mod CTRL, code:1${toString i}, exec, hyprkool set-named-focus -n ${toString ws}"
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
            ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1" # Increase Volume
            ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 1" # Decrese Volume
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" # Mute Toggle
            # FN Knob
            ", XF86AudioPlay, exec, playerctl play-pause" # Pause Song
            ", XF86AudioNext, exec, playerctl next" # Next Song
            ", XF86AudioPrev, exec, playerctl previous" # Previous Song
            # Mic Mute
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" # Toggle Microphone Mute
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
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    environment.systemPackages = with pkgs; [
      hyprcursor
      hypridle
      hyprlock

      hyprpolkitagent
    ];
  };
}
