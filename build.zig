const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});


    const lib = b.addSharedLibrary(.{
        .name = "lib",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize =  optimize,
    });

    lib.linker_allow_shlib_undefined = true;
    
    lib.addObjectFile(b.path("deps/node.lib")); // linking the executable against a "file.a" static library.

    b.installArtifact(lib);

    const copy_node_step = b.addInstallLibFile(lib.getEmittedBin(), "example.node");
    b.getInstallStep().dependOn(&copy_node_step.step);

}
