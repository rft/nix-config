{
  delib,
  inputs,
  lib,
  pkgs,
  ...
}:
delib.host {
  name = "mistletoe";
  type = "wsl";
  system = "x86_64-linux";

  home.home.stateVersion = "24.05";

  nixos = { myconfig, ... }: {
    system.stateVersion = "25.05";
    imports = [ inputs.nixos-wsl.nixosModules.wsl ];

    wsl.enable = true;
    wsl.defaultUser = myconfig.constants.username;

    programs.nix-ld.enable = true;

    # WSL manages resolv.conf itself, so systemd-resolved does nothing here
    services.resolved.enable = lib.mkForce false;

    # Fix MTU for WSL2 when Windows Netbird client sets adapter to 1280
    systemd.services.fix-wsl-mtu = {
      description = "Set eth0 MTU to 1500 for WSL2 Netbird compatibility";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.iproute2}/bin/ip link set eth0 mtu 1500";
        RemainAfterExit = true;
      };
    };
  };

  myconfig = {
    programs.programming.enable = true;
    programs.programming.analysis.enable = true;
    programs.programming.cloud.enable = true;
  };
}
