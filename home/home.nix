{ pkgs, lib, ... }:
{
  imports = [
    ./vscode.nix
    ./zsh.nix
    ./obs.nix
    ./k9s.nix
  ];
  # programs = { k9s.settings.ui.skin = "skin"; };

  home.sessionPath = [ "$HOME/.cargo/bin" ];

  secondfront.hyprland.monitors = [
    # Setup your monitors
    {
      name = "DP-5";

      position = "0x0";
      # position = "auto-left";
      # width = 2560;
      # height = 1440;
      width = 1920;
      height = 1080;
      refreshRate = 60;
      workspace = "2";
    }
    {
      name = "DP-6";
      position = "1920x0";
      # position = "auto-right";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      workspace = "1";
    }
    {
      name = "eDP-1";
      position = "3840x0";
      # position = "auto";
      width = 1920;
      height = 1200;
      enabled = true;
      refreshRate = 60;
    }
  ];
  home.packages = with pkgs; [
    twofctl
    pulumi-bin
    nixfmt
    base16-schemes
    pulseaudio
    bash
    xarchiver
    go
    kubectx
    signal-desktop
    rustls-libssl
    typescript
    gcc
    openssl
    signal-desktop
    stern
    cosign
    rustlings
    rustup
    spotify
    dig
    dive
    rustc
    lsof
    brightnessctl
    hubble
    sops
    kail
    kyverno
    yq-go
    jq
    wget
    virt-manager
    qemu
    bridge-utils
    vde2
    usbutils
    google-chrome
    brave
  ];

  # download ubuntu and move home directory
  home.file.".local/bin/download-ubuntu-iso" = {
    text = ''
      #!/bin/sh
      cd ~/Downloads
      wget -O ubuntu-22.04.5-desktop-amd64.iso \
        "https://releases.ubuntu.com/22.04.5/ubuntu-22.04.5-desktop-amd64.iso"
    '';
    executable = true;
  };
  # Create VM setup script
  home.file.".local/bin/setup-ubuntu-vm" = {
    text = ''
      #!/bin/sh
      # Create VM directory
      mkdir -p ~/VMs/ubuntu-22.04
      # Create disk image (adjust size as needed)
      qemu-img create -f qcow2 ~/VMs/ubuntu-22.04/ubuntu.qcow2 50G
      echo "VM disk created. Use virt-manager to create the VM or run the installation script."
    '';
    executable = true;
  };
  # QEMU installation script
  home.file.".local/bin/install-ubuntu-vm" = {
    text = ''
      #!/bin/sh
      ISO_PATH="$HOME/Downloads/ubuntu-22.04.5-desktop-amd64.iso"
      DISK_PATH="$HOME/VMs/ubuntu-22.04/ubuntu.qcow2"
      # CAC Reader USB IDs - update these with your actual device IDs
      # Find your CAC reader with: lsusb
      # Common CAC readers:
      # SCM Microsystems: 04e6:e003
      # Gemalto: 08e6:3478
      # Update the line below with your actual vendor:product ID
      CAC_USB_ID="04e6:5116"  # Change this to match your CAC reader
      if [ ! -f "$ISO_PATH" ]; then
        echo "Ubuntu ISO not found at $ISO_PATH"
        echo "Run download-ubuntu-iso first"
        exit 1
      fi
      # Check if CAC reader is connected
      if lsusb | grep -q "$CAC_USB_ID"; then
        echo "CAC reader detected, enabling USB passthrough"
        USB_PASSTHROUGH="-device usb-host,vendorid=0x''${CAC_USB_ID%:*},productid=0x''${CAC_USB_ID#*:}"
      else
        echo "CAC reader not detected (looking for $CAC_USB_ID)"
        echo "VM will start without CAC reader passthrough"
        USB_PASSTHROUGH=""
      fi
      qemu-system-x86_64 \
        -enable-kvm \
        -m 4096 \
        -cpu host \
        -smp 4 \
        -drive file="$DISK_PATH",format=qcow2 \
        -cdrom "$ISO_PATH" \
        -boot d \
        -netdev user,id=net0 \
        -device virtio-net,netdev=net0 \
        -vga virtio \
        -display gtk,gl=on \
        -usb \
        -device usb-ehci,id=usb \
        $USB_PASSTHROUGH
    '';
    executable = true;
  };
  # Script to run the VM after installation
  home.file.".local/bin/run-ubuntu-vm" = {
    text = ''
      #!/bin/sh
      DISK_PATH="$HOME/VMs/ubuntu-22.04/ubuntu.qcow2"
      # CAC Reader USB IDs - update these with your actual device IDs
      # Find your CAC reader with: lsusb
      CAC_USB_ID="04e6:5116"  # Change this to match your CAC reader
      # Check if CAC reader is connected
      if lsusb | grep -q "$CAC_USB_ID"; then
        echo "CAC reader detected, enabling USB passthrough"
        USB_PASSTHROUGH="-device usb-host,vendorid=0x''${CAC_USB_ID%:*},productid=0x''${CAC_USB_ID#*:}"
      else
        echo "CAC reader not detected (looking for $CAC_USB_ID)"
        echo "VM will start without CAC reader passthrough"
        USB_PASSTHROUGH=""
      fi
      qemu-system-x86_64 \
        -enable-kvm \
        -m 4096 \
        -cpu host \
        -smp 4 \
        -drive file="$DISK_PATH",format=qcow2 \
        -netdev user,id=net0 \
        -device virtio-net,netdev=net0 \
        -vga virtio \
        -display gtk,gl=on \
        -usb \
        -device usb-ehci,id=ehci \
        -device qemu-xhci,id=xhci \
        $USB_PASSTHROUGH
    '';
    executable = true;
  };

  # stylix = {
  #   enable = true;
  #   cursor = {
  #     package = pkgs.bibata-cursors;
  #     name = "Bibata-Modern-Classic";
  #     size = 24;
  #   };
  # };

  programs.zed-editor.userSettings.vim_mode = lib.mkForce false;
  programs.zed-editor.userSettings.relative_line_numbers = lib.mkForce false;

  programs.git = {
    enable = true;

    includes = [
      {
        condition = "gitdir:~/personal/*";
        path = "/home/jbguillory/.config/git/config-personal";
      }
      {
        condition = "gitdir:~/nix-config/*";
        path = "/home/jbguillory/.config/git/config-personal";
      }
    ];

    extraConfig = {
      commit.template = "/home/jbguillory/.config/git/gitmessage";
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      windowrule = [
        "opacity 0.90,class:(dev.zed.Zed)"
        "float, title:^(MainPicker)$"
      ];
      workspace = [
        "1, monitor:DP-6"
        "special:spotify, on-created-empty: spotify"
        "special:chat, on-created-empty: slack && signal-desktop"
        "special:browser, on-created-empty: google-chrome"
        "special:notes, on-created-empty: kitty"
        "special:obs, on-created-empty: nvidia-offload obs --startvirtualcam --disable-shutdown-check"
      ];
      exec-once = [
        "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"
      ];
      bind = [
        "$mainMod, x, togglespecialworkspace, browser"
        "$mainMod, s, togglespecialworkspace, spotify"
        "$mainMod, c, togglespecialworkspace, chat"
        "$mainMod, z, togglespecialworkspace, notes"
        "$mainMod, O, togglespecialworkspace, obs"
        "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
        "$mainMod, G, togglegroup"
        "$mainMod, Return, exec, kitty"
        "$mainMod, Y, exec, ykmanoath"
        "$mainMod, Q, killactive,"
        "$mainMod, E, exec, thunar"
        "$mainMod, F, togglefloating,"
        "$mainMod, SPACE, exec, fuzzel"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, S, togglesplit, # dwindle"
        "$mainMod, TAB, workspace, previous"
        ",F11,fullscreen"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        "$mainMod ALT, J, changegroupactive, f"
        "$mainMod ALT, K, changegroupactive, b"
        "$mainMod SHIFT, h, movewindoworgroup, l"
        "$mainMod SHIFT, l, movewindoworgroup, r"
        "$mainMod SHIFT, k, movewindoworgroup, u"
        "$mainMod SHIFT, j, movewindoworgroup, d"
        "$mainMod CTRL, h, resizeactive, -60 0"
        "$mainMod CTRL, l, resizeactive,  60 0"
        "$mainMod CTRL, k, resizeactive,  0 -60"
        "$mainMod CTRL, j, resizeactive,  0  60"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, F3, exec, brightnessctl -d *::kbd_backlight set +33%"
        "$mainMod, F2, exec, brightnessctl -d *::kbd_backlight set 33%-"
        ", XF86AudioRaiseVolume, exec, pamixer -i 5 "
        ", XF86AudioLowerVolume, exec, pamixer -d 5 "
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -m"
        "$mainMod ALT, n, exec, brightnessctl set 5%- "
        "$mainMod ALT, equal, exec, brightnessctl set +5% "
        '', Print, exec, grim -g "$(slurp)" - | swappy -f -''
        "$mainMod, B, exec, pkill -SIGUSR1 waybar"
        "$mainMod, W, exec, pkill -SIGUSR2 waybar"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
