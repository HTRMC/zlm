const std = @import("std");
const zlm = @import("zlm").init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });
const print = std.debug.print;

const iterations = 10_000_000;

const float_types = .{ f16, f32, f64, f128 };
const int_types = .{ i8, i16, i32, i64, u8, u16, u32, u64 };

fn Vec2Bench(comptime T: type) type {
    const V = zlm.Vec2(T);
    return struct {
        var a = V.init(1, 2);
        var b = V.init(3, 4);
        fn add() void { std.mem.doNotOptimizeAway(V.add(a, b)); }
        fn sub() void { std.mem.doNotOptimizeAway(V.sub(a, b)); }
        fn scale() void { std.mem.doNotOptimizeAway(V.scale(a, 2)); }
        fn dot() void { std.mem.doNotOptimizeAway(V.dot(a, b)); }
        fn length() void { std.mem.doNotOptimizeAway(V.length(a)); }
        fn normalize() void { std.mem.doNotOptimizeAway(V.normalize(a)); }
    };
}

fn Vec3Bench(comptime T: type) type {
    const V = zlm.Vec3(T);
    return struct {
        var a = V.init(1, 2, 3);
        var b = V.init(4, 5, 6);
        fn add() void { std.mem.doNotOptimizeAway(V.add(a, b)); }
        fn sub() void { std.mem.doNotOptimizeAway(V.sub(a, b)); }
        fn scale() void { std.mem.doNotOptimizeAway(V.scale(a, 2)); }
        fn dot() void { std.mem.doNotOptimizeAway(V.dot(a, b)); }
        fn length() void { std.mem.doNotOptimizeAway(V.length(a)); }
        fn normalize() void { std.mem.doNotOptimizeAway(V.normalize(a)); }
        fn cross() void { std.mem.doNotOptimizeAway(V.cross(a, b)); }
    };
}

fn Vec4Bench(comptime T: type) type {
    const V = zlm.Vec4(T);
    return struct {
        var a = V.init(1, 2, 3, 4);
        var b = V.init(5, 6, 7, 8);
        fn add() void { std.mem.doNotOptimizeAway(V.add(a, b)); }
        fn sub() void { std.mem.doNotOptimizeAway(V.sub(a, b)); }
        fn scale() void { std.mem.doNotOptimizeAway(V.scale(a, 2)); }
        fn dot() void { std.mem.doNotOptimizeAway(V.dot(a, b)); }
        fn length() void { std.mem.doNotOptimizeAway(V.length(a)); }
        fn normalize() void { std.mem.doNotOptimizeAway(V.normalize(a)); }
    };
}

fn runVecBench(comptime name: []const u8, comptime B: type, comptime is_float: bool, comptime has_cross: bool, io: std.Io) void {
    bench(io, name ++ ".add", B.add);
    bench(io, name ++ ".sub", B.sub);
    bench(io, name ++ ".scale", B.scale);
    bench(io, name ++ ".dot", B.dot);
    if (is_float) {
        bench(io, name ++ ".length", B.length);
        bench(io, name ++ ".normalize", B.normalize);
    }
    if (has_cross) {
        bench(io, name ++ ".cross", B.cross);
    }
}

pub fn main(init: std.process.Init) void {
    const io = init.io;

    print("\n", .{});
    print("  zlm benchmark — {d} iterations per test\n", .{iterations});
    print("  ──────────────────────────────────────────────────\n", .{});

    // Vec2
    inline for (float_types) |T| {
        runVecBench("Vec2(" ++ @typeName(T) ++ ")", Vec2Bench(T), true, false, io);
    }
    inline for (int_types) |T| {
        runVecBench("Vec2(" ++ @typeName(T) ++ ")", Vec2Bench(T), false, false, io);
    }

    // Vec3
    inline for (float_types) |T| {
        runVecBench("Vec3(" ++ @typeName(T) ++ ")", Vec3Bench(T), true, true, io);
    }
    inline for (int_types) |T| {
        runVecBench("Vec3(" ++ @typeName(T) ++ ")", Vec3Bench(T), false, true, io);
    }

    // Vec4
    inline for (float_types) |T| {
        runVecBench("Vec4(" ++ @typeName(T) ++ ")", Vec4Bench(T), true, false, io);
    }
    inline for (int_types) |T| {
        runVecBench("Vec4(" ++ @typeName(T) ++ ")", Vec4Bench(T), false, false, io);
    }

    // Mat4
    print("  ──────────────────────────────────────────────────\n", .{});
    bench(io, "Mat4(f64).mul", benchMat4Mul);
    bench(io, "Mat4(f64).perspective", benchMat4Perspective);
    bench(io, "Mat4(f64).lookAt", benchMat4LookAt);

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

    print("  {s:>28}: {d:8.2} ns/op  ({d:12.0} ops/s)\n", .{ name, ns_per_op, ops_per_sec });
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
