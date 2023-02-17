const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const s4 = b.addStaticLibrary(.{
        .name = "s4",
        .target = target,
        .optimize = optimize,
    });
    s4.defineCMacro("CONFIG_VERSION", "\"2021-03-27\"");
    s4.linkLibC();
    s4.addCSourceFiles(&.{
        "cutils.c",
        "libregexp.c",
        "libunicode.c",
        "quickjs.c",
    }, &.{
        "-Wall",
        "-W",
        "-Wstrict-prototypes",
        "-Wwrite-strings",
        "-Wno-missing-field-initializers",
    });
    s4.install();
    s4.installHeader("quickjs.h", "s4/quickjs.h");
    s4.installHeader("cutils.h", "s4/cutils.h");
}
