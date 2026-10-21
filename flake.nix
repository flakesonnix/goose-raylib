{
  description = "Goose bindings for raylib (goose-raylib package)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        name = "goose-raylib-dev";
        buildInputs = with pkgs; [
          cmake
          gcc
          raylib
          git
        ];

        shellHook = ''
          echo "=== goose-raylib dev shell ==="
          echo "Goose compiler:   /home/lucy/Documents/recreational/goose/build/goose"
          echo "Build minimal:    goose build minimal.goose && ./minimal"
          echo "Run window test:  goose build test_window.goose && ./test_window"
          echo "Typecheck:        goose check raylib.goose"
          echo "Full Pong:        see your Pong repo"
          echo "============================================================"
        '';
      };

      packages.${system} = {};
    };
}
