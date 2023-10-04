{
  description = "Description for the project";

  inputs.game = {
    type = "github";
    owner = "minetest";
    repo = "minetest_game";
    flake = false;
  };

  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    game,
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
        packages.server = pkgs.minetestserver;
        packages.minetest = pkgs.callPackage ./package/minetest.nix { };

        packages.default = pkgs.linkFarm "server" [ { name = "data"; path = game; } { name = "bin"; path = "${pkgs.minetestserver}/bin"; } ];


        packages.old = pkgs.stdenv.mkDerivation {
          name = "minetestserver";
          src = ./.;
          buildInputs = [pkgs.minetestserver];
          phases = ["buildPhase"];
          buildPhase = ''
            mkdir -p $out/bin
            ln -s ${pkgs.minetestserver}/bin/minetestserver $out/bin/minetestserver
            cp -r ${pkgs.minetestserver}/share/ $out/share/
            chmod +w $out/share/minetest/games/
            # cp -r $src/ $out/share/minetest/games/ld52/
            # chmod +w $out/share/minetest/games/ld52/mods/
          '';
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
        outputs.game = game;
        #   outputs.data = fetchFromGitHub {
        #   owner = "minetest";
        #   repo = "minetest_game";
        #   rev = dataRev;
        #   sha256 = dataSha256;
        # };
      };
    };
}
