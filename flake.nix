{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        {
          system,
          ...
        }:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          # packages.default =
          #   (pkgs.lean.buildLeanPackage {
          #     name = "lambda-genesis";
          #     roots = [ "Main" ];
          #     src = pkgs.lib.cleanSource ./.;
          #   }).executable;

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              # Lua tools
              lua
              stylua
              luaPackages.luacheck

              # Nix tools
              nil
              statix

              # Temporary workaround for copilot-cli direnv integration bug
              # See: https://github.com/github/copilot-cli/issues/731
              # TODO: Remove once the upstream issue is resolved
              bashInteractive
            ];
          };
        };
    };
}
