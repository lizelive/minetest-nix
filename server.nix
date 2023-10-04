{withSystem, ...}: {
  flake.nixosModules.default = {pkgs, ...}: {
    imports = [./nixos-module.nix];
    services.foo.package = withSystem pkgs.stdenv.hostPlatform.system (
      {config, ...}:
        config.packages.default
    );
  };
}
