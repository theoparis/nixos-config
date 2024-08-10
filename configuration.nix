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
				version = "git";
				src = inputs.blender;
				cmakeFlags = old.cmakeFlags ++ [
					"-DWITH_VULKAN_BACKEND=ON"
					"-DWITH_VULKAN_MOLTENVK=ON"
					"-DWITH_EXPERIMENTAL_FEATURES=ON"
				];

				buildInputs = old.buildInputs ++ [
					super.vulkan-headers
					super.vulkan-loader
				];
			});
		})
	];

	nix.settings = {
		experimental-features = [ "ca-derivations" "nix-command" "flakes" ];
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
		(pkgs.nerdfonts.override {
			fonts = ["JetBrainsMono"];
		})
		pkgs.jetbrains-mono
		pkgs.noto-fonts
		pkgs.noto-fonts-color-emoji
	];
	
	boot.supportedFilesystems = [ "bcachefs" "btrfs" ];
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
		extraGroups = [ "networkmanager" "wheel" ];
		shell = pkgs.nushell;
		packages = [
			pkgs.librewolf
			pkgs.foot
			pkgs.tofi
			pkgs.grim
			pkgs.slurp
			pkgs.ffmpeg_7
			pkgs.jdk22
			pkgs.neovide
			pkgs.hyprlandPlugins.hyprexpo
			pkgs.hyprlandPlugins.hy3
			pkgs.hyprlandPlugins.hyprtrails
			pkgs.hyprlandPlugins.hyprwinwrap
			pkgs.hyprlandPlugins.hyprscroller
			pkgs.nodejs_22
		];
	};

	programs.hyprland = {
		enable = true;
	};

	environment.systemPackages = with pkgs; [
		curlHTTP3
		neovim
		gitoxide
		gitMinimal
		uutils-coreutils-noprefix
		ripgrep
		skim
		sd
		fd
		hyperfine
		broot
		zellij
		nix-output-monitor
		attic-client
		attic-server
		btop
		fastfetch
		wpa_supplicant
		dhcpcd
		iw
		rustup
		llvmPackages.libcxxClang
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

	system.stateVersion = "24.05"; 
}
