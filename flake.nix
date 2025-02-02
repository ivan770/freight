{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };

    crane = {
      type = "github";
      owner = "ipetkov";
      repo = "crane";
    };

    fenix = {
      type = "github";
      owner = "nix-community";
      repo = "fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    workers-rs = {
      type = "github";
      owner = "cloudflare";
      repo = "workers-rs";
      flake = false;
    };

    flake-utils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
    };
  };

  outputs = {
    nixpkgs,
    crane,
    fenix,
    workers-rs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };

        rustToolchain = with fenix.packages.${system};
          combine [
            stable.rustc
            stable.cargo
            targets.wasm32-unknown-unknown.stable.rust-std
          ];
      in {
        lib.mkWorker = pkgs.lib.makeOverridable (
          {esbuildPnameSuffix ? "-bundle", ...} @ args:
            pkgs.callPackage ./src/esbuild.nix {
              inherit workers-rs;
              inherit (args) version;

              pname = "${args.pname}${esbuildPnameSuffix}";

              src =
                (pkgs.callPackage ./src/wasm-pack.nix {
                  craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;
                })
                args;
            }
        );

        formatter = pkgs.alejandra;
      }
    )
    // {
      templates.default = {
        path = ./templates/default;
        description = ''
          "Hello, world" project built with Freight
        '';
        welcomeText = ''
          Run `cargo update` to update the required `Cargo.lock` file.

          `wrangler.toml` file is pre-configured to use the default Nix output directory.

          You can use `wrangler deploy` command to deploy this project.
        '';
      };
    };
}
