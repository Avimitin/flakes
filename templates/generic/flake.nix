{
  description = "Generic devshell setup";

  inputs = {
    # The nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utility functions
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils }:
    let
      overlay = import ./overlay.nix;
      pkgsForSys = system: import nixpkgs { inherit system; };
      perSystem = (system:
        let
          pkgs = pkgsForSys system;
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [ ];
          };

          formatter = pkgs.nixpkgs-fmt;
          legacyPackages = pkgs;
        });
    in
    {
      # Other system-independent attr
      inherit inputs;
      overlays.default = overlay;
    } //

    flake-utils.lib.eachDefaultSystem perSystem;
}
