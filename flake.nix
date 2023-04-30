{
  description = "A flake for zig-bootstrap";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, ... }: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            cmake
            gdb
            libxml2
            ninja
            qemu
            wasmtime
            zlib
            python3
          ] ++ (with llvmPackages_15; [
            clang
            clang-unwrapped
            lld
            llvm
          ]);

          hardeningDisable = [ "all" ];
        };
        # For compatibility with older versions of the `nix` binary
        devShell = self.devShells.${system}.default;

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zig";
          # TODO: Fix the output of `zig version`.
          version = "0.10.0-dev";
          src = self;

          nativeBuildInputs = with pkgs; [
            cmake
          ] ++ (with llvmPackages_15; [
            libclang
            lld
            llvm
          ]);

          preBuild = ''
            export HOME=$TMPDIR;
          '';

          cmakeFlags = [
            # https://github.com/ziglang/zig/issues/12069
            "-DZIG_STATIC_ZLIB=on"
          ];
        };
      }
  );
}
