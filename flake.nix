{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        # cubeb and OpenAL Soft dlopen() their audio backends at runtime.
        audioLibs = with pkgs; [
          libpulseaudio
          alsa-lib
          pipewire
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          # NixOS has no global library path, so make the backends findable by dlopen().
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath audioLibs;

          packages =
            audioLibs
            ++ (with pkgs; [
            gcc
            clang-tools
            cmake
            ninja
            pkg-config
            python3
            ffmpeg_7
            SDL2
            libusb1
            qt6.qtbase
            qt6.qtmultimedia
            qt6.qttools
          ]);
        };
      }
    );
}
