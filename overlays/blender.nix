{ inputs }:

(self: super: {
  blender = super.blender.overrideAttrs (old: {
    version = "4.3.0";
    srcs = [
      inputs.blender
      (super.fetchgit {
        name = "assets";
        url = "https://projects.blender.org/blender/blender-assets.git";
        rev = "6864f1832e71a31e1e04f72bb7a5a1f53f0cd01c";
        fetchLFS = true;
        hash = "sha256-vepK0inPMuleAJBSipwoI99nMBBiFaK/eSMHDetEtjY=";
      })
    ];
    cmakeFlags = old.cmakeFlags ++ [
      "-DWITH_VULKAN_BACKEND=ON"
      "-DWITH_VULKAN_MOLTENVK=ON"
      "-DWITH_EXPERIMENTAL_FEATURES=ON"
      "-DCMAKE_CXX_FLAGS='-DVK_ENABLE_BETA_EXTENSIONS=1'"
    ];

    buildInputs = old.buildInputs ++ [
      (super.vulkan-headers.overrideAttrs (old: {
        src = inputs.vulkan-headers;
      }))
      super.vulkan-loader
      super.shaderc
    ];
  });
})
