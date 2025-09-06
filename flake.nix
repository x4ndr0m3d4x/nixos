{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
    	url = "github:nix-community/home-manager/master";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
    	url = "github:0xc000022070/zen-browser-flake";
    };

    caelestia-shell = {
    	url = "github:caelestia-dots/shell";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, caelestia-shell, ... } @ inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
	inherit system;

	config = {
	    allowUnfree = true;
	};
    };
  in
  {
    nixosConfigurations = {
	nixos = nixpkgs.lib.nixosSystem {
	    inherit system;
	    modules = [ 
	    	# Configuration
	    	./configuration.nix 

		# System packages (can use inputs from here)
		({ pkgs, ... }: {
		    environment.systemPackages = with pkgs; [
			discord
			spotify
			pavucontrol
            wakatime

            cargo
            rustc
            rustfmt
            clippy
            rust-analyzer

			inputs.zen-browser.packages.${system}.default
		    ];
		})
	    ];
	};
    };
    homeConfigurations = {
	ashley = home-manager.lib.homeManagerConfiguration {
	    inherit pkgs;
	    modules = [
	      ./home.nix
	      caelestia-shell.homeManagerModules.default
	    ];
	};
    };
  };
}
