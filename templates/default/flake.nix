{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    freight = {
      url = "github:ivan770/freight";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    freight,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: {
        packages.default = freight.lib.${system}.mkWorker {
          pname = "hello";
          version = "0.1.0";

          src = ./.;
        };
      }
    );
}
