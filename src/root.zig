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
        pub fn Quat(comptime T: type) type {
            return GenQuat(T, config);
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

        // ── Algebra ──

        pub fn mul(p: Self, q: Self) Self {
            return .{
                .s = p.s * q.s - p.e12 * q.e12 - p.e13 * q.e13 - p.e23 * q.e23,
                .e12 = p.s * q.e12 + p.e12 * q.s - p.e13 * q.e23 + p.e23 * q.e13,
                .e13 = p.s * q.e13 + p.e13 * q.s + p.e12 * q.e23 - p.e23 * q.e12,
                .e23 = p.s * q.e23 + p.e23 * q.s - p.e12 * q.e13 + p.e13 * q.e12,
            };
        }

        pub fn conjugate(r: Self) Self {
            return .{ .s = r.s, .e12 = -r.e12, .e13 = -r.e13, .e23 = -r.e23 };
        }

        pub fn norm(r: Self) T {
            return @sqrt(r.s * r.s + r.e12 * r.e12 + r.e13 * r.e13 + r.e23 * r.e23);
        }

        pub fn normalize(r: Self) Self {
            const n = norm(r);
            if (n < std.math.floatEps(T)) return r;
            const inv = 1.0 / n;
            return .{ .s = r.s * inv, .e12 = r.e12 * inv, .e13 = r.e13 * inv, .e23 = r.e23 * inv };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.s * b.s + a.e12 * b.e12 + a.e13 * b.e13 + a.e23 * b.e23;
        }

        pub fn inverse(r: Self) Self {
            const n2 = r.s * r.s + r.e12 * r.e12 + r.e13 * r.e13 + r.e23 * r.e23;
            const inv = 1.0 / n2;
            return .{ .s = r.s * inv, .e12 = -r.e12 * inv, .e13 = -r.e13 * inv, .e23 = -r.e23 * inv };
        }

        // ── Rotation ──

        pub fn rotate(r: Self, v: Vec3T) Vec3T {
            const w = r.s;
            const qx = r.e23;
            const qy = -r.e13;
            const qz = r.e12;

            const tx = 2 * (qy * v.z - qz * v.y);
            const ty = 2 * (qz * v.x - qx * v.z);
            const tz = 2 * (qx * v.y - qy * v.x);

            return Vec3T{
                .x = v.x + w * tx + (qy * tz - qz * ty),
                .y = v.y + w * ty + (qz * tx - qx * tz),
                .z = v.z + w * tz + (qx * ty - qy * tx),
            };
        }

        // ── Conversion ──

        pub fn toMat3(r: Self) Mat3T {
            const w = r.s;
            const x = r.e23;
            const y = -r.e13;
            const z = r.e12;

            const x2 = x + x;
            const y2 = y + y;
            const z2 = z + z;
            const xx = x * x2;
            const xy = x * y2;
            const xz = x * z2;
            const yy = y * y2;
            const yz = y * z2;
            const zz = z * z2;
            const wx = w * x2;
            const wy = w * y2;
            const wz = w * z2;

            var result: Mat3T = undefined;
            result.m[Mat3T.idx(0, 0)] = 1 - (yy + zz);
            result.m[Mat3T.idx(0, 1)] = xy + wz;
            result.m[Mat3T.idx(0, 2)] = xz - wy;
            result.m[Mat3T.idx(1, 0)] = xy - wz;
            result.m[Mat3T.idx(1, 1)] = 1 - (xx + zz);
            result.m[Mat3T.idx(1, 2)] = yz + wx;
            result.m[Mat3T.idx(2, 0)] = xz + wy;
            result.m[Mat3T.idx(2, 1)] = yz - wx;
            result.m[Mat3T.idx(2, 2)] = 1 - (xx + yy);
            return result;
        }

        pub fn toMat4(r: Self) Mat4T {
            const w = r.s;
            const x = r.e23;
            const y = -r.e13;
            const z = r.e12;

            const x2 = x + x;
            const y2 = y + y;
            const z2 = z + z;
            const xx = x * x2;
            const xy = x * y2;
            const xz = x * z2;
            const yy = y * y2;
            const yz = y * z2;
            const zz = z * z2;
            const wx = w * x2;
            const wy = w * y2;
            const wz = w * z2;

            const zero: T = 0;
            var result: Mat4T = undefined;
            result.m[Mat4T.idx(0, 0)] = 1 - (yy + zz);
            result.m[Mat4T.idx(0, 1)] = xy + wz;
            result.m[Mat4T.idx(0, 2)] = xz - wy;
            result.m[Mat4T.idx(0, 3)] = zero;
            result.m[Mat4T.idx(1, 0)] = xy - wz;
            result.m[Mat4T.idx(1, 1)] = 1 - (xx + zz);
            result.m[Mat4T.idx(1, 2)] = yz + wx;
            result.m[Mat4T.idx(1, 3)] = zero;
            result.m[Mat4T.idx(2, 0)] = xz + wy;
            result.m[Mat4T.idx(2, 1)] = yz - wx;
            result.m[Mat4T.idx(2, 2)] = 1 - (xx + yy);
            result.m[Mat4T.idx(2, 3)] = zero;
            result.m[Mat4T.idx(3, 0)] = zero;
            result.m[Mat4T.idx(3, 1)] = zero;
            result.m[Mat4T.idx(3, 2)] = zero;
            result.m[Mat4T.idx(3, 3)] = 1;
            return result;
        }

        pub fn fromMat3(m: Mat3T) Self {
            const m00 = m.m[Mat3T.idx(0, 0)];
            const m11 = m.m[Mat3T.idx(1, 1)];
            const m22 = m.m[Mat3T.idx(2, 2)];
            const tr = m00 + m11 + m22;

            var w: T = undefined;
            var x: T = undefined;
            var y: T = undefined;
            var z: T = undefined;

            if (tr > 0) {
                const s_val = @sqrt(tr + 1.0) * 2.0;
                w = 0.25 * s_val;
                x = (m.m[Mat3T.idx(1, 2)] - m.m[Mat3T.idx(2, 1)]) / s_val;
                y = (m.m[Mat3T.idx(2, 0)] - m.m[Mat3T.idx(0, 2)]) / s_val;
                z = (m.m[Mat3T.idx(0, 1)] - m.m[Mat3T.idx(1, 0)]) / s_val;
            } else if (m00 > m11 and m00 > m22) {
                const s_val = @sqrt(1.0 + m00 - m11 - m22) * 2.0;
                w = (m.m[Mat3T.idx(1, 2)] - m.m[Mat3T.idx(2, 1)]) / s_val;
                x = 0.25 * s_val;
                y = (m.m[Mat3T.idx(0, 1)] + m.m[Mat3T.idx(1, 0)]) / s_val;
                z = (m.m[Mat3T.idx(2, 0)] + m.m[Mat3T.idx(0, 2)]) / s_val;
            } else if (m11 > m22) {
                const s_val = @sqrt(1.0 + m11 - m00 - m22) * 2.0;
                w = (m.m[Mat3T.idx(2, 0)] - m.m[Mat3T.idx(0, 2)]) / s_val;
                x = (m.m[Mat3T.idx(0, 1)] + m.m[Mat3T.idx(1, 0)]) / s_val;
                y = 0.25 * s_val;
                z = (m.m[Mat3T.idx(1, 2)] + m.m[Mat3T.idx(2, 1)]) / s_val;
            } else {
                const s_val = @sqrt(1.0 + m22 - m00 - m11) * 2.0;
                w = (m.m[Mat3T.idx(0, 1)] - m.m[Mat3T.idx(1, 0)]) / s_val;
                x = (m.m[Mat3T.idx(2, 0)] + m.m[Mat3T.idx(0, 2)]) / s_val;
                y = (m.m[Mat3T.idx(1, 2)] + m.m[Mat3T.idx(2, 1)]) / s_val;
                z = 0.25 * s_val;
            }

            return .{ .s = w, .e12 = z, .e13 = -y, .e23 = x };
        }

        pub fn fromMat4(m: Mat4T) Self {
            var m3: Mat3T = undefined;
            for (0..3) |col| {
                for (0..3) |row| {
                    m3.m[Mat3T.idx(col, row)] = m.m[Mat4T.idx(col, row)];
                }
            }
            return fromMat3(m3);
        }

        pub fn toAxisAngle(r: Self) struct { axis: Vec3T, angle: T } {
            const n = normalize(r);
            const sin_half_sq = n.e12 * n.e12 + n.e13 * n.e13 + n.e23 * n.e23;

            if (sin_half_sq < std.math.floatEps(T)) {
                return .{ .axis = Vec3T.init(1, 0, 0), .angle = 0 };
            }

            const sin_half = @sqrt(sin_half_sq);
            const angle = 2.0 * std.math.atan2(sin_half, n.s);
            const inv_sh = 1.0 / sin_half;

            return .{
                .axis = Vec3T.init(n.e23 * inv_sh, -n.e13 * inv_sh, n.e12 * inv_sh),
                .angle = angle,
            };
        }

        // ── Interpolation ──

        pub fn slerp(a: Self, b: Self, t: T) Self {
            var d = dot(a, b);
            var b2 = b;

            if (d < 0) {
                d = -d;
                b2 = .{ .s = -b.s, .e12 = -b.e12, .e13 = -b.e13, .e23 = -b.e23 };
            }

            if (d > 1.0 - std.math.floatEps(T)) {
                return nlerpPreflipped(a, b2, t);
            }

            const theta = std.math.acos(d);
            const sin_theta = @sin(theta);
            const wa = @sin((1.0 - t) * theta) / sin_theta;
            const wb = @sin(t * theta) / sin_theta;

            return .{
                .s = a.s * wa + b2.s * wb,
                .e12 = a.e12 * wa + b2.e12 * wb,
                .e13 = a.e13 * wa + b2.e13 * wb,
                .e23 = a.e23 * wa + b2.e23 * wb,
            };
        }

        pub fn nlerp(a: Self, b: Self, t: T) Self {
            var b2 = b;
            if (dot(a, b) < 0) {
                b2 = .{ .s = -b.s, .e12 = -b.e12, .e13 = -b.e13, .e23 = -b.e23 };
            }
            return nlerpPreflipped(a, b2, t);
        }

        fn nlerpPreflipped(a: Self, b2: Self, t: T) Self {
            const omt = 1.0 - t;
            return normalize(.{
                .s = a.s * omt + b2.s * t,
                .e12 = a.e12 * omt + b2.e12 * t,
                .e13 = a.e13 * omt + b2.e13 * t,
                .e23 = a.e23 * omt + b2.e23 * t,
            });
        }
    };
}

fn GenQuat(comptime T: type, comptime config: Config) type {
    return struct {
        const Self = @This();
        const Vec3T = GenVec3(T);
        const Mat3T = GenMat(T, 3, 3, config);
        const Mat4T = GenMat(T, 4, 4, config);
        const Rotor3T = GenRotor3(T, config);

        w: T,
        x: T,
        y: T,
        z: T,

        // ── Constructors ──

        pub fn init(w_val: T, x_val: T, y_val: T, z_val: T) Self {
            return .{ .w = w_val, .x = x_val, .y = y_val, .z = z_val };
        }

        pub fn identity() Self {
            return .{ .w = 1, .x = 0, .y = 0, .z = 0 };
        }

        pub fn fromAxisAngle(axis: Vec3T, angle: T) Self {
            const a = Vec3T.normalize(axis);
            const half = angle * 0.5;
            const sh = @sin(half);
            return .{
                .w = @cos(half),
                .x = a.x * sh,
                .y = a.y * sh,
                .z = a.z * sh,
            };
        }

        // ── Algebra ──

        pub fn mul(p: Self, q: Self) Self {
            return .{
                .w = p.w * q.w - p.x * q.x - p.y * q.y - p.z * q.z,
                .x = p.w * q.x + p.x * q.w + p.y * q.z - p.z * q.y,
                .y = p.w * q.y + p.y * q.w + p.z * q.x - p.x * q.z,
                .z = p.w * q.z + p.z * q.w + p.x * q.y - p.y * q.x,
            };
        }

        pub fn conjugate(q: Self) Self {
            return .{ .w = q.w, .x = -q.x, .y = -q.y, .z = -q.z };
        }

        pub fn norm(q: Self) T {
            return @sqrt(q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z);
        }

        pub fn normalize(q: Self) Self {
            const n = norm(q);
            if (n < std.math.floatEps(T)) return q;
            const inv = 1.0 / n;
            return .{ .w = q.w * inv, .x = q.x * inv, .y = q.y * inv, .z = q.z * inv };
        }

        pub fn dot(a: Self, b: Self) T {
            return a.w * b.w + a.x * b.x + a.y * b.y + a.z * b.z;
        }

        pub fn inverse(q: Self) Self {
            const n2 = q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z;
            const inv = 1.0 / n2;
            return .{ .w = q.w * inv, .x = -q.x * inv, .y = -q.y * inv, .z = -q.z * inv };
        }

        // ── Rotation ──

        pub fn rotate(q: Self, v: Vec3T) Vec3T {
            const tx = 2 * (q.y * v.z - q.z * v.y);
            const ty = 2 * (q.z * v.x - q.x * v.z);
            const tz = 2 * (q.x * v.y - q.y * v.x);

            return Vec3T{
                .x = v.x + q.w * tx + (q.y * tz - q.z * ty),
                .y = v.y + q.w * ty + (q.z * tx - q.x * tz),
                .z = v.z + q.w * tz + (q.x * ty - q.y * tx),
            };
        }

        // ── Conversion ──

        pub fn toMat3(q: Self) Mat3T {
            const x2 = q.x + q.x;
            const y2 = q.y + q.y;
            const z2 = q.z + q.z;
            const xx = q.x * x2;
            const xy = q.x * y2;
            const xz = q.x * z2;
            const yy = q.y * y2;
            const yz = q.y * z2;
            const zz = q.z * z2;
            const wx = q.w * x2;
            const wy = q.w * y2;
            const wz = q.w * z2;

            var result: Mat3T = undefined;
            result.m[Mat3T.idx(0, 0)] = 1 - (yy + zz);
            result.m[Mat3T.idx(0, 1)] = xy + wz;
            result.m[Mat3T.idx(0, 2)] = xz - wy;
            result.m[Mat3T.idx(1, 0)] = xy - wz;
            result.m[Mat3T.idx(1, 1)] = 1 - (xx + zz);
            result.m[Mat3T.idx(1, 2)] = yz + wx;
            result.m[Mat3T.idx(2, 0)] = xz + wy;
            result.m[Mat3T.idx(2, 1)] = yz - wx;
            result.m[Mat3T.idx(2, 2)] = 1 - (xx + yy);
            return result;
        }

        pub fn toMat4(q: Self) Mat4T {
            const x2 = q.x + q.x;
            const y2 = q.y + q.y;
            const z2 = q.z + q.z;
            const xx = q.x * x2;
            const xy = q.x * y2;
            const xz = q.x * z2;
            const yy = q.y * y2;
            const yz = q.y * z2;
            const zz = q.z * z2;
            const wx = q.w * x2;
            const wy = q.w * y2;
            const wz = q.w * z2;

            const zero: T = 0;
            var result: Mat4T = undefined;
            result.m[Mat4T.idx(0, 0)] = 1 - (yy + zz);
            result.m[Mat4T.idx(0, 1)] = xy + wz;
            result.m[Mat4T.idx(0, 2)] = xz - wy;
            result.m[Mat4T.idx(0, 3)] = zero;
            result.m[Mat4T.idx(1, 0)] = xy - wz;
            result.m[Mat4T.idx(1, 1)] = 1 - (xx + zz);
            result.m[Mat4T.idx(1, 2)] = yz + wx;
            result.m[Mat4T.idx(1, 3)] = zero;
            result.m[Mat4T.idx(2, 0)] = xz + wy;
            result.m[Mat4T.idx(2, 1)] = yz - wx;
            result.m[Mat4T.idx(2, 2)] = 1 - (xx + yy);
            result.m[Mat4T.idx(2, 3)] = zero;
            result.m[Mat4T.idx(3, 0)] = zero;
            result.m[Mat4T.idx(3, 1)] = zero;
            result.m[Mat4T.idx(3, 2)] = zero;
            result.m[Mat4T.idx(3, 3)] = 1;
            return result;
        }

        pub fn fromMat3(m: Mat3T) Self {
            const m00 = m.m[Mat3T.idx(0, 0)];
            const m11 = m.m[Mat3T.idx(1, 1)];
            const m22 = m.m[Mat3T.idx(2, 2)];
            const tr = m00 + m11 + m22;

            var w_val: T = undefined;
            var x_val: T = undefined;
            var y_val: T = undefined;
            var z_val: T = undefined;

            if (tr > 0) {
                const s = @sqrt(tr + 1.0) * 2.0;
                w_val = 0.25 * s;
                x_val = (m.m[Mat3T.idx(1, 2)] - m.m[Mat3T.idx(2, 1)]) / s;
                y_val = (m.m[Mat3T.idx(2, 0)] - m.m[Mat3T.idx(0, 2)]) / s;
                z_val = (m.m[Mat3T.idx(0, 1)] - m.m[Mat3T.idx(1, 0)]) / s;
            } else if (m00 > m11 and m00 > m22) {
                const s = @sqrt(1.0 + m00 - m11 - m22) * 2.0;
                w_val = (m.m[Mat3T.idx(1, 2)] - m.m[Mat3T.idx(2, 1)]) / s;
                x_val = 0.25 * s;
                y_val = (m.m[Mat3T.idx(0, 1)] + m.m[Mat3T.idx(1, 0)]) / s;
                z_val = (m.m[Mat3T.idx(2, 0)] + m.m[Mat3T.idx(0, 2)]) / s;
            } else if (m11 > m22) {
                const s = @sqrt(1.0 + m11 - m00 - m22) * 2.0;
                w_val = (m.m[Mat3T.idx(2, 0)] - m.m[Mat3T.idx(0, 2)]) / s;
                x_val = (m.m[Mat3T.idx(0, 1)] + m.m[Mat3T.idx(1, 0)]) / s;
                y_val = 0.25 * s;
                z_val = (m.m[Mat3T.idx(1, 2)] + m.m[Mat3T.idx(2, 1)]) / s;
            } else {
                const s = @sqrt(1.0 + m22 - m00 - m11) * 2.0;
                w_val = (m.m[Mat3T.idx(0, 1)] - m.m[Mat3T.idx(1, 0)]) / s;
                x_val = (m.m[Mat3T.idx(2, 0)] + m.m[Mat3T.idx(0, 2)]) / s;
                y_val = (m.m[Mat3T.idx(1, 2)] + m.m[Mat3T.idx(2, 1)]) / s;
                z_val = 0.25 * s;
            }

            return .{ .w = w_val, .x = x_val, .y = y_val, .z = z_val };
        }

        pub fn fromMat4(m: Mat4T) Self {
            var m3: Mat3T = undefined;
            for (0..3) |col| {
                for (0..3) |row| {
                    m3.m[Mat3T.idx(col, row)] = m.m[Mat4T.idx(col, row)];
                }
            }
            return fromMat3(m3);
        }

        pub fn toAxisAngle(q: Self) struct { axis: Vec3T, angle: T } {
            const n = normalize(q);
            const sin_half_sq = n.x * n.x + n.y * n.y + n.z * n.z;

            if (sin_half_sq < std.math.floatEps(T)) {
                return .{ .axis = Vec3T.init(1, 0, 0), .angle = 0 };
            }

            const sin_half = @sqrt(sin_half_sq);
            const angle = 2.0 * std.math.atan2(sin_half, n.w);
            const inv_sh = 1.0 / sin_half;

            return .{
                .axis = Vec3T.init(n.x * inv_sh, n.y * inv_sh, n.z * inv_sh),
                .angle = angle,
            };
        }

        // ── Interpolation ──

        pub fn slerp(a: Self, b: Self, t: T) Self {
            var d = dot(a, b);
            var b2 = b;

            if (d < 0) {
                d = -d;
                b2 = .{ .w = -b.w, .x = -b.x, .y = -b.y, .z = -b.z };
            }

            if (d > 1.0 - std.math.floatEps(T)) {
                return nlerpPreflipped(a, b2, t);
            }

            const theta = std.math.acos(d);
            const sin_theta = @sin(theta);
            const wa = @sin((1.0 - t) * theta) / sin_theta;
            const wb = @sin(t * theta) / sin_theta;

            return .{
                .w = a.w * wa + b2.w * wb,
                .x = a.x * wa + b2.x * wb,
                .y = a.y * wa + b2.y * wb,
                .z = a.z * wa + b2.z * wb,
            };
        }

        pub fn nlerp(a: Self, b: Self, t: T) Self {
            var b2 = b;
            if (dot(a, b) < 0) {
                b2 = .{ .w = -b.w, .x = -b.x, .y = -b.y, .z = -b.z };
            }
            return nlerpPreflipped(a, b2, t);
        }

        fn nlerpPreflipped(a: Self, b2: Self, t: T) Self {
            const omt = 1.0 - t;
            return normalize(.{
                .w = a.w * omt + b2.w * t,
                .x = a.x * omt + b2.x * t,
                .y = a.y * omt + b2.y * t,
                .z = a.z * omt + b2.z * t,
            });
        }

        // ── Rotor conversion ──

        pub fn toRotor3(q: Self) Rotor3T {
            return Rotor3T{ .s = q.w, .e12 = q.z, .e13 = -q.y, .e23 = q.x };
        }

        pub fn fromRotor3(r: Rotor3T) Self {
            return .{ .w = r.s, .x = r.e23, .y = -r.e13, .z = r.e12 };
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
const Rotor3 = zlm.Rotor3(f32);
const Quat = zlm.Quat(f32);

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

// ── Rotor3 Tests ──

test "rotor3: identity preserves vector" {
    const r = Rotor3.identity();
    const v = Vec3.init(1.0, 2.0, 3.0);
    const result = Rotor3.rotate(r, v);
    try expectApprox(1.0, result.x);
    try expectApprox(2.0, result.y);
    try expectApprox(3.0, result.z);
}

test "rotor3: 90 deg around X" {
    const r = Rotor3.fromAxisAngle(Vec3.init(1, 0, 0), std.math.pi / 2.0);
    // (0,1,0) -> (0,0,1)
    const v = Rotor3.rotate(r, Vec3.init(0, 1, 0));
    try expectApprox(0.0, v.x);
    try expectApprox(0.0, v.y);
    try expectApprox(1.0, v.z);
}

test "rotor3: 90 deg around Y" {
    const r = Rotor3.fromAxisAngle(Vec3.init(0, 1, 0), std.math.pi / 2.0);
    // (0,0,1) -> (1,0,0)... wait: R_y(90)(0,0,1) = (sin90, 0, cos90) = (1,0,0)
    const v = Rotor3.rotate(r, Vec3.init(0, 0, 1));
    try expectApprox(1.0, v.x);
    try expectApprox(0.0, v.y);
    try expectApprox(0.0, v.z);
}

test "rotor3: 90 deg around Z" {
    const r = Rotor3.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 2.0);
    // (1,0,0) -> (0,1,0)
    const v = Rotor3.rotate(r, Vec3.init(1, 0, 0));
    try expectApprox(0.0, v.x);
    try expectApprox(1.0, v.y);
    try expectApprox(0.0, v.z);
}

test "rotor3: axis-angle roundtrip" {
    const axis = Vec3.normalize(Vec3.init(1.0, 2.0, 3.0));
    const angle: f32 = 1.23;
    const r = Rotor3.fromAxisAngle(axis, angle);
    const aa = Rotor3.toAxisAngle(r);
    try expectApprox(axis.x, aa.axis.x);
    try expectApprox(axis.y, aa.axis.y);
    try expectApprox(axis.z, aa.axis.z);
    try expectApprox(angle, aa.angle);
}

test "rotor3: composition two 90 = 180" {
    const r90 = Rotor3.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 2.0);
    const r180 = Rotor3.mul(r90, r90);
    // (1,0,0) rotated 180 around Z -> (-1,0,0)
    const v = Rotor3.rotate(r180, Vec3.init(1, 0, 0));
    try expectApprox(-1.0, v.x);
    try expectApprox(0.0, v.y);
    try expectApprox(0.0, v.z);
}

test "rotor3: conjugate is inverse for unit rotor" {
    const r = Rotor3.fromAxisAngle(Vec3.normalize(Vec3.init(1, 1, 0)), 0.7);
    const prod = Rotor3.mul(r, Rotor3.conjugate(r));
    try expectApprox(1.0, prod.s);
    try expectApprox(0.0, prod.e12);
    try expectApprox(0.0, prod.e13);
    try expectApprox(0.0, prod.e23);
}

test "rotor3: toMat4 matches Mat4.rotate" {
    const axis = Vec3.init(0.0, 0.0, 1.0);
    const angle: f32 = std.math.pi / 3.0;
    const mat_rot = Mat4.rotate(Mat4.identity(), angle, axis);
    const rotor_mat = Rotor3.toMat4(Rotor3.fromAxisAngle(axis, angle));
    try expectMat4(mat_rot.m, rotor_mat.m);
}

test "rotor3: fromMat4 roundtrip" {
    const axis = Vec3.normalize(Vec3.init(1, 2, 3));
    const angle: f32 = 1.0;
    const r = Rotor3.fromAxisAngle(axis, angle);
    const m = Rotor3.toMat4(r);
    const r2 = Rotor3.fromMat4(m);
    // Rotors may differ by sign (double cover); compare absolute dot
    const d = @abs(Rotor3.dot(r, r2));
    try expectApprox(1.0, d);
}

test "rotor3: slerp endpoints and midpoint" {
    const a = Rotor3.fromAxisAngle(Vec3.init(0, 0, 1), 0.0);
    const b = Rotor3.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 2.0);

    // t=0 -> a
    const s0 = Rotor3.slerp(a, b, 0.0);
    try expectApprox(1.0, @abs(Rotor3.dot(s0, a)));

    // t=1 -> b
    const s1 = Rotor3.slerp(a, b, 1.0);
    try expectApprox(1.0, @abs(Rotor3.dot(s1, b)));

    // t=0.5 -> 45 degrees
    const s_half = Rotor3.slerp(a, b, 0.5);
    const expected = Rotor3.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 4.0);
    try expectApprox(1.0, @abs(Rotor3.dot(s_half, expected)));
}

test "rotor3: normalize produces unit norm" {
    const r = Rotor3.init(2, 3, 4, 5);
    const n = Rotor3.normalize(r);
    try expectApprox(1.0, Rotor3.norm(n));
}

// ── Quat Tests ──

test "quat: identity preserves vector" {
    const q = Quat.identity();
    const v = Vec3.init(1.0, 2.0, 3.0);
    const result = Quat.rotate(q, v);
    try expectApprox(1.0, result.x);
    try expectApprox(2.0, result.y);
    try expectApprox(3.0, result.z);
}

test "quat: 90 deg around X" {
    const q = Quat.fromAxisAngle(Vec3.init(1, 0, 0), std.math.pi / 2.0);
    const v = Quat.rotate(q, Vec3.init(0, 1, 0));
    try expectApprox(0.0, v.x);
    try expectApprox(0.0, v.y);
    try expectApprox(1.0, v.z);
}

test "quat: 90 deg around Y" {
    const q = Quat.fromAxisAngle(Vec3.init(0, 1, 0), std.math.pi / 2.0);
    const v = Quat.rotate(q, Vec3.init(0, 0, 1));
    try expectApprox(1.0, v.x);
    try expectApprox(0.0, v.y);
    try expectApprox(0.0, v.z);
}

test "quat: 90 deg around Z" {
    const q = Quat.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 2.0);
    const v = Quat.rotate(q, Vec3.init(1, 0, 0));
    try expectApprox(0.0, v.x);
    try expectApprox(1.0, v.y);
    try expectApprox(0.0, v.z);
}

test "quat: composition two 90 = 180" {
    const q90 = Quat.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 2.0);
    const q180 = Quat.mul(q90, q90);
    const v = Quat.rotate(q180, Vec3.init(1, 0, 0));
    try expectApprox(-1.0, v.x);
    try expectApprox(0.0, v.y);
    try expectApprox(0.0, v.z);
}

test "quat: conjugate is inverse for unit quat" {
    const q = Quat.fromAxisAngle(Vec3.normalize(Vec3.init(1, 1, 0)), 0.7);
    const prod = Quat.mul(q, Quat.conjugate(q));
    try expectApprox(1.0, prod.w);
    try expectApprox(0.0, prod.x);
    try expectApprox(0.0, prod.y);
    try expectApprox(0.0, prod.z);
}

test "quat: toMat4 matches Mat4.rotate" {
    const axis = Vec3.init(0.0, 0.0, 1.0);
    const angle: f32 = std.math.pi / 3.0;
    const mat_rot = Mat4.rotate(Mat4.identity(), angle, axis);
    const quat_mat = Quat.toMat4(Quat.fromAxisAngle(axis, angle));
    try expectMat4(mat_rot.m, quat_mat.m);
}

test "quat: fromMat4 roundtrip" {
    const axis = Vec3.normalize(Vec3.init(1, 2, 3));
    const angle: f32 = 1.0;
    const q = Quat.fromAxisAngle(axis, angle);
    const m = Quat.toMat4(q);
    const q2 = Quat.fromMat4(m);
    const d = @abs(Quat.dot(q, q2));
    try expectApprox(1.0, d);
}

test "quat: slerp endpoints and midpoint" {
    const a = Quat.fromAxisAngle(Vec3.init(0, 0, 1), 0.0);
    const b = Quat.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 2.0);

    const s0 = Quat.slerp(a, b, 0.0);
    try expectApprox(1.0, @abs(Quat.dot(s0, a)));

    const s1 = Quat.slerp(a, b, 1.0);
    try expectApprox(1.0, @abs(Quat.dot(s1, b)));

    const s_half = Quat.slerp(a, b, 0.5);
    const expected = Quat.fromAxisAngle(Vec3.init(0, 0, 1), std.math.pi / 4.0);
    try expectApprox(1.0, @abs(Quat.dot(s_half, expected)));
}

test "quat: rotor3 roundtrip" {
    const q = Quat.fromAxisAngle(Vec3.normalize(Vec3.init(1, 2, 3)), 1.5);
    const r = Quat.toRotor3(q);
    const q2 = Quat.fromRotor3(r);
    try expectApprox(q.w, q2.w);
    try expectApprox(q.x, q2.x);
    try expectApprox(q.y, q2.y);
    try expectApprox(q.z, q2.z);
}

test "quat: rotor3 rotation equivalence" {
    const axis = Vec3.normalize(Vec3.init(3, 1, 4));
    const angle: f32 = 2.1;
    const q = Quat.fromAxisAngle(axis, angle);
    const r = Quat.toRotor3(q);
    const v = Vec3.init(1.0, -2.0, 0.5);
    const vq = Quat.rotate(q, v);
    const vr = Rotor3.rotate(r, v);
    try expectApprox(vq.x, vr.x);
    try expectApprox(vq.y, vr.y);
    try expectApprox(vq.z, vr.z);
}
