{ config, lib, pkgs, modulesPath, ... }:

{
	nix.settings.max-jobs = 12;

	imports = [
		"${modulesPath}/installer/scan/not-detected.nix"
	];

	boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "uas" "sd_mod" "sr_mod" "sdhci_pci" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-amd" ];
	boot.extraModulePackages = [ ];

	fileSystems."/" = {
			device = "/dev/disk/by-uuid/d6eb77bb-c34c-433e-a967-370bbf9b528a";
			fsType = "btrfs";
			options = [ "compress=zstd:6" ];
	};

	fileSystems."/boot" = {
			device = "/dev/disk/by-uuid/4C8C-56FB";
			fsType = "vfat";
			options = [ "fmask=0022" "dmask=0022" ];
	};

	swapDevices = [ ];

	networking.useDHCP = lib.mkDefault true;

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
