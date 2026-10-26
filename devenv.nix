{ pkgs, ... }:

{
  packages = [
    pkgs.neovim
    pkgs.stylua
    pkgs.selene
    pkgs.lua-language-server
  ];

  scripts.run-tests.exec = ''
    XDG_CACHE_HOME="$DEVENV_STATE/test-cache" nvim --clean -l tests/run.lua
  '';

  scripts.lint.exec = ''
    stylua --check lua plugin tests && selene lua plugin tests
  '';

  scripts.format.exec = ''
    stylua lua plugin tests
  '';
}
