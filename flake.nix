  {
  description = "Public DOH Servers";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, ... }:
    let
      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
         public_doh_servers = pkgs.stdenv.mkDerivation {
          name = "public_doh_servers";
          src = self;
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir $out;
            cp $src/*.list $out;
            cp $src/*.set $out;
          '';
        };
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.public_doh_servers);
    };
}
