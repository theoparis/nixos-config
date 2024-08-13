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
    servo = {
      url = "github:servo/servo";
      flake = false;
    };
    firefox = {
      url = "github:mozilla/gecko-dev";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, attic, ... }@inputs:
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
