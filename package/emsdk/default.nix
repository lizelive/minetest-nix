{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}: {
  emsdk = stdenv.mkDerivation {
    name = "emsdk";
    src = sources.emsdk_src;
    phases = ["installPhase"];
    patches = [./emsdk_emcc.patch ./emsdk_file_packager.patch ./emsdk_dirperms.patch ./emsdk_setlk.patch];
    installPhase = ''
      ./emsdk install 3.1.25
      ./emsdk activate 3.1.25
    '';
  };
}
