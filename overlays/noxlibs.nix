{ }:
(self: super: {
  wayland = super.wayland.override { withDocumentation = false; };

  systemd = super.systemd.override { withTpm2Tss = false; };
})
