{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  nix.settings.max-jobs = 12;

  imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "uas"
    "sd_mod"
    "sr_mod"
    "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1063681d-6d2f-4413-ba8c-3c34a2e54b5a";
    fsType = "bcachefs";
    options = [ "compress=zstd:6" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/02E6-B2D9";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
