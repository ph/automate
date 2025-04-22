{
  description = "PH's NixOS automate";

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, home-manager, catppuccin, firefox-addons, ... }@inputs: {
    nixosConfigurations = builtins.listToAttrs(
      map(host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [


            catppuccin.nixosModules.catppuccin
            disko.nixosModules.disko

            ./hosts/${host}

            home-manager.nixosModules.home-manager
            {
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.ph = {
                nixpkgs.overlays = [ firefox-addons.overlays.default ];

                imports = [
                  catppuccin.homeModules.catppuccin
                  ./modules/home.nix
                ];
              };
            }




          ];
        };
      })(builtins.attrNames (builtins.readDir ./hosts ))
    );
  };
}
