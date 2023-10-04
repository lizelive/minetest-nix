{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  jre_minimal,
  python3,
}: let
  version = "3.1.46";
  emsdk_src = fetchFromGitHub {
    owner = "emscripten-core";
    repo = "emsdk";
    rev = version;
    sha256 = "sha256-IzrJ9YI0jhUyFnYHJIoOpExE0nHXD0uTFs0JQCw+gK8=";
  };
in
  stdenv.mkDerivation {
    name = "emsdk";
    src = emsdk_src;
    phases = ["installPhase"];
    patches = [./emsdk_emcc.patch ./emsdk_file_packager.patch ./emsdk_dirperms.patch ./emsdk_setlk.patch];
    nativeBuildInputs = [ python3 ];
    installPhase = ''
      $src/emsdk install latest
      $src/emsdk activate latest
    '';
  }
