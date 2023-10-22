{
  pname,
  version,
  src,
  workers-rs,
  esbuild,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    esbuild
  ];

  postUnpack = ''
    cp ${workers-rs}/worker-build/src/js/glue.js $sourceRoot
    cp ${workers-rs}/worker-build/src/js/shim.js $sourceRoot
  '';

  buildPhase = ''
    esbuild --bundle \
      --format=esm \
      --external:./index.wasm \
      --external:cloudflare:sockets \
      --outfile=shim.mjs \
      --minify \
      ./shim.js
  '';

  installPhase = ''
    mkdir $out

    cp $src/index.wasm $out
    mv shim.mjs $out
  '';
}
