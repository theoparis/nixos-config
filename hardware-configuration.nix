{ config, lib, pkgs, modulesPath, ... }:

{
	nix.settings.max-jobs = 4;

	imports = [
		"${modulesPath}/installer/scan/not-detected.nix"
	];

	boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "uas" "sd_mod" "sr_mod" "sdhci_pci" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" = {
			device = "/dev/disk/by-uuid/073dec37-eca3-4ab4-9388-7fc3eacddffb";
			fsType = "btrfs";
			options = [ "subvol=@" "compress=zstd:6" ];
	};

	fileSystems."/boot" = {
			device = "/dev/disk/by-uuid/BBA2-E38A";
			fsType = "vfat";
			options = [ "fmask=0022" "dmask=0022" ];
	};

	swapDevices = [ ];

	networking.useDHCP = lib.mkDefault true;

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
