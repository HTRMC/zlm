const std = @import("std");
const zlm = @import("zlm").init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });
const print = std.debug.print;

const iterations = 10_000_000;

pub fn main(init: std.process.Init) void {
    const io = init.io;

    print("\n", .{});
    print("  zlm benchmark — {d} iterations per test\n", .{iterations});
    print("  ──────────────────────────────────────────\n", .{});

    // Vec2
    bench(io, "Vec2.add", benchVec2Add);
    bench(io, "Vec2.sub", benchVec2Sub);
    bench(io, "Vec2.scale", benchVec2Scale);
    bench(io, "Vec2.dot", benchVec2Dot);
    bench(io, "Vec2.length", benchVec2Length);
    bench(io, "Vec2.normalize", benchVec2Normalize);

    // Vec3
    bench(io, "Vec3.add", benchVec3Add);
    bench(io, "Vec3.sub", benchVec3Sub);
    bench(io, "Vec3.scale", benchVec3Scale);
    bench(io, "Vec3.dot", benchVec3Dot);
    bench(io, "Vec3.length", benchVec3Length);
    bench(io, "Vec3.normalize", benchVec3Normalize);
    bench(io, "Vec3.cross", benchVec3Cross);

    // Vec4
    bench(io, "Vec4.add", benchVec4Add);
    bench(io, "Vec4.sub", benchVec4Sub);
    bench(io, "Vec4.scale", benchVec4Scale);
    bench(io, "Vec4.dot", benchVec4Dot);
    bench(io, "Vec4.length", benchVec4Length);
    bench(io, "Vec4.normalize", benchVec4Normalize);

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

// ── Vec2 benchmarks ──

var v2a = zlm.Vec2(f32).init(1.0, 2.0);
var v2b = zlm.Vec2(f32).init(3.0, 4.0);

fn benchVec2Add() void {
    std.mem.doNotOptimizeAway(zlm.Vec2(f32).add(v2a, v2b));
}

fn benchVec2Sub() void {
    std.mem.doNotOptimizeAway(zlm.Vec2(f32).sub(v2a, v2b));
}

fn benchVec2Scale() void {
    std.mem.doNotOptimizeAway(zlm.Vec2(f32).scale(v2a, 2.5));
}

fn benchVec2Dot() void {
    std.mem.doNotOptimizeAway(zlm.Vec2(f32).dot(v2a, v2b));
}

fn benchVec2Length() void {
    std.mem.doNotOptimizeAway(zlm.Vec2(f32).length(v2a));
}

fn benchVec2Normalize() void {
    std.mem.doNotOptimizeAway(zlm.Vec2(f32).normalize(v2a));
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

// ── Vec4 benchmarks ──

var v4a = zlm.Vec4(f32).init(1.0, 2.0, 3.0, 4.0);
var v4b = zlm.Vec4(f32).init(5.0, 6.0, 7.0, 8.0);

fn benchVec4Add() void {
    std.mem.doNotOptimizeAway(zlm.Vec4(f32).add(v4a, v4b));
}

fn benchVec4Sub() void {
    std.mem.doNotOptimizeAway(zlm.Vec4(f32).sub(v4a, v4b));
}

fn benchVec4Scale() void {
    std.mem.doNotOptimizeAway(zlm.Vec4(f32).scale(v4a, 2.5));
}

fn benchVec4Dot() void {
    std.mem.doNotOptimizeAway(zlm.Vec4(f32).dot(v4a, v4b));
}

fn benchVec4Length() void {
    std.mem.doNotOptimizeAway(zlm.Vec4(f32).length(v4a));
}

fn benchVec4Normalize() void {
    std.mem.doNotOptimizeAway(zlm.Vec4(f32).normalize(v4a));
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
