note: this nix flake DOES NOT WORK, cython and poetry2nix are too much to deal with rn
{
  description = "finds words with similar length and low edit distance";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication defaultPoetryOverrides;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          word-scrungler = mkPoetryApplication {
            projectDir = self;
            overrides = poetry2nix.overrides.withDefaults (final: prev: {
              english-words  = prev.english-words.override {
                preferWheel=true;
              };
            });
#            defaultPoetryOverrides.extend
#              (self: super: {
#                english-words = super.english-words.overridePythonAttrs
#                (
#                  old: {
#            preferWheels = true;
#                    buildInputs = (old.buildInputs or [ ]) ++ [ super.setuptools ];
#                  }
#                );
#              });
          };
          default = self.packages.${system}.word-scrungler;
        };

        devShells.default = pkgs.mkShell {
          packages = [ poetry2nix.packages.${system}.poetry ];
        };
      });
}
