{
  delib,
  lib,
  pkgs,
  ...
}:
let
  # SFTP chroot root for the document scanner. sshd refuses to chroot into a
  # path it doesn't own, so this stays root-owned and the paperless consume
  # dir is nested inside it.
  scanDir = "/var/lib/scan";

  # One subdir per scanner profile — PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS turns
  # each directory name into a paperless tag on ingest.
  scanTags = [
    "receipts"
    "tax"
    "manuals"
  ];
in
delib.module {
  name = "services.scanner";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.scanner.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  # The scanner feeds paperless and falls back to SMB, so it brings both.
  myconfig.ifEnabled.services = {
    paperless.enable = true;
    samba.enable = true;
  };

  nixos.ifEnabled = {
    # The consume dir lives under /var/lib/scan (not the default
    # /var/lib/paperless/consume) so sshd can chroot the scanner user into a
    # root-owned parent. Upstream derives ReadWritePaths from consumptionDir,
    # so the relocation needs no hardening change.
    services.paperless = {
      consumptionDir = "${scanDir}/consume";
      consumptionDirIsPublic = true; # mode 0777 so the scanner can drop files
      settings = {
        PAPERLESS_CONSUMER_RECURSIVE = true;
        PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
      };
    };

    # Brother ADS-1700W ingest: the scanner pushes finished PDFs over SFTP
    # (primary) or SMB (fallback) into a per-tag subdir of the consume dir.
    users.groups.scanner = { };
    users.users.scanner = {
      isSystemUser = true;
      group = "scanner";
      home = scanDir;
      createHome = false;
      # Safe with SFTP: sshd implements internal-sftp in-process and never
      # execs the login shell.
      shell = "${pkgs.shadow}/bin/nologin";
      # Generated on the scanner under Network > Security > Client Key Pair and
      # exported from Web Based Management. A public key, so it belongs in Nix
      # for the same reason myconfig.constants.sshKeys does.
      # RSA 2048, SHA256:QWsjjN2g4Y+sv1iZtrTUnS640Vn4nwp1UFbcBZ0gSg0
      # The comment is the scanner's own hostname (BR + its MAC).
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfTXHWsyvbt5qyT+1TecbgJrKBDHLP017k2ebfepreRD4SFicEbXaN4MS1WUhGNNNFYefvApDbhCskwJ3obe4PLPVFubfKsgWr8DpvaPuJQJc+vS8WH/lxReO7RvRDv0OhfY4oq0NgyAv4YNcUZGmSnuRfb3wTJe+HzNqFjwmuFSd8mZeNVifDuSGX8Mk8XaZ41M4iCYpNPidbWntK8AsF7Fck/FA9ebrWFckwkTGw8qqmOAgYXj0o+2VnfZsD+wb6OcUkHqWgEnPs7uoy+ufMoXNJpnEdQzf2QqLsLc9A4UgFdOiMn3Mu/RUbcLrqBc38pcVxD9cX91kOOBjqFyUP root@BR5CF370C3AC5A"
      ];
    };

    # The ADS-1700W only accepts an RSA server host key (it rejects the ed25519
    # one outright) and only offers the legacy SHA-1 `ssh-rsa` host key
    # algorithm, which OpenSSH has not offered by default since 8.8. Without
    # this the scanner fails with "no matching host key type found".
    #
    # This is host-wide, not scoped: HostKeyAlgorithms is not a valid Match
    # keyword. `+ssh-rsa` appends to the defaults, so modern clients still
    # negotiate ed25519/rsa-sha2 and only ever fall back to SHA-1 if they ask
    # for it. It weakens host *authentication* only — user pubkey auth is
    # governed separately by PubkeyAcceptedAlgorithms and is untouched.
    # Drop this line if the SMB transport ever replaces SFTP here.
    services.openssh.settings.HostKeyAlgorithms = "+ssh-rsa";

    # Same story for MACs: the scanner offers only non-ETM algorithms
    # (hmac-sha2-256/512 plus sha1/md5/ripemd160 variants), while the default
    # list here is ETM-only — an empty intersection, so the connection dies at
    # "no matching MAC found" before authentication is even attempted.
    # Appending just the two SHA-2 non-ETM variants keeps the SHA-1 and MD5
    # ones the firmware also offers off the table. Encrypt-and-MAC rather than
    # encrypt-then-MAC is a real but modest downgrade, and only for clients
    # that can't do better — the ETM entries stay first in the list.
    # Macs is not a valid Match keyword either, hence global.
    services.openssh.settings.Macs = [
      "hmac-sha2-512-etm@openssh.com"
      "hmac-sha2-256-etm@openssh.com"
      "umac-128-etm@openssh.com"
      "hmac-sha2-512"
      "hmac-sha2-256"
    ];

    # internal-sftp is required, not stylistic: the global `Subsystem sftp`
    # points at a /nix/store binary that doesn't exist inside the chroot.
    # -u 0022 makes uploads 0644 so paperless-consumer can read them.
    # mkAfter keeps the Match block last — every directive after a Match
    # belongs to it. Ciphers/MACs/KexAlgorithms cannot go in a Match block; if
    # the scanner can't negotiate, widen them globally (see docs/SERVICES.md).
    #
    # PubkeyAcceptedAlgorithms *is* a valid Match keyword, so the firmware's
    # SHA-1 ssh-rsa user-auth signatures are accepted for this account alone —
    # every other user on the host keeps the SHA-2-only default. Without it:
    # "signature algorithm ssh-rsa not in PubkeyAcceptedAlgorithms".
    services.openssh.extraConfig = lib.mkAfter ''
      Match User scanner
        ChrootDirectory ${scanDir}
        ForceCommand internal-sftp -u 0022 -d /consume
        AllowTcpForwarding no
        X11Forwarding no
        PermitTunnel no
        PermitTTY no
        PubkeyAcceptedAlgorithms +ssh-rsa
    '';

    # SMB fallback (Samba itself is set up in services.samba). The scanner
    # password is set out-of-band with `smbpasswd -a scanner`, like
    # /var/lib/mosquitto/hass-password.
    services.samba.settings.scan = {
      "path" = "${scanDir}/consume";
      "browseable" = "yes";
      "read only" = "no";
      "valid users" = "scanner";
      "force user" = "paperless"; # uploads land owned by paperless
      "create mask" = "0644";
      "directory mask" = "0755";
    };

    systemd.tmpfiles.rules = [
      # Chroot root: must be root-owned and not group/world-writable.
      # The consume dir inside it is created by the paperless module.
      "d ${scanDir} 0755 root root -"
    ]
    ++ map (tag: "d ${scanDir}/consume/${tag} 0777 - - -") scanTags;
  };
}
