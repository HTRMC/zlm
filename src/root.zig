const std = @import("std");

pub const GraphicsApi = enum { vulkan, opengl };
pub const ShaderLang = enum { glsl, hlsl };
pub const Config = struct {
    graphics_api: GraphicsApi,
    shader_lang: ShaderLang,
};

pub fn init(comptime config: Config) type {
    return struct {
        pub fn Vec2(comptime T: type) type {
            return GenVec2(T);
        }
        pub fn Vec3(comptime T: type) type {
            return GenVec3(T);
        }
        pub fn Vec4(comptime T: type) type {
            return GenVec4(T);
        }
        pub fn Mat2(comptime T: type) type {
            return GenMat(T, 2, 2, config);
        }
        pub fn Mat3(comptime T: type) type {
            return GenMat(T, 3, 3, config);
        }
        pub fn Mat4(comptime T: type) type {
            return GenMat(T, 4, 4, config);
        }
        pub fn Mat2x3(comptime T: type) type {
            return GenMat(T, 2, 3, config);
        }
        pub fn Mat2x4(comptime T: type) type {
            return GenMat(T, 2, 4, config);
        }
        pub fn Mat3x2(comptime T: type) type {
            return GenMat(T, 3, 2, config);
        }
        pub fn Mat3x4(comptime T: type) type {
            return GenMat(T, 3, 4, config);
        }
        pub fn Mat4x2(comptime T: type) type {
            return GenMat(T, 4, 2, config);
        }
        pub fn Mat4x3(comptime T: type) type {
            return GenMat(T, 4, 3, config);
        }
        pub fn Rotor3(comptime T: type) type {
            return GenRotor3(T, config);
        }
    };
}

fn GenVec2(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub fn init(x: T, y: T) Self {
            return Self{ .x = x, .y = y };
        }

        pub fn add(a: Self, b: Self) Self {
            return Self{
                .x = a.x + b.x,
                .y = a.y + b.y,
            };
        }

        pub fn sub(a: Self, b: Self) Self {
            return Self{
                .x = a.x - b.x,
                .y = a.y - b.y,
            };
        }

        pub fn scale(v: Self, s: T) Self {
            return Self{
                .x = v.x * s,
                .y = v.y * s,
            };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y;
        }

        pub fn length(v: Self) T {
            return @sqrt(dot(v, v));
        }

        pub fn normalize(v: Self) Self {
            const len = length(v);
            if (len < std.math.floatEps(T)) return v;
            return scale(v, 1.0 / len);
        }
    };
}

fn GenVec3(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,

        pub fn init(x: T, y: T, z: T) Self {
            return Self{ .x = x, .y = y, .z = z };
        }

        pub fn add(a: Self, b: Self) Self {
            return Self{
                .x = a.x + b.x,
                .y = a.y + b.y,
                .z = a.z + b.z,
            };
        }

        pub fn sub(a: Self, b: Self) Self {
            return Self{
                .x = a.x - b.x,
                .y = a.y - b.y,
                .z = a.z - b.z,
            };
        }

        pub fn scale(v: Self, s: T) Self {
            return Self{
                .x = v.x * s,
                .y = v.y * s,
                .z = v.z * s,
            };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub fn length(v: Self) T {
            return @sqrt(dot(v, v));
        }

        pub fn normalize(v: Self) Self {
            const len = length(v);
            if (len < std.math.floatEps(T)) return v;
            return scale(v, 1.0 / len);
        }

        pub fn cross(a: Self, b: Self) Self {
            return Self{
                .x = a.y * b.z - a.z * b.y,
                .y = a.z * b.x - a.x * b.z,
                .z = a.x * b.y - a.y * b.x,
            };
        }
    };
}

fn GenVec4(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,
        w: T,

        pub fn init(x: T, y: T, z: T, w: T) Self {
            return Self{ .x = x, .y = y, .z = z, .w = w };
        }

        pub fn add(a: Self, b: Self) Self {
            return Self{
                .x = a.x + b.x,
                .y = a.y + b.y,
                .z = a.z + b.z,
                .w = a.w + b.w,
            };
        }

        pub fn sub(a: Self, b: Self) Self {
            return Self{
                .x = a.x - b.x,
                .y = a.y - b.y,
                .z = a.z - b.z,
                .w = a.w - b.w,
            };
        }

        pub fn scale(v: Self, s: T) Self {
            return Self{
                .x = v.x * s,
                .y = v.y * s,
                .z = v.z * s,
                .w = v.w * s,
            };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
        }

        pub fn length(v: Self) T {
            return @sqrt(dot(v, v));
        }

        pub fn normalize(v: Self) Self {
            const len = length(v);
            if (len < std.math.floatEps(T)) return v;
            return scale(v, 1.0 / len);
        }
    };
}

fn GenMat(comptime T: type, comptime C: usize, comptime R: usize, comptime config: Config) type {
    return struct {
        const Self = @This();
        pub const num_cols = C;
        pub const num_rows = R;

        m: [C * R]T,

        pub inline fn idx(col: usize, row: usize) usize {
            return switch (config.shader_lang) {
                .glsl => col * R + row,
                .hlsl => row * C + col,
            };
        }

        inline fn matIdx(comptime cols: usize, comptime rows: usize, col: usize, row: usize) usize {
            return switch (config.shader_lang) {
                .glsl => col * rows + row,
                .hlsl => row * cols + col,
            };
        }

        // ── All matrices ──

        pub fn add(a: Self, b: Self) Self {
            var result: Self = undefined;
            for (0..C * R) |i| {
                result.m[i] = a.m[i] + b.m[i];
            }
            return result;
        }

        pub fn sub(a: Self, b: Self) Self {
            var result: Self = undefined;
            for (0..C * R) |i| {
                result.m[i] = a.m[i] - b.m[i];
            }
            return result;
        }

        pub fn scale(a: Self, s: T) Self {
            var result: Self = undefined;
            for (0..C * R) |i| {
                result.m[i] = a.m[i] * s;
            }
            return result;
        }

        pub fn transpose(a: Self) GenMat(T, R, C, config) {
            const Out = GenMat(T, R, C, config);
            var result: Out = undefined;
            for (0..C) |col| {
                for (0..R) |row| {
                    result.m[Out.idx(row, col)] = a.m[idx(col, row)];
                }
            }
            return result;
        }

        pub fn mul(a: Self, b: anytype) GenMat(T, @TypeOf(b).num_cols, R, config) {
            const B = @TypeOf(b);
            comptime {
                if (C != B.num_rows) @compileError("matrix dimension mismatch: lhs cols != rhs rows");
            }
            const Out = GenMat(T, B.num_cols, R, config);
            var result: Out = undefined;
            for (0..B.num_cols) |i| {
                for (0..R) |j| {
                    var sum: T = 0;
                    for (0..C) |k| {
                        sum += a.m[idx(k, j)] * b.m[matIdx(B.num_cols, B.num_rows, i, k)];
                    }
                    result.m[Out.idx(i, j)] = sum;
                }
            }
            return result;
        }

        // ── Square only (C == R) ──
        pub fn identity() Self {
            comptime if (C != R) @compileError("identity() requires a square matrix");
            const m = comptime blk: {
                var arr = [_]T{0} ** (C * R);
                for (0..C) |i| {
                    arr[idx(i, i)] = 1;
                }
                break :blk arr;
            };
            return Self{ .m = m };
        }

        pub fn trace(a: Self) T {
            comptime {
                if (C != R) @compileError("trace() requires a square matrix");
            }
            var sum: T = 0;
            for (0..C) |i| {
                sum += a.m[idx(i, i)];
            }
            return sum;
        }

        pub fn determinant(a: Self) T {
            comptime {
                if (C != R) @compileError("determinant() requires a square matrix");
            }
            if (C == 2) {
                return a.m[idx(0, 0)] * a.m[idx(1, 1)] - a.m[idx(0, 1)] * a.m[idx(1, 0)];
            } else if (C == 3) {
                const a00 = a.m[idx(0, 0)];
                const a01 = a.m[idx(0, 1)];
                const a02 = a.m[idx(0, 2)];
                const a10 = a.m[idx(1, 0)];
                const a11 = a.m[idx(1, 1)];
                const a12 = a.m[idx(1, 2)];
                const a20 = a.m[idx(2, 0)];
                const a21 = a.m[idx(2, 1)];
                const a22 = a.m[idx(2, 2)];
                return a00 * (a11 * a22 - a12 * a21) - a01 * (a10 * a22 - a12 * a20) + a02 * (a10 * a21 - a11 * a20);
            } else if (C == 4) {
                return det4x4(a);
            } else {
                @compileError("determinant() only supports 2x2, 3x3, and 4x4 matrices");
            }
        }

        fn det4x4(a: Self) T {
            const s0 = a.m[idx(0, 0)] * a.m[idx(1, 1)] - a.m[idx(1, 0)] * a.m[idx(0, 1)];
            const s1 = a.m[idx(0, 0)] * a.m[idx(1, 2)] - a.m[idx(1, 0)] * a.m[idx(0, 2)];
            const s2 = a.m[idx(0, 0)] * a.m[idx(1, 3)] - a.m[idx(1, 0)] * a.m[idx(0, 3)];
            const s3 = a.m[idx(0, 1)] * a.m[idx(1, 2)] - a.m[idx(1, 1)] * a.m[idx(0, 2)];
            const s4 = a.m[idx(0, 1)] * a.m[idx(1, 3)] - a.m[idx(1, 1)] * a.m[idx(0, 3)];
            const s5 = a.m[idx(0, 2)] * a.m[idx(1, 3)] - a.m[idx(1, 2)] * a.m[idx(0, 3)];

            const c5 = a.m[idx(2, 2)] * a.m[idx(3, 3)] - a.m[idx(3, 2)] * a.m[idx(2, 3)];
            const c4 = a.m[idx(2, 1)] * a.m[idx(3, 3)] - a.m[idx(3, 1)] * a.m[idx(2, 3)];
            const c3 = a.m[idx(2, 1)] * a.m[idx(3, 2)] - a.m[idx(3, 1)] * a.m[idx(2, 2)];
            const c2 = a.m[idx(2, 0)] * a.m[idx(3, 3)] - a.m[idx(3, 0)] * a.m[idx(2, 3)];
            const c1 = a.m[idx(2, 0)] * a.m[idx(3, 2)] - a.m[idx(3, 0)] * a.m[idx(2, 2)];
            const c0 = a.m[idx(2, 0)] * a.m[idx(3, 1)] - a.m[idx(3, 0)] * a.m[idx(2, 1)];

            return s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0;
        }

        pub fn inverse(a: Self) Self {
            comptime {
                if (C != R) @compileError("inverse() requires a square matrix");
            }
            if (C == 2) {
                return inv2x2(a);
            } else if (C == 3) {
                return inv3x3(a);
            } else if (C == 4) {
                return inv4x4(a);
            } else {
                @compileError("inverse() only supports 2x2, 3x3, and 4x4 matrices");
            }
        }

        fn inv2x2(a: Self) Self {
            const det = a.m[idx(0, 0)] * a.m[idx(1, 1)] - a.m[idx(0, 1)] * a.m[idx(1, 0)];
            const inv_det = 1.0 / det;
            return Self{ .m = .{
                 a.m[idx(1, 1)] * inv_det,
                -a.m[idx(0, 1)] * inv_det,
                -a.m[idx(1, 0)] * inv_det,
                 a.m[idx(0, 0)] * inv_det,
            } };
        }

        fn inv3x3(a: Self) Self {
            const a00 = a.m[idx(0, 0)];
            const a01 = a.m[idx(0, 1)];
            const a02 = a.m[idx(0, 2)];
            const a10 = a.m[idx(1, 0)];
            const a11 = a.m[idx(1, 1)];
            const a12 = a.m[idx(1, 2)];
            const a20 = a.m[idx(2, 0)];
            const a21 = a.m[idx(2, 1)];
            const a22 = a.m[idx(2, 2)];

            const cof00 = a11 * a22 - a12 * a21;
            const cof01 = a12 * a20 - a10 * a22;
            const cof02 = a10 * a21 - a11 * a20;

            const inv_det = 1.0 / (a00 * cof00 + a01 * cof01 + a02 * cof02);

            return Self{ .m = .{
                cof00 * inv_det,
                (a02 * a21 - a01 * a22) * inv_det,
                (a01 * a12 - a02 * a11) * inv_det,

                cof01 * inv_det,
                (a00 * a22 - a02 * a20) * inv_det,
                (a02 * a10 - a00 * a12) * inv_det,

                cof02 * inv_det,
                (a01 * a20 - a00 * a21) * inv_det,
                (a00 * a11 - a01 * a10) * inv_det,
            } };
        }

        fn inv4x4(a: Self) Self {
            const s0 = a.m[idx(0, 0)] * a.m[idx(1, 1)] - a.m[idx(1, 0)] * a.m[idx(0, 1)];
            const s1 = a.m[idx(0, 0)] * a.m[idx(1, 2)] - a.m[idx(1, 0)] * a.m[idx(0, 2)];
            const s2 = a.m[idx(0, 0)] * a.m[idx(1, 3)] - a.m[idx(1, 0)] * a.m[idx(0, 3)];
            const s3 = a.m[idx(0, 1)] * a.m[idx(1, 2)] - a.m[idx(1, 1)] * a.m[idx(0, 2)];
            const s4 = a.m[idx(0, 1)] * a.m[idx(1, 3)] - a.m[idx(1, 1)] * a.m[idx(0, 3)];
            const s5 = a.m[idx(0, 2)] * a.m[idx(1, 3)] - a.m[idx(1, 2)] * a.m[idx(0, 3)];

            const c5 = a.m[idx(2, 2)] * a.m[idx(3, 3)] - a.m[idx(3, 2)] * a.m[idx(2, 3)];
            const c4 = a.m[idx(2, 1)] * a.m[idx(3, 3)] - a.m[idx(3, 1)] * a.m[idx(2, 3)];
            const c3 = a.m[idx(2, 1)] * a.m[idx(3, 2)] - a.m[idx(3, 1)] * a.m[idx(2, 2)];
            const c2 = a.m[idx(2, 0)] * a.m[idx(3, 3)] - a.m[idx(3, 0)] * a.m[idx(2, 3)];
            const c1 = a.m[idx(2, 0)] * a.m[idx(3, 2)] - a.m[idx(3, 0)] * a.m[idx(2, 2)];
            const c0 = a.m[idx(2, 0)] * a.m[idx(3, 1)] - a.m[idx(3, 0)] * a.m[idx(2, 1)];

            const det = s0 * c5 - s1 * c4 + s2 * c3 + s3 * c2 - s4 * c1 + s5 * c0;
            const inv_det = 1.0 / det;

            return Self{ .m = .{
                ( a.m[idx(1, 1)] * c5 - a.m[idx(1, 2)] * c4 + a.m[idx(1, 3)] * c3) * inv_det,
                (-a.m[idx(0, 1)] * c5 + a.m[idx(0, 2)] * c4 - a.m[idx(0, 3)] * c3) * inv_det,
                ( a.m[idx(3, 1)] * s5 - a.m[idx(3, 2)] * s4 + a.m[idx(3, 3)] * s3) * inv_det,
                (-a.m[idx(2, 1)] * s5 + a.m[idx(2, 2)] * s4 - a.m[idx(2, 3)] * s3) * inv_det,

                (-a.m[idx(1, 0)] * c5 + a.m[idx(1, 2)] * c2 - a.m[idx(1, 3)] * c1) * inv_det,
                ( a.m[idx(0, 0)] * c5 - a.m[idx(0, 2)] * c2 + a.m[idx(0, 3)] * c1) * inv_det,
                (-a.m[idx(3, 0)] * s5 + a.m[idx(3, 2)] * s2 - a.m[idx(3, 3)] * s1) * inv_det,
                ( a.m[idx(2, 0)] * s5 - a.m[idx(2, 2)] * s2 + a.m[idx(2, 3)] * s1) * inv_det,

                ( a.m[idx(1, 0)] * c4 - a.m[idx(1, 1)] * c2 + a.m[idx(1, 3)] * c0) * inv_det,
                (-a.m[idx(0, 0)] * c4 + a.m[idx(0, 1)] * c2 - a.m[idx(0, 3)] * c0) * inv_det,
                ( a.m[idx(3, 0)] * s4 - a.m[idx(3, 1)] * s2 + a.m[idx(3, 3)] * s0) * inv_det,
                (-a.m[idx(2, 0)] * s4 + a.m[idx(2, 1)] * s2 - a.m[idx(2, 3)] * s0) * inv_det,

                (-a.m[idx(1, 0)] * c3 + a.m[idx(1, 1)] * c1 - a.m[idx(1, 2)] * c0) * inv_det,
                ( a.m[idx(0, 0)] * c3 - a.m[idx(0, 1)] * c1 + a.m[idx(0, 2)] * c0) * inv_det,
                (-a.m[idx(3, 0)] * s3 + a.m[idx(3, 1)] * s1 - a.m[idx(3, 2)] * s0) * inv_det,
                ( a.m[idx(2, 0)] * s3 - a.m[idx(2, 1)] * s1 + a.m[idx(2, 2)] * s0) * inv_det,
            } };
        }

        // ── 4x4 only ──

        pub fn perspective(fov: T, aspect: T, near: T, far: T) Self {
            comptime if (C != 4 or R != 4) @compileError("perspective() requires a 4x4 matrix");
            const inv_thf = 1.0 / @tan(fov / 2.0);
            const inv_fmn = 1.0 / (far - near);
            const z: T = 0;
            return Self{ .m = switch (config.graphics_api) {
                .vulkan => .{
                    inv_thf / aspect, z, z,                         z,
                    z,               -inv_thf, z,                   z,
                    z,                z, -far * inv_fmn,           -1.0,
                    z,                z, -(far * near) * inv_fmn,   z,
                },
                .opengl => .{
                    inv_thf / aspect, z, z,                             z,
                    z,                inv_thf, z,                       z,
                    z,                z, -(far + near) * inv_fmn,      -1.0,
                    z,                z, -(2.0 * far * near) * inv_fmn, z,
                },
            } };
        }

        pub fn translate(m: Self, v: GenVec3(T)) Self {
            comptime {
                if (C != 4 or R != 4) @compileError("translate() requires a 4x4 matrix");
            }
            var result = m;
            // result[3] = m[0]*v.x + m[1]*v.y + m[2]*v.z + m[3]
            for (0..R) |row| {
                result.m[idx(3, row)] =
                    m.m[idx(0, row)] * v.x +
                    m.m[idx(1, row)] * v.y +
                    m.m[idx(2, row)] * v.z +
                    m.m[idx(3, row)];
            }
            return result;
        }

        pub fn rotate(m: Self, angle: T, axis: GenVec3(T)) Self {
            comptime {
                if (C != 4 or R != 4) @compileError("rotate() requires a 4x4 matrix");
            }
            const Vec3T = GenVec3(T);
            const a = Vec3T.normalize(axis);
            const c = @cos(angle);
            const s = @sin(angle);
            const t: T = 1.0 - c;

            const xy_t = a.x * a.y * t;
            const xz_t = a.x * a.z * t;
            const yz_t = a.y * a.z * t;
            const xs = a.x * s;
            const ys = a.y * s;
            const zs = a.z * s;

            const r00 = c + a.x * a.x * t;
            const r01 = xy_t + zs;
            const r02 = xz_t - ys;

            const r10 = xy_t - zs;
            const r11 = c + a.y * a.y * t;
            const r12 = yz_t + xs;

            const r20 = xz_t + ys;
            const r21 = yz_t - xs;
            const r22 = c + a.z * a.z * t;

            // result = m * R (only first 3 columns change, column 3 stays)
            var result = m;
            for (0..R) |row| {
                const m0 = m.m[idx(0, row)];
                const m1 = m.m[idx(1, row)];
                const m2 = m.m[idx(2, row)];
                result.m[idx(0, row)] = m0 * r00 + m1 * r01 + m2 * r02;
                result.m[idx(1, row)] = m0 * r10 + m1 * r11 + m2 * r12;
                result.m[idx(2, row)] = m0 * r20 + m1 * r21 + m2 * r22;
            }
            return result;
        }

        pub fn reScale(m: Self, v: GenVec3(T)) Self {
            comptime {
                if (C != 4 or R != 4) @compileError("reScale() requires a 4x4 matrix");
            }
            var result = m;
            for (0..R) |row| {
                result.m[idx(0, row)] = m.m[idx(0, row)] * v.x;
                result.m[idx(1, row)] = m.m[idx(1, row)] * v.y;
                result.m[idx(2, row)] = m.m[idx(2, row)] * v.z;
            }
            return result;
        }

        pub fn lookAt(eye: GenVec3(T), target: GenVec3(T), up: GenVec3(T)) Self {
            comptime if (C != 4 or R != 4) @compileError("lookAt() requires a 4x4 matrix");
            const Vec3T = GenVec3(T);
            const f = Vec3T.normalize(Vec3T.sub(target, eye));
            const s = Vec3T.normalize(Vec3T.cross(f, up));
            const u = Vec3T.cross(s, f);
            const z: T = 0;
            return Self{ .m = .{
                 s.x,  u.x, -f.x, z,
                 s.y,  u.y, -f.y, z,
                 s.z,  u.z, -f.z, z,
                -Vec3T.dot(s, eye), -Vec3T.dot(u, eye), Vec3T.dot(f, eye), 1,
            } };
        }
    };
}

fn GenRotor3(comptime T: type, comptime config: Config) type {
    return struct {
        const Self = @This();
        const Vec3T = GenVec3(T);
        const Mat3T = GenMat(T, 3, 3, config);
        const Mat4T = GenMat(T, 4, 4, config);

        s: T,
        e12: T,
        e13: T,
        e23: T,

        // ── Constructors ──

        pub fn init(s_val: T, e12_val: T, e13_val: T, e23_val: T) Self {
            return .{ .s = s_val, .e12 = e12_val, .e13 = e13_val, .e23 = e23_val };
        }

        pub fn identity() Self {
            return .{ .s = 1, .e12 = 0, .e13 = 0, .e23 = 0 };
        }

        pub fn fromAxisAngle(axis: Vec3T, angle: T) Self {
            const a = Vec3T.normalize(axis);
            const half = angle * 0.5;
            const sh = @sin(half);
            return .{
                .s = @cos(half),
                .e12 = a.z * sh,
                .e13 = -a.y * sh,
                .e23 = a.x * sh,
            };
        }
    };
}

// ── Tests ──

const testing = std.testing;
const eps = std.math.floatEps(f32);

fn expectApprox(expected: f32, actual: f32) !void {
    try testing.expectApproxEqAbs(expected, actual, 1e-5);
}

fn expectMat4(expected: [16]f32, actual: [16]f32) !void {
    for (0..16) |i| {
        try testing.expectApproxEqAbs(expected[i], actual[i], 1e-5);
    }
}

const zlm = init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });
const Mat4 = zlm.Mat4(f32);
const Vec3 = zlm.Vec3(f32);

test "translate identity" {
    const m = Mat4.translate(Mat4.identity(), Vec3.init(2.0, 3.0, 4.0));

    // Column-major: translation goes in column 3
    try expectApprox(1.0, m.m[Mat4.idx(0, 0)]);
    try expectApprox(0.0, m.m[Mat4.idx(1, 0)]);
    try expectApprox(0.0, m.m[Mat4.idx(2, 0)]);
    try expectApprox(2.0, m.m[Mat4.idx(3, 0)]);

    try expectApprox(0.0, m.m[Mat4.idx(0, 1)]);
    try expectApprox(1.0, m.m[Mat4.idx(1, 1)]);
    try expectApprox(0.0, m.m[Mat4.idx(2, 1)]);
    try expectApprox(3.0, m.m[Mat4.idx(3, 1)]);

    try expectApprox(0.0, m.m[Mat4.idx(0, 2)]);
    try expectApprox(0.0, m.m[Mat4.idx(1, 2)]);
    try expectApprox(1.0, m.m[Mat4.idx(2, 2)]);
    try expectApprox(4.0, m.m[Mat4.idx(3, 2)]);

    try expectApprox(0.0, m.m[Mat4.idx(0, 3)]);
    try expectApprox(0.0, m.m[Mat4.idx(1, 3)]);
    try expectApprox(0.0, m.m[Mat4.idx(2, 3)]);
    try expectApprox(1.0, m.m[Mat4.idx(3, 3)]);
}

test "translate composes" {
    var m = Mat4.identity();
    m = Mat4.translate(m, Vec3.init(1.0, 0.0, 0.0));
    m = Mat4.translate(m, Vec3.init(0.0, 2.0, 0.0));

    try expectApprox(1.0, m.m[Mat4.idx(3, 0)]);
    try expectApprox(2.0, m.m[Mat4.idx(3, 1)]);
    try expectApprox(0.0, m.m[Mat4.idx(3, 2)]);
}

test "rotate 90 degrees around Z axis" {
    const angle = std.math.pi / 2.0;
    const m = Mat4.rotate(Mat4.identity(), angle, Vec3.init(0.0, 0.0, 1.0));

    // cos(90) = 0, sin(90) = 1
    // col0 = (0, 1, 0, 0), col1 = (-1, 0, 0, 0), col2 = (0, 0, 1, 0), col3 = (0, 0, 0, 1)
    try expectApprox(0.0, m.m[Mat4.idx(0, 0)]);
    try expectApprox(1.0, m.m[Mat4.idx(0, 1)]);
    try expectApprox(-1.0, m.m[Mat4.idx(1, 0)]);
    try expectApprox(0.0, m.m[Mat4.idx(1, 1)]);
    try expectApprox(1.0, m.m[Mat4.idx(2, 2)]);
    try expectApprox(1.0, m.m[Mat4.idx(3, 3)]);
}

test "rotate 90 degrees around Y axis" {
    const angle = std.math.pi / 2.0;
    const m = Mat4.rotate(Mat4.identity(), angle, Vec3.init(0.0, 1.0, 0.0));

    // col0 = (0, 0, -1, 0), col1 = (0, 1, 0, 0), col2 = (1, 0, 0, 0)
    try expectApprox(0.0, m.m[Mat4.idx(0, 0)]);
    try expectApprox(-1.0, m.m[Mat4.idx(0, 2)]);
    try expectApprox(1.0, m.m[Mat4.idx(1, 1)]);
    try expectApprox(1.0, m.m[Mat4.idx(2, 0)]);
    try expectApprox(0.0, m.m[Mat4.idx(2, 2)]);
}

test "rotate 360 degrees returns identity" {
    const m = Mat4.rotate(Mat4.identity(), 2.0 * std.math.pi, Vec3.init(1.0, 1.0, 1.0));
    try expectMat4(Mat4.identity().m, m.m);
}

test "reScale identity" {
    const m = Mat4.reScale(Mat4.identity(), Vec3.init(2.0, 3.0, 4.0));

    try expectApprox(2.0, m.m[Mat4.idx(0, 0)]);
    try expectApprox(3.0, m.m[Mat4.idx(1, 1)]);
    try expectApprox(4.0, m.m[Mat4.idx(2, 2)]);
    try expectApprox(1.0, m.m[Mat4.idx(3, 3)]);

    // Off-diagonals should be zero
    try expectApprox(0.0, m.m[Mat4.idx(1, 0)]);
    try expectApprox(0.0, m.m[Mat4.idx(0, 1)]);
    try expectApprox(0.0, m.m[Mat4.idx(2, 0)]);
}

test "reScale preserves translation" {
    var m = Mat4.translate(Mat4.identity(), Vec3.init(5.0, 6.0, 7.0));
    m = Mat4.reScale(m, Vec3.init(2.0, 2.0, 2.0));

    // Translation column unchanged
    try expectApprox(5.0, m.m[Mat4.idx(3, 0)]);
    try expectApprox(6.0, m.m[Mat4.idx(3, 1)]);
    try expectApprox(7.0, m.m[Mat4.idx(3, 2)]);

    // Scale applied to basis
    try expectApprox(2.0, m.m[Mat4.idx(0, 0)]);
    try expectApprox(2.0, m.m[Mat4.idx(1, 1)]);
    try expectApprox(2.0, m.m[Mat4.idx(2, 2)]);
}

test "translate then rotate then reScale" {
    var m = Mat4.identity();
    m = Mat4.translate(m, Vec3.init(1.0, 2.0, 3.0));
    m = Mat4.rotate(m, std.math.pi / 2.0, Vec3.init(0.0, 0.0, 1.0));
    m = Mat4.reScale(m, Vec3.init(2.0, 2.0, 2.0));

    // Apply to point (1, 0, 0, 1): scale(2,2,2) -> (2,0,0), rotate Z 90 -> (0,2,0), translate -> (1,4,3)
    const px = m.m[Mat4.idx(0, 0)] * 1.0 + m.m[Mat4.idx(1, 0)] * 0.0 + m.m[Mat4.idx(2, 0)] * 0.0 + m.m[Mat4.idx(3, 0)];
    const py = m.m[Mat4.idx(0, 1)] * 1.0 + m.m[Mat4.idx(1, 1)] * 0.0 + m.m[Mat4.idx(2, 1)] * 0.0 + m.m[Mat4.idx(3, 1)];
    const pz = m.m[Mat4.idx(0, 2)] * 1.0 + m.m[Mat4.idx(1, 2)] * 0.0 + m.m[Mat4.idx(2, 2)] * 0.0 + m.m[Mat4.idx(3, 2)];

    try expectApprox(1.0, px);
    try expectApprox(4.0, py);
    try expectApprox(3.0, pz);
}
