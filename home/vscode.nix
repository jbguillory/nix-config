{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  vscode-marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in
{
  home.packages = [ pkgs.nil ];

  programs.vscode = {
    enable = true;
    profiles.default.extensions = with vscode-marketplace; [
      asvetliakov.vscode-neovim
    ];

    # Add user settings here
    userSettings = {
      "editor.lineNumbers" = "relative";
      # Add other settings if needed
      # "editor.fontSize" = 14;
      # "workbench.colorTheme" = "Default Dark+";
    };
  };
}
