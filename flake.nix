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
              cp ${pkgs.pkgsStatic.su-exec}/bin/su-exec $out/bin/
              cp ${pkgs.pkgsStatic.coreutils}/bin/chmod $out/bin/
            '';
          };

          docker = pkgs.dockerTools.buildImage {
            name = "kontti";
            copyToRoot = with pkgs; [
              pkgs.dockerTools.usrBinEnv
              pkgs.dockerTools.caCertificates

              (stdenvNoCC.mkDerivation {
                name = "chmod";
                phases = [
                  "installPhase"
                  "fixupPhase"
                ];
                installPhase = ''
                  mkdir -p $out/bin
                  cp ${pkgs.coreutils}/bin/chmod $out/bin
                '';
              })

              su-exec
              dash
              jre
            ];
          };
        }
      );
    };
}
