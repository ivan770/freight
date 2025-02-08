{
  binaryen,
  callPackage,
  fetchFromGitHub,
  lib,
  wasm-pack,
  craneLib,
  ...
}: args: let
  wasm-bindgen-cli = (callPackage ./wasm-bindgen.nix {}) args;

  filteredArgs = builtins.removeAttrs args [
    "craneLib"
  ];

  wasmPackPath = args.wasmPackPath or ".";
  extraWasmPackArgs = args.extraWasmPackArgs or [];

  buildDir = "${wasmPackPath}/build";
in
  (args.craneLib or craneLib).mkCargoDerivation (filteredArgs
    // {
      # Make sure that build succeeds even if user didn't provide cargoArtifacts value
      cargoArtifacts = args.cargoArtifacts or null;

      nativeBuildInputs =
        (args.nativeBuildInputs or [])
        ++ [
          wasm-bindgen-cli
          wasm-pack
          binaryen
        ];

      buildPhaseCargoCommand =
        args.buildPhaseCargoCommand
        or ''
          HOME=$(mktemp -d)

          wasm-pack build \
            --no-typescript \
            --target bundler \
            --out-dir build \
            --out-name index \
            --release \
            ${wasmPackPath} ${lib.escapeShellArgs extraWasmPackArgs}
        '';

      doInstallCargoArtifacts = args.doInstallCargoArtifacts or false;

      installPhaseCommand =
        args.installPhaseCommand
        or ''
          mkdir $out

          mv ${buildDir}/index_bg.js $out
          mv ${buildDir}/index_bg.wasm $out/index.wasm

          [ -f ${buildDir}/snippets ] && mv ${buildDir}/snippets $out
        '';
    })
