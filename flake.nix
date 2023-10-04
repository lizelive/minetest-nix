{
  description = "Description for the project";

  inputs.minetest_game = {
    type = "github";
    owner = "minetest";
    repo = "minetest_game";
    flake = false;
  };

  inputs.minetest_src = {
    type = "github";
    owner = "minetest";
    repo = "minetest";
    flake = false;
  };

  inputs.minetest_wasm = {
    type = "github";
    owner = "paradust7";
    repo = "minetest-wasm";
    ref = "main";
    flake = false;
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    minetest_game,
    minetest_src,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.minetestserver;
        formatter = pkgs.alejandra;
        packages.minetest = pkgs.callPackage ./package/minetest.nix {};
        packages.default = pkgs.callPackage ./package/hello/default.nix {};
        # packages.default = pkgs.callPackage ./package/emsdk/default.nix {};
        # packages.default = pkgs.linkFarm "lf" [
        #   {
        #     name = "data";
        #     path = minetest_game;
        #   }
        #   {
        #     name = "bin";
        #     path = "${pkgs.minetestserver}/bin";
        #   }
        # ];

        # packages.old = pkgs.stdenv.mkDerivation {
        #   name = "minetestserver";
        #   src = ./.;
        #   buildInputs = [pkgs.minetestserver];
        #   phases = ["buildPhase"];
        #   buildPhase = ''
        #     mkdir -p $out/bin
        #     ln -s ${pkgs.minetestserver}/bin/minetestserver $out/bin/minetestserver
        #     cp -r ${pkgs.minetestserver}/share/ $out/share/
        #     chmod +w $out/share/minetest/games/
        #     # cp -r $src/ $out/share/minetest/games/ld52/
        #     # chmod +w $out/share/minetest/games/ld52/mods/
        #   '';
        # };
      };
    };
}
