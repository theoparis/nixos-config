{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.overlays = [
    (self: super: {
      blender = super.blender.overrideAttrs (old: {
        version = "4.3.0";
        srcs = [
          inputs.blender
          (pkgs.fetchgit {
            name = "assets";
            url = "https://projects.blender.org/blender/blender-assets.git";
            rev = "6864f1832e71a31e1e04f72bb7a5a1f53f0cd01c";
            fetchLFS = true;
            hash = "sha256-vepK0inPMuleAJBSipwoI99nMBBiFaK/eSMHDetEtjY=";
          })
        ];
        cmakeFlags = old.cmakeFlags ++ [
          "-DWITH_VULKAN_BACKEND=ON"
          "-DWITH_VULKAN_MOLTENVK=ON"
          "-DWITH_EXPERIMENTAL_FEATURES=ON"
          "-DCMAKE_CXX_FLAGS='-DVK_ENABLE_BETA_EXTENSIONS=1'"
        ];

        buildInputs = old.buildInputs ++ [
          (super.vulkan-headers.overrideAttrs (old: {
            src = inputs.vulkan-headers;
          }))
          super.vulkan-loader
          super.shaderc
        ];
      });
    })
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];

    trusted-substituters = [
      "https://hydra.nixos.org"
      "https://cache.garnix.io"
    ];

    trusted-public-keys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    pkgs.jetbrains-mono
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
  ];

  boot.supportedFilesystems = [
    "bcachefs"
    "btrfs"
  ];
  boot.kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.wireless = {
    enable = true;
    dbusControlled = false;
    userControlled.enable = true;
  };

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = false;

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  users.users.theo = {
    isNormalUser = true;
    description = "Theo";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
    packages = [
      pkgs.librewolf
      pkgs.foot
      pkgs.tofi
      pkgs.grim
      pkgs.slurp
      pkgs.ffmpeg_7-full
      pkgs.jdk22
      pkgs.neovide
      pkgs.hyprlandPlugins.hyprexpo
      pkgs.hyprlandPlugins.hy3
      pkgs.hyprlandPlugins.hyprtrails
      pkgs.hyprlandPlugins.hyprwinwrap
      pkgs.hyprlandPlugins.hyprscroller
      pkgs.nodejs_22
      pkgs.blender
    ];
  };

  programs.hyprland = {
    enable = true;
  };

  environment.systemPackages = [
    pkgs.age
    pkgs.nushell
    pkgs.helix
    pkgs.gitoxide
    pkgs.gitMinimal
    pkgs.uutils-coreutils-noprefix
    pkgs.ripgrep
    pkgs.skim
    pkgs.sd
    pkgs.fd
    pkgs.hyperfine
    pkgs.broot
    pkgs.zellij
    pkgs.nix-output-monitor
    pkgs.attic-client
    pkgs.attic-server
    pkgs.btop
    pkgs.fastfetch
    pkgs.wpa_supplicant
    pkgs.dhcpcd
    pkgs.iw
    pkgs.rustup
    pkgs.llvmPackages.libcxxClang
    pkgs.llvmPackages.bintools
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 200;
    algorithm = "zstd";
  };

  nix.optimise = {
    automatic = true;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.openssh.enable = true;

  services.kanata = {
    enable = true;
  };

  services.atticd = {
    enable = true;
    credentialsFile = "/etc/nixos/.env";
    settings = {
      listen = "[::1]:8080";
      chunking = {
        nar-size-threshold = 64 * 1024;
        min-size = 16 * 1024;
        avg-size = 64 * 1024;
        max-size = 256 * 1024;
      };
    };
  };

  boot.binfmt.emulatedSystems = [
    "wasm32-wasi"
    "x86_64-windows"
    "aarch64-linux"
    "riscv64-linux"
    "riscv32-linux"
  ];

  networking.firewall.enable = false;

  environment.noXlibs = false;

  sops.defaultSopsFile = ./secrets.json;

  system.stateVersion = "24.05";
}
