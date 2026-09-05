# NOTE: AI-GENERATED
# Declarative disk layout for schizopad (adopted from the existing on-disk
# layout; NixOS partitions only — the Windows partitions are NOT described
# here and are never touched by this config).
#
# Applied layouts:
#   nvme0n1p1 1G   vfat  ESP          /boot        (systemd-boot)
#   nvme0n1p2 rest btrfs subvols @, @home, @nix, @log, @cache
#   nvme0n1p3 16M  MSR  (Windows, not managed)
#   nvme0n1p4 149G NTFS (Windows C:, not managed)
#   nvme0n1p5 780M NTFS (Windows recovery, not managed)
#
# NOTE: rebuilding NEVER touches the disk. The disko module only generates
# fileSystems/swap options. Only the `disko` CLI in format mode repartitions,
# which would wipe this drive — never run it here.
{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.0025384941b112c8";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              # The live disk has no GPT partlabels, so by-partlabel devices
              # won't exist. Pin to the existing filesystem UUIDs (matches the
              # previous hardware-configuration.nix mounts). If you ever do a
              # fresh install from this config, remove BOTH `device` overrides
              # so disko uses its by-partlabel device generation.
              device = "/dev/disk/by-uuid/5812-6453";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            linux = {
              size = "100%";
              device = "/dev/disk/by-uuid/0150253e-0995-415a-8cd6-388e388c0cf3";
              content = {
                type = "btrfs";
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    # x-initrd.mount: initrd must mount root before switch-root.
                    mountOptions = [
                      "defaults"
                      "x-initrd.mount"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    # The system lives under /nix/store — mount in initrd or
                    # the boot fails after switch-root.
                    mountOptions = [
                      "defaults"
                      "x-initrd.mount"
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "defaults"
                      "x-initrd.mount"
                    ];
                  };
                  "@cache" = {
                    mountpoint = "/var/cache";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
