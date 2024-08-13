{ inputs }:
(self: super: {
  firefox = super.firefox-unwrapped.overrideAttrs (old: {
    src = inputs.firefox;
    version = "131.0-nightly";
  });
  servo = super.callPackage (
    {
      lib,
      stdenv,
      fontconfig,
      freetype,
      openssl,
      libunwind,
      xorg,
      gst_all_1,
      rustup,
      cmakeMinimal,
      dbus,
      gitMinimal,
      pkgconf,
      which,
      autoconf,
      perl,
      yasm,
      m4,
      python3,
      darwin,
    }:

    stdenv.mkDerivation {
      pname = "servo";
      version = "0-unstable-2024-08-10";

      src = inputs.servo;

      buildInputs = [
        # Native dependencies
        fontconfig
        freetype
        openssl
        libunwind
        xorg.libxcb

        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-bad

        rustup

        # Build utilities
        cmakeMinimal
        dbus
        gitMinimal
        pkgconf
        which
        autoconf
        perl
        yasm
        m4
        (python3.withPackages (
          ps: with ps; [
            virtualenv
            pip
            dbus
          ]
        ))

      ] ++ (lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.AppKit ]);

      enableParallelBuilding = true;

      configurePhase = ''
        runHook preConfigure
        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild
        ./mach build --release
        runHook postBuild
      '';

      doCheck = true;
      checkPhase = ''
        runHook preCheck
        ./mach run --release tests/html/about-mozilla.html
        runHook postCheck
      '';

      meta = {
        homepage = "https://servo.org";
        description = "Servo is a prototype web browser engine written in the Rust language.";
        license = lib.licenses.mpl20;
        maintainers = [ ];
        platforms = lib.platforms.all;
      };
    }
  ) { };
})
