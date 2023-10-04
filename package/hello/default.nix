{
  lib,
  stdenv,
  gcc,
  emscripten,
  pkg-config,
  autoconf,
  automake,
  libtool,
  gnumake,
  libxml2,
  nodejs,
  openjdk,
  json_c,
  zlib,
  fetchgit,
  buildEmscriptenPackage,
  simple-http-server,
  writeShellApplication,
}: let
  src = ./.;
  xmlmirror = buildEmscriptenPackage rec {
    name = "xmlmirror";

    buildInputs = [pkg-config autoconf automake libtool gnumake libxml2 nodejs openjdk json_c];
    nativeBuildInputs = [pkg-config zlib];

    src = fetchgit {
      url = "https://gitlab.com/odfplugfest/xmlmirror.git";
      rev = "4fd7e86f7c9526b8f4c1733e5c8b45175860a8fd";
      hash = "sha256-i+QgY+5PYVg5pwhzcDnkfXAznBg3e8sWH2jZtixuWsk=";
    };

    configurePhase = ''
      rm -f fastXmlLint.js*
      # a fix for ERROR:root:For asm.js, TOTAL_MEMORY must be a multiple of 16MB, was 234217728
      # https://gitlab.com/odfplugfest/xmlmirror/issues/8
      sed -e "s/TOTAL_MEMORY=234217728/TOTAL_MEMORY=268435456/g" -i Makefile.emEnv
      # https://github.com/kripken/emscripten/issues/6344
      # https://gitlab.com/odfplugfest/xmlmirror/issues/9
      sed -e "s/\$(JSONC_LDFLAGS) \$(ZLIB_LDFLAGS) \$(LIBXML20_LDFLAGS)/\$(JSONC_LDFLAGS) \$(LIBXML20_LDFLAGS) \$(ZLIB_LDFLAGS) /g" -i Makefile.emEnv
      # https://gitlab.com/odfplugfest/xmlmirror/issues/11
      sed -e "s/-o fastXmlLint.js/-s EXTRA_EXPORTED_RUNTIME_METHODS='[\"ccall\", \"cwrap\"]' -o fastXmlLint.js/g" -i Makefile.emEnv
    '';

    buildPhase = ''
      EM_CACHE=$TMPDIR/emscripten
      mkdir -p $EM_CACHE
      HOME=$TMPDIR
      make -f Makefile.emEnv
    '';

    outputs = ["out" "doc"];

    installPhase = ''
      mkdir -p $out/share
      mkdir -p $doc/share/${name}

      cp Demo* $out/share
      cp -R codemirror-5.12 $out/share
      cp fastXmlLint.js* $out/share
      cp *.xsd $out/share
      cp *.js $out/share
      cp *.xhtml $out/share
      cp *.html $out/share
      cp *.json $out/share
      cp *.rng $out/share
      cp README.md $doc/share/${name}
    '';
    checkPhase = ''

    '';
  };
  hello_emscripten = stdenv.mkDerivation {
    name = "hello_emscripten";
    inherit src;

    nativeBuildInputs = [emscripten];

    buildPhase = ''
      emcc -o index.html *.c
    '';

    installPhase = ''
      mkdir -p $out/share
      cp *.js *.html *.wasm $out/share
    '';
  };
  app = xmlmirror;
in
  writeShellApplication {
    name = "hello";

    runtimeInputs = [simple-http-server app];

    text = ''
      simple-http-server --index --coep --coop --cors -- ${app}/share/
    '';
  }
# (nix build .#) && tree result && nix run nixpkgs#python3 -- -m http.server --directory result/share/
# nix run nixpkgs#nix-tree  .#hello

