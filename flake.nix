{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.pkgsStatic.stdenvNoCC.mkDerivation {
            name = "kontti-binaries";
            phases = [
              "installPhase"
              "fixupPhase"
            ];
            installPhase = ''
              mkdir -p $out/bin
              cp ${pkgs.pkgsStatic.dash}/bin/dash $out/bin/sh
              cp ${pkgs.pkgsStatic.su}/bin/su $out/bin/
              cp ${pkgs.pkgsStatic.coreutils}/bin/chmod $out/bin/
            '';
          };
        }
      );
    };
}
