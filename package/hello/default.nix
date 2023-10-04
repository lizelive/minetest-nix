{
  lib,
  stdenv,
  gcc,
  emscripten,
}: let
src = ./;
in
  stdenv.mkDerivation {
    name = "hello_world";
    inherit src;
    phases = ["installPhase"];
    nativeBuildInputs = [ gcc ];
    installPhase = ''
      $src/emsdk install latest
      $src/emsdk activate latest
    '';
  }
