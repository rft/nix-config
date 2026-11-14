# Shared systemd sandbox baseline for the self-hosted services in
# modules/services. Each service forces these over upstream's serviceConfig
# and relaxes or extends individual keys where it has to.
{
  ProtectHome = true;
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectKernelLogs = true;
  ProtectControlGroups = true;
  ProtectClock = true;
  NoNewPrivileges = true;
  PrivateTmp = true;
  PrivateDevices = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
  RestrictNamespaces = true;
  LockPersonality = true;
  MemoryDenyWriteExecute = false;
  SystemCallArchitectures = "native";
  SystemCallFilter = [
    "@system-service"
    "~@mount"
    "~@reboot"
    "~@swap"
  ];
}
