{
  pname,
  version,
  src,
  workers-rs,
  esbuild,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    esbuild
  ];

  postUnpack = ''
    cp ${workers-rs}/worker-build/src/js/shim.js $sourceRoot
  '';

  # https://github.com/cloudflare/workers-rs/blob/38af58acc4e54b29c73336c1720188f3c3e86cc4/worker-build/src/main.rs#L51-L55
  buildPhase = ''
    substituteInPlace shim.js \
      --replace-fail "\$WAIT_UNTIL_RESPONSE" ""

    esbuild --bundle \
      --format=esm \
      --external:./index.wasm \
      --external:cloudflare:sockets \
      --external:cloudflare:workers \
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
