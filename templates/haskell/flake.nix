{
  description = "Flake for Haskell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    let
      overlay = import ./nix/overlay.nix;
      assertWith = expr: msg: expr || builtins.throw msg;
      mkFlakeOutput = extra: builder:
        assert assertWith (builtins.typeOf extra == "set") "First argument is not a set";
        assert assertWith (builtins.typeOf builder == "lambda") "Second argument is not a lambda";
        (flake-utils.lib.eachDefaultSystem (system:
          let
            pkgs = import nixpkgs { overlays = [ overlay ]; inherit system; };
          in
          builder pkgs
        )) // extra;
    in
    mkFlakeOutput { inherit inputs; overlays.default = overlay; } (pkgs: {
      formatter = pkgs.nixpkgs-fmt;
      legacyPackages = pkgs;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          (pkgs.haskellPackages.ghcWithPackages (hsPkgs: [ hsPkgs.aeson ]))
          pkgs.fourmolu
          pkgs.haskell-language-server
        ];
      };
    });
}
