const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("zlm", .{
        .root_source_file = b.path("src/zlm.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Benchmark executable
    const bench_mod = b.createModule(.{
        .root_source_file = b.path("bench/bench.zig"),
        .target = target,
        .optimize = .ReleaseFast,
        .imports = &.{
            .{ .name = "zlm", .module = b.createModule(.{
                .root_source_file = b.path("src/zlm.zig"),
                .target = target,
                .optimize = .ReleaseFast,
            }) },
        },
    });

    const bench_exe = b.addExecutable(.{
        .name = "bench",
        .root_module = bench_mod,
    });

    const run_bench = b.addRunArtifact(bench_exe);
    const bench_step = b.step("bench", "Run benchmarks");
    bench_step.dependOn(&run_bench.step);
}
