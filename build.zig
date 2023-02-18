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
    }, &.{});
    s4.install();
    s4.installHeader("quickjs.h", "s4/quickjs.h");
    s4.installHeader("cutils.h", "s4/cutils.h");

    // to ensure linking works
    const tester = b.addExecutable(.{
        .name = "tester",
        .target = target,
        .optimize = optimize,
        .root_source_file = .{ .path = "helper.zig" },
    });
    tester.addCSourceFiles(&.{
        "tester.c",
    }, &.{});
    tester.addIncludePath("./s4");
    tester.linkLibC();
    tester.linkLibrary(s4);
    tester.install();
}
