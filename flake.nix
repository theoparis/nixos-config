{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		attic = {
			url = "github:zhaofengli/attic";
			inputs.nixpkgs.follows = "/nixpkgs";
		};
	};

	outputs = { nixpkgs, attic, ...}@inputs:
	let
		system = "x86_64-linux";
		
		pkgs = import nixpkgs {
				inherit system;
				overlays = [];
		};
	in {
		nixosConfigurations = {
			t420 = nixpkgs.lib.nixosSystem {
				inherit system;
				specialArgs = { inherit inputs; };
				modules = [
					({
						nixpkgs.pkgs = pkgs;
					})
					./configuration.nix
					./systems/t420.nix
					attic.nixosModules.atticd
				];
			};
				
			gigamachine = nixpkgs.lib.nixosSystem {
				inherit system;
				specialArgs = { inherit inputs; };
				modules = [
					({
						nixpkgs.pkgs = pkgs;
					})
					./configuration.nix
					./systems/gigamachine.nix
					attic.nixosModules.atticd
				];
			};
		};
	};
}

