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

  # https://github.com/cloudflare/workers-rs/blob/fea2e8e14d8807d422bde6bfab837914a0019e8d/worker-build/src/main.rs#L19-L24
  wasmImport = builtins.readFile ./snippets/import.js;

  # https://github.com/cloudflare/workers-rs/blob/fea2e8e14d8807d422bde6bfab837914a0019e8d/worker-build/src/main.rs#L26-L32
  wasmImportReplacement = builtins.readFile ./snippets/importReplacement.js;

  filteredArgs = builtins.removeAttrs args [
    "craneLib"
  ];

  extraWasmPackArgs = args.extraWasmPackArgs or [];
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
            --release ${lib.escapeShellArgs extraWasmPackArgs}

          substituteInPlace build/index_bg.js \
            --replace "${wasmImport}" "${wasmImportReplacement}"
        '';

      doInstallCargoArtifacts = args.doInstallCargoArtifacts or false;

      installPhaseCommand =
        args.installPhaseCommand
        or ''
          mkdir $out

          mv build/index_bg.js $out
          mv build/index_bg.wasm $out/index.wasm

          [ -f build/snippets ] && mv build/snippets $out
        '';
    })
