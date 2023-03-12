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
        "libbf.c",
        "libregexp.c",
        "libunicode.c",
        "quickjs.c",
    }, &.{
        "-DSHORT_OPCODES=0",
        "-DCONFIG_BIGNUM=1",
    });
    s4.install();
    s4.installHeader("quickjs.h", "s4/quickjs.h");
    s4.installHeader("cutils.h", "s4/cutils.h");

    // run tests
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

    const s4_fast = b.addStaticLibrary(.{
        .name = "s4",
        .target = target,
        .optimize = .ReleaseFast,
    });
    s4_fast.defineCMacro("CONFIG_VERSION", "\"2021-03-27\"");
    s4_fast.linkLibC();
    s4_fast.addCSourceFiles(&.{
        "cutils.c",
        "libbf.c",
        "libregexp.c",
        "libunicode.c",
        "quickjs.c",
    }, &.{
        "-DSHORT_OPCODES=0",
        "-DCONFIG_BIGNUM=1",
    });
    s4_fast.install();
    s4_fast.installHeader("quickjs.h", "s4-fast/quickjs.h");
    s4_fast.installHeader("cutils.h", "s4-fast/cutils.h");

    const test262_runner = b.addExecutable(.{
        .name = "test262-runner",
        .target = target,
        .optimize = .ReleaseFast,
        .root_source_file = .{ .path = "helper.zig" },
    });
    test262_runner.addCSourceFiles(&.{
        "test262-runner.c",
    }, &.{});
    test262_runner.defineCMacro("CONFIG_VERSION", "\"2021-03-27\"");
    test262_runner.addIncludePath("./s4-fast");
    test262_runner.linkLibrary(s4_fast);
    test262_runner.install();
}
