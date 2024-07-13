{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    clang-tools
    gcc14
    gnumake
    cmake
    codespell
    conan
    cppcheck
    doxygen
    gtest
    lcov
    # vcpkg
    # vcpkg-tool
  ] ++ (if system == "aarch64-darwin" then [ ] else [ gdb ]);
}
