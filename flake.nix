{
  description = "Goose bindings for raylib (goose-raylib package)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    raylib-src = {
      url = "github:raysan5/raylib/02566453880e06bec97f5b8160fa6fe1e98397ca";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, raylib-src }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      raylib = pkgs.raylib.overrideAttrs (_: {
        version = "6.2";
        src = raylib-src;
      });
    in {
      devShells.${system}.default = pkgs.mkShell {
        name = "goose-raylib-dev";
        buildInputs = with pkgs; [
          cmake
          gcc
          git
          pkg-config
          python3
          xvfb-run
          mesa
        ];
        packages = [ raylib ];

        shellHook = ''
          echo "goose-raylib: raylib 6.2, CMake and headless graphics test tools"
          echo "Set GOOSE to your Goose executable, then: python3 tests/run_3d.py"
        '';
      };

      packages.${system} = {};
    };
}
