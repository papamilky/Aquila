{
  pkgs,
  inputs,
  config,
  ...
}: let
  cursorPath = "${inputs.breeze-cursor.packages.${pkgs.stdenv.hostPlatform.system}.default}/share/icons";
in {
  users.users.milky = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "milky";
    extraGroups = ["networkmanager" "wheel" "cdrom" "cdrom" "i2c"];
    linger = true;
  };

  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs;
    [
      qmk
    ]
    ++ [
      inputs.breeze-cursor.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

  hjem.users = {
    milky = {
      user = "milky";
      directory = "/home/milky";

      files = {
        ".p10k.zsh".text = builtins.readFile ./configs/milky-p10k.zsh;

        ## hyprland
        ".config/hypr/hyprlock.conf".text = builtins.readFile ./configs/milky-hyprlock.conf;
        ".config/hypr/hyprland.conf".text = builtins.readFile ./configs/hyprland.conf;

        ## gtk
        "theme.conf".text = "
[org/gnome/desktop/interface]
gtk-theme='Colloid-Dark'
icon-theme='Papirus-Dark'
cursor-theme='breeze5-cursor'
color-scheme='prefer-dark'
";

        ## fish
        ".config/fish/functions/fish_greeting.fish".text = builtins.readFile ./configs/fish/greetingfunc.fish;
        ".config/fish/functions/_tide_item_cmd_duration.fish".text = builtins.readFile ./configs/fish/cmddurfunc.fish;
        ".config/fish/functions/_tide_item_newstatus.fish".text = builtins.readFile ./configs/fish/statusfunc.fish;
        ".config/fish/functions/_tide_item_time.fish".text = builtins.readFile ./configs/fish/timefunc.fish;
        ".config/fish/functions/_tide_print_item.fish".text = builtins.readFile ./configs/fish/printfunc.fish;
        ".config/fish/conf.d/tide.fish".text = builtins.readFile ./configs/fish/tide.fish;
      };

      uwsm.env = {
        XCURSOR_SIZE = "25";
        XCURSOR_PATH = "${cursorPath}";
        XCURSOR_THEME = "breeze5-cursor";
      };
    };
  };
}
