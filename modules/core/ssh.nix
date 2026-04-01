{
  delib,
  ...
}:
delib.module {
  name = "core.ssh";

  options = delib.singleEnableOption true;

  nixos.ifEnabled = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];
  };

  # On macOS, enable Remote Login in System Settings > General > Sharing
  # Authorized keys are managed via home-manager below
  home.ifEnabled = { myconfig, ... }: {
    home.file.".ssh/authorized_keys" = {
      text = builtins.concatStringsSep "\n" (builtins.attrValues myconfig.constants.sshKeys) + "\n";
    };
  };
}
