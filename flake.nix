{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    blender = {
      url = "github:blender/blender";
      flake = false;
    };
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "/nixpkgs";
    };
    vulkan-headers = {
      url = "github:khronosgroup/vulkan-headers";
      flake = false;
    };
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      nixpkgs,
      attic,
      sops-nix,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        t420 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/t420.nix
            attic.nixosModules.atticd
            sops-nix.nixosModules.sops
          ];
        };

        gigamachine = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            ./systems/gigamachine.nix
            attic.nixosModules.atticd
            sops-nix.nixosModules.sops
          ];
        };

        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
          modules = [
            ./configuration.nix
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
            "${nixpkgs}/nixos/modules/profiles/minimal.nix"
            attic.nixosModules.atticd
            sops-nix.nixosModules.sops
            (
              { lib, ... }:
              {
                isoImage.edition = lib.mkOverride 500 "minimal";
                boot.supportedFilesystems.zfs = lib.mkForce false;
              }
            )
          ];
        };
      };
    };
}
