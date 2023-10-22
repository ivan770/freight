# Freight

Build your Rust-based Cloudflare Workers® with Nix!

* Automatically installs `wasm-pack` and `wasm-bindgen` by analyzing project dependencies.
* Maintains compatibility with the `worker-build` build process.
* Supports custom Rust toolchains.

## Getting started

You can use the following command to create a new Nix project with pre-configured Nix Flake:

```sh
nix flake init -t github:ivan770/freight
cargo update
wrangler deploy
```

Make sure that your Nix installation [supports Flakes](https://nixos.wiki/wiki/Flakes#Enable_flakes).

## Usage

Freight provides a single function named `mkWorker`, that allows you to build your projects.

`mkWorker :: set -> drv`

This function encapsulates both building (with `wasm-pack` and `wasm-bindgen`) and bundling (with `esbuild`) steps
of a project build lifecycle.

Required attributes are `pname`, `version` and `src`.

You may specify any attributes supported by the
[`mkCargoDerivation`](https://crane.dev/API.html#cranelibmkcargoderivation)
from the [crane](https://github.com/ipetkov/crane) project.

You may optionally replace the default Rust toolchain with your own using the `craneLib` attribute.
See [crane documentation](https://crane.dev/examples/custom-toolchain.html) for more information on how to use custom toolchains.

## License

This project is licensed under Apache License, Version 2.0.

Cloudflare, the Cloudflare logo, and Cloudflare Workers are trademarks and/or registered trademarks of Cloudflare, Inc. in the United States and other jurisdictions.

