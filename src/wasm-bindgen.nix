{
  lib,
  wasm-bindgen-cli,
  ...
}: args: let
  inherit
    (builtins)
    fromTOML
    pathExists
    readFile
    sort
    ;

  inherit
    (lib)
    head
    isAttrs
    lists
    mapAttrs
    mapAttrsToList
    strings
    trivial
    ;

  versions = mapAttrs (version: {
    hash,
    cargoHash,
  }:
    wasm-bindgen-cli.override {
      inherit version hash cargoHash;
    }) {
    "0.2.100" = {
      hash = "sha256-3RJzK7mkYFrs7C/WkhW9Rr4LdP5ofb2FdYGz1P7Uxog=";
      cargoHash = "sha256-tD0OY2PounRqsRiFh8Js5nyknQ809ZcHMvCOLrvYHRE=";
    };
    "0.2.92" = {
      hash = "sha256-1VwY8vQy7soKEgbki4LD+v259751kKxSxmo/gqE6yV0=";
      cargoHash = "sha256-aACJ+lYNEU8FFBs158G1/JG8sc6Rq080PeKCMnwdpH0=";
    };
    "0.2.87" = {
      hash = "sha256-0u9bl+FkXEK2b54n7/l9JOCtKo+pb42GF9E1EnAUQa0=";
      cargoHash = "sha256-AsZBtE2qHJqQtuCt/wCAgOoxYMfvDh8IzBPAOkYSYko=";
    };
    "0.2.86" = {
      hash = "sha256-56EOiLbdgAcoTrkyvB3t9TjtLaRvGxFUXx4haLwE2QY=";
      cargoHash = "sha256-4CPBmz92PuPN6KeGDTdYPAf5+vTFk9EN5Cmx4QJy6yI=";
    };
    "0.2.84" = {
      hash = "sha256-0rK+Yx4/Jy44Fw5VwJ3tG243ZsyOIBBehYU54XP/JGk=";
      cargoHash = "sha256-vcpxcRlW1OKoD64owFF6mkxSqmNrvY+y3Ckn5UwEQ50=";
    };
    "0.2.80" = {
      hash = "sha256-f3XRVuK892TE6xP7eq3aKpl9d3fnOFxLh+/K59iWPAg=";
      cargoHash = "sha256-WJ5hPw2mzZB+GMoqo3orhl4fCFYKWXOWqaFj1EMrb2Q=";
    };
  };

  cargoLockPath = args.src + "/Cargo.lock";

  wasmBindgenEntry =
    lists.findFirst
    ({name, ...}: name == "wasm-bindgen")
    null
    (fromTOML (readFile cargoLockPath)).package;

  fallbackVersion = head (sort (a: b: strings.versionOlder b.version a.version) (
    mapAttrsToList (version: drv: {
      inherit version drv;
    })
    versions
  ));

  matchingVersion =
    if (pathExists cargoLockPath && isAttrs wasmBindgenEntry)
    then versions."${wasmBindgenEntry.version}"
    else
      trivial.warn ''
        Unable to parse Cargo.lock file to acquire the required `wasm-bindgen` version.
        Using ${fallbackVersion.version} as a fallback one.
      ''
      fallbackVersion.drv;
in
  matchingVersion
