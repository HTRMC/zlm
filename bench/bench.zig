const std = @import("std");
const zlm = @import("zlm").init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });
const print = std.debug.print;

const iterations = 10_000_000;

pub fn main(init: std.process.Init) void {
    const io = init.io;

    print("\n", .{});
    print("  zlm benchmark — {d} iterations per test\n", .{iterations});
    print("  ──────────────────────────────────────────\n", .{});

    // Vec3
    bench(io, "Vec3.add", benchVec3Add);
    bench(io, "Vec3.sub", benchVec3Sub);
    bench(io, "Vec3.scale", benchVec3Scale);
    bench(io, "Vec3.dot", benchVec3Dot);
    bench(io, "Vec3.length", benchVec3Length);
    bench(io, "Vec3.normalize", benchVec3Normalize);
    bench(io, "Vec3.cross", benchVec3Cross);

    // Mat4
    bench(io, "Mat4.mul", benchMat4Mul);
    bench(io, "Mat4.perspective", benchMat4Perspective);
    bench(io, "Mat4.lookAt", benchMat4LookAt);

    print("\n", .{});
}

fn bench(io: std.Io, name: []const u8, comptime func: fn () void) void {
    const start = std.Io.Clock.Timestamp.now(io, .awake);

    for (0..iterations) |_| {
        @call(.never_inline, func, .{});
    }

    const elapsed = start.durationTo(std.Io.Clock.Timestamp.now(io, .awake));
    const elapsed_ns: i96 = elapsed.raw.nanoseconds;
    const ns_f: f64 = @floatFromInt(elapsed_ns);
    const ns_per_op = ns_f / @as(f64, @floatFromInt(iterations));
    const ops_per_sec = @as(f64, @floatFromInt(iterations)) / (ns_f / 1_000_000_000.0);

    print("  {s:>20}: {d:8.2} ns/op  ({d:12.0} ops/s)\n", .{ name, ns_per_op, ops_per_sec });
}

// ── Vec3 benchmarks ──

var va = zlm.Vec3(f32).init(1.0, 2.0, 3.0);
var vb = zlm.Vec3(f32).init(4.0, 5.0, 6.0);

fn benchVec3Add() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).add(va, vb));
}

fn benchVec3Sub() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).sub(va, vb));
}

fn benchVec3Scale() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).scale(va, 2.5));
}

fn benchVec3Dot() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).dot(va, vb));
}

fn benchVec3Length() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).length(va));
}

fn benchVec3Normalize() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).normalize(va));
}

fn benchVec3Cross() void {
    std.mem.doNotOptimizeAway(zlm.Vec3(f32).cross(va, vb));
}

// ── Mat4 benchmarks ──

var ma = zlm.Mat4(f64).mul(zlm.Mat4(f64).identity(), zlm.Mat4(f64).perspective(
    std.math.pi / 4.0,
    16.0 / 9.0,
    0.1,
    100.0,
));
var mb = zlm.Mat4(f64).lookAt(
    zlm.Vec3(f64).init(0.0, 0.0, 5.0),
    zlm.Vec3(f64).init(0.0, 0.0, 0.0),
    zlm.Vec3(f64).init(0.0, 1.0, 0.0),
);

fn benchMat4Mul() void {
    std.mem.doNotOptimizeAway(zlm.Mat4(f64).mul(ma, mb));
}

fn benchMat4Perspective() void {
    std.mem.doNotOptimizeAway(zlm.Mat4(f64).perspective(
        std.math.pi / 4.0,
        16.0 / 9.0,
        0.1,
        100.0,
    ));
}

fn benchMat4LookAt() void {
    std.mem.doNotOptimizeAway(zlm.Mat4(f64).lookAt(
        zlm.Vec3(f64).init(0.0, 0.0, 5.0),
        zlm.Vec3(f64).init(0.0, 0.0, 0.0),
        zlm.Vec3(f64).init(0.0, 1.0, 0.0),
    ));
}
