{ delib, lib, ... }:
delib.module {
  name = "services.backup";

  options = delib.singleEnableOption false;

  myconfig.always =
    { myconfig, ... }:
    {
      services.backup.enable = lib.mkDefault (myconfig.services.enable or false);
    };

  nixos.ifEnabled =
    { myconfig, ... }:
    {
      # Borgmatic backups of service state. Upstream ships the daily timer and
      # a sandboxed unit (ProtectSystem=full, so /var stays writable for the
      # repo below).
      #
      # What gets backed up is declared next to each service: every module in
      # this directory adds its own source_directories, sqlite_databases and
      # exclude_patterns to services.borgmatic.settings, and hosts add their
      # own paths the same way (bristlecone adds /srv/share).
      #
      # Conventions for those entries:
      # - DynamicUser services are listed by their real /var/lib/private path:
      #   borg archives the /var/lib/<name> symlink itself, not its target.
      # - Live SQLite files can be torn mid-write, so each is dumped by the
      #   sqlite_databases hook and the raw file (plus -wal/-shm) excluded.
      #   The hook runs sqlite3 as root and a missing path gets created empty,
      #   so keep these in sync with where the services actually put their DBs.
      #
      # The repo is local for now — same disk as the sources, so this guards
      # against deletion/corruption, not drive failure. Add an off-machine entry
      # to `repositories` to fix that; borgmatic backs up to each in turn.
      #
      # One-time bootstrap (see docs/SERVICES.md):
      #   install -m 0400 /dev/stdin /var/lib/borgmatic/passphrase
      #   borgmatic repo-create --encryption repokey-blake2
      services.borgmatic = {
        enable = true;
        settings = {
          repositories = [
            {
              path = "/var/lib/borg/${myconfig.host.name}";
              label = "local";
            }
          ];

          # A plain file rather than the unit's LoadCredentialEncrypted, so
          # manual `sudo borgmatic list/extract` works outside systemd too.
          encryption_passcommand = "cat /var/lib/borgmatic/passphrase";

          exclude_caches = true;

          keep_daily = 7;
          keep_weekly = 4;
          keep_monthly = 6;

          checks = [
            {
              name = "repository";
              frequency = "2 weeks";
            }
            {
              name = "archives";
              frequency = "1 month";
            }
          ];
        };
      };
      # Upstream bounds root to CAP_DAC_READ_SEARCH (read-only), but even a
      # .dump of a live WAL-mode DB must write the service-owned -shm file, so
      # sqlite3 fails with "attempt to write a readonly database" (seen on
      # jellyfin.db). Bounding-set assignments are additive, so this extends
      # upstream's list rather than replacing it.
      systemd.services.borgmatic.serviceConfig.CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];

      # Parent of the local borg repo; borg creates the repo dir itself.
      systemd.tmpfiles.rules = [ "d /var/lib/borg 0700 root root -" ];
    };
}
