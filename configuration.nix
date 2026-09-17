{
  pkgs,
  inputs,
  ...
}:

let
  # Create LocalSend GTK Wrapper
  localsendGtk = pkgs.symlinkJoin {
    name = "localsend-gtk";
    paths = [ pkgs.localsend ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      rm "$out/bin/localsend_app"
      makeWrapper "${pkgs.localsend}/bin/localsend_app" \
        "$out/bin/localsend_app" \
        --set GTK_CSD 0
    '';
  };

  # Custom BreezeX Black Cursors
  breezexBlack = pkgs.callPackage ./pkgs/breezex-black.nix { };
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./default/xdg.nix
    inputs.noctalia-greeter.nixosModules.default
  ];

  # Allow non-FOSS
  nixpkgs.config.allowUnfree = true;

  # Systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options asus_wmi fnlock_default=0
  '';

  # Firmware idling bug fix
  boot.kernelParams = [ "intel_idle.max_cstate=2" ];

  programs.noctalia-greeter = {
    enable = true;
    settings = {
      keyboard = {
        layout = "se";
        variant = "nodeadkeys";
      };
    };
  };
  services.displayManager.defaultSession = "niri";

  # Clean up old systems
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Network
  networking.networkmanager.enable = true;
  networking.hostName = "schizopad";

  # Internationalization
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "se";

  # Keyd config
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          leftmeta = "leftalt";
          leftalt = "leftmeta";
          capslock = "esc";
        };
      };
    };
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Enable touchpad support
  services.libinput.enable = true;

  # Battery
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # User account
  users.users.wef = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "video"
      "audio"
      "networkmanager"
      "docker"
      "libvirtd"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
  };

  # App enables
  programs.niri.enable = true;
  programs.fish.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  services.sslh.enable = true;

  # Dark mode
  programs.dconf.enable = true;
  systemd.user.services.dconf-dark-mode = {
    script = ''
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    '';
    wantedBy = [ "default.target" ];
  };

  # Noctalia shell daemon
  systemd.user.services.noctalia = {
    description = "Noctalia desktop shell daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [
      # systemd appends /bin and /sbin to each entry, so pass the base dir.
      "/run/current-system/sw"
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.noctalia.packages."${pkgs.stdenv.hostPlatform.system}".default}/bin/noctalia";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };

  # Cursor theme
  environment.sessionVariables = {
    XCURSOR_THEME = "BreezeX-Black";
    XCURSOR_SIZE = "24";
  };

  # Packages
  environment.systemPackages = with pkgs; [
    # nvim stuff
    lazygit
    stylua
    prettier
    black
    shfmt
    clang-tools
    nil
    nixpkgs-fmt
    typescript-language-server
    tailwindcss-language-server
    pyright
    bash-language-server
    marksman
    vscode-langservers-extracted
    jdk21
    gcc
    # system stuff
    colloid-icon-theme
    breezexBlack
    phinger-cursors
    vim
    wget
    git
    zoxide
    starship
    niri
    xwayland-satellite
    bluez
    xdg-desktop-portal
    ripgrep
    brightnessctl
    libnotify
    wl-clipboard
    zip
    unzip
    # my stuff
    mpv
    localsendGtk
    kitty
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    neovim
    nautilus
    dust
    prismlauncher
    obs-studio
    obsidian
    btop
    zathura
    tmux
    opencode
    hyprpicker
    yazi
    fastfetch
    inputs.areofyl-fetch.packages."${pkgs.stdenv.hostPlatform.system}".default
    inputs.noctalia.packages."${pkgs.stdenv.hostPlatform.system}".default
    discord-ptb
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    nerd-fonts.iosevka
    font-awesome
    inter
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # SSH and V12n
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  # Enable and configure git
  programs.git = {
    enable = true;
    config = {
      user.name = "ekrlstd";
      user.email = "ebbekarlstad@proton.me";
      user.signingkey = "~/.ssh/id_ed25519.pub";
      gpg.format = "ssh";
      commit.gpgsign = true;
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
    lfs.enable = true;
  };

  # /etc/nixos ownership
  systemd.tmpfiles.rules = [
    "Z /etc/nixos 0755 wef users - -"
  ];

  system.stateVersion = "26.05";
}
