const std = @import("std");
const zlm = @import("zlm").init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });
const print = std.debug.print;

const iterations = 10_000_000;

const float_types = .{ f16, f32, f64, f128 };
const int_types = .{ i8, i16, i32, i64, u8, u16, u32, u64 };

const Result = struct {
    name: []const u8,
    ns_per_op: f64,
    ops_per_sec: f64,
    is_separator: bool,
};

var results: [256]Result = undefined;
var result_count: usize = 0;

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

    results[result_count] = .{ .name = name, .ns_per_op = ns_per_op, .ops_per_sec = ops_per_sec, .is_separator = false };
    result_count += 1;
}

fn separator() void {
    results[result_count] = .{ .name = "", .ns_per_op = 0, .ops_per_sec = 0, .is_separator = true };
    result_count += 1;
}

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

    // Vec2
    inline for (float_types) |T| {
        runVecBench("Vec2(" ++ @typeName(T) ++ ")", Vec2Bench(T), true, false, io);
    }
    inline for (int_types) |T| {
        runVecBench("Vec2(" ++ @typeName(T) ++ ")", Vec2Bench(T), false, false, io);
    }

    separator();

    // Vec3
    inline for (float_types) |T| {
        runVecBench("Vec3(" ++ @typeName(T) ++ ")", Vec3Bench(T), true, true, io);
    }
    inline for (int_types) |T| {
        runVecBench("Vec3(" ++ @typeName(T) ++ ")", Vec3Bench(T), false, true, io);
    }

    separator();

    // Vec4
    inline for (float_types) |T| {
        runVecBench("Vec4(" ++ @typeName(T) ++ ")", Vec4Bench(T), true, false, io);
    }
    inline for (int_types) |T| {
        runVecBench("Vec4(" ++ @typeName(T) ++ ")", Vec4Bench(T), false, false, io);
    }

    separator();

    // Mat2
    inline for (float_types) |T| {
        const B = MatBench(T, 2);
        const name = "Mat2(" ++ @typeName(T) ++ ")";
        bench(io, name ++ ".mul", B.mul);
        bench(io, name ++ ".determinant", B.determinant);
        bench(io, name ++ ".inverse", B.inverse);
    }

    separator();

    // Mat3
    inline for (float_types) |T| {
        const B = MatBench(T, 3);
        const name = "Mat3(" ++ @typeName(T) ++ ")";
        bench(io, name ++ ".mul", B.mul);
        bench(io, name ++ ".determinant", B.determinant);
        bench(io, name ++ ".inverse", B.inverse);
    }

    separator();

    // Mat4
    bench(io, "Mat4(f64).mul", benchMat4Mul);
    bench(io, "Mat4(f64).perspective", benchMat4Perspective);
    bench(io, "Mat4(f64).lookAt", benchMat4LookAt);

    // Print all results
    print("\n", .{});
    print("  zlm benchmark — {d} iterations per test\n", .{iterations});
    for (results[0..result_count]) |r| {
        if (r.is_separator) {
            print("  ──────────────────────────────────────────────────\n", .{});
        } else {
            print("  {s:>28}: {d:8.2} ns/op  ({d:12.0} ops/s)\n", .{ r.name, r.ns_per_op, r.ops_per_sec });
        }
    }
    print("\n", .{});
}

// ── Mat2/Mat3 benchmarks ──

fn MatBench(comptime T: type, comptime N: usize) type {
    const M = switch (N) {
        2 => zlm.Mat2(T),
        3 => zlm.Mat3(T),
        4 => zlm.Mat4(T),
        else => unreachable,
    };
    return struct {
        var a = M.identity();
        var b = blk: {
            var m = M.identity();
            m.m[M.idx(0, 1)] = 2;
            m.m[M.idx(1, 0)] = 3;
            break :blk m;
        };
        fn mul() void { std.mem.doNotOptimizeAway(M.mul(a, b)); }
        fn determinant() void { std.mem.doNotOptimizeAway(M.determinant(a)); }
        fn inverse() void { std.mem.doNotOptimizeAway(M.inverse(a)); }
    };
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
