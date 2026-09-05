{
  description = "NixOS from Scratch";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    areofyl-fetch.url = "github:areofyl/fetch";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      noctalia,
      noctalia-greeter,
      areofyl-fetch,
      zen-browser,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations.schizopad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
        ];
      };
    };
}
