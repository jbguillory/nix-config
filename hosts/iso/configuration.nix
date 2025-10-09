{
  pkgs,
  modulesPath,
  system,
  lib,
  user,
  ...
}:
let
  drivePassword = builtins.getEnv "DRIVE_PASSWORD";
  hostname = builtins.getEnv "HOSTNAME";
  token = builtins.getEnv "GITLAB_TOKEN";
  run-install = pkgs.writeShellApplication {
    name = "run-install";
    runtimeInputs = with pkgs; [
      git
      disko
      nh
    ];
    text = (
      builtins.replaceStrings
        [
          "__USER__"
          "__HOSTNAME__"
          "__DRIVE_PASSWORD__"
        ]
        [ user.name hostname drivePassword ]
        (builtins.readFile ./install.sh)
    );
  };

in
{

  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${modulesPath}/installer/cd-dvd/channel.nix"
  ];

  # Enable libvirtd and configure virtualization support
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable KVM modules (for hardware acceleration if supported)
  # boot.kernelModules = [ "kvm" "kvm-intel" "kvm-amd" ]; # Add both; only one will load depending on CPU

  # Add your user to the libvirtd group
  users.users.${user.name} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "libvirtd"
      "networkmanager"
    ];
  };

  nix = {
    channel.enable = false;
    settings = {
      access-tokens = "code.il2.gamewarden.io=PAT:${token}";
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
  };
  isoImage = {
    isoName = lib.mkForce "nixinstaller.iso";
    contents = [
      {
        source = ../../.;
        target = "cfg";
      }
    ];
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.hostPlatform = system;
  environment.systemPackages = with pkgs; [
    run-install
    disko
    vim
    git
  ];
}
  {
    # Enable virtualization
    virtualisation = {
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };
    environment.systemPackages = with pkgs; [ OVMF ];
    # Add your user to the libvirtd group
    users.users.john-guillory.extraGroups = [ "libvirtd" ];

    # Enable KVM
    boot.kernelModules = [ "kvm-intel" ]; # Use "kvm-amd" for AMD processors

    # Optional: Enable nested virtualization
    boot.extraModprobeConfig = "options kvm_intel nested=1";
  }
