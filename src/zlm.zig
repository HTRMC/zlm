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
            comptime {
                if (C != R) @compileError("identity() requires a square matrix");
            }
            var result = Self{ .m = [_]T{0} ** (C * R) };
            for (0..C) |i| {
                result.m[idx(i, i)] = 1;
            }
            return result;
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
            var result: Self = undefined;
            result.m[idx(0, 0)] = a.m[idx(1, 1)] * inv_det;
            result.m[idx(0, 1)] = -a.m[idx(0, 1)] * inv_det;
            result.m[idx(1, 0)] = -a.m[idx(1, 0)] * inv_det;
            result.m[idx(1, 1)] = a.m[idx(0, 0)] * inv_det;
            return result;
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

            const det = a00 * (a11 * a22 - a12 * a21) - a01 * (a10 * a22 - a12 * a20) + a02 * (a10 * a21 - a11 * a20);
            const inv_det = 1.0 / det;

            var result: Self = undefined;
            result.m[idx(0, 0)] = (a11 * a22 - a12 * a21) * inv_det;
            result.m[idx(0, 1)] = (a02 * a21 - a01 * a22) * inv_det;
            result.m[idx(0, 2)] = (a01 * a12 - a02 * a11) * inv_det;
            result.m[idx(1, 0)] = (a12 * a20 - a10 * a22) * inv_det;
            result.m[idx(1, 1)] = (a00 * a22 - a02 * a20) * inv_det;
            result.m[idx(1, 2)] = (a02 * a10 - a00 * a12) * inv_det;
            result.m[idx(2, 0)] = (a10 * a21 - a11 * a20) * inv_det;
            result.m[idx(2, 1)] = (a01 * a20 - a00 * a21) * inv_det;
            result.m[idx(2, 2)] = (a00 * a11 - a01 * a10) * inv_det;
            return result;
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

            var result: Self = undefined;
            result.m[idx(0, 0)] = (a.m[idx(1, 1)] * c5 - a.m[idx(1, 2)] * c4 + a.m[idx(1, 3)] * c3) * inv_det;
            result.m[idx(0, 1)] = (-a.m[idx(0, 1)] * c5 + a.m[idx(0, 2)] * c4 - a.m[idx(0, 3)] * c3) * inv_det;
            result.m[idx(0, 2)] = (a.m[idx(3, 1)] * s5 - a.m[idx(3, 2)] * s4 + a.m[idx(3, 3)] * s3) * inv_det;
            result.m[idx(0, 3)] = (-a.m[idx(2, 1)] * s5 + a.m[idx(2, 2)] * s4 - a.m[idx(2, 3)] * s3) * inv_det;

            result.m[idx(1, 0)] = (-a.m[idx(1, 0)] * c5 + a.m[idx(1, 2)] * c2 - a.m[idx(1, 3)] * c1) * inv_det;
            result.m[idx(1, 1)] = (a.m[idx(0, 0)] * c5 - a.m[idx(0, 2)] * c2 + a.m[idx(0, 3)] * c1) * inv_det;
            result.m[idx(1, 2)] = (-a.m[idx(3, 0)] * s5 + a.m[idx(3, 2)] * s2 - a.m[idx(3, 3)] * s1) * inv_det;
            result.m[idx(1, 3)] = (a.m[idx(2, 0)] * s5 - a.m[idx(2, 2)] * s2 + a.m[idx(2, 3)] * s1) * inv_det;

            result.m[idx(2, 0)] = (a.m[idx(1, 0)] * c4 - a.m[idx(1, 1)] * c2 + a.m[idx(1, 3)] * c0) * inv_det;
            result.m[idx(2, 1)] = (-a.m[idx(0, 0)] * c4 + a.m[idx(0, 1)] * c2 - a.m[idx(0, 3)] * c0) * inv_det;
            result.m[idx(2, 2)] = (a.m[idx(3, 0)] * s4 - a.m[idx(3, 1)] * s2 + a.m[idx(3, 3)] * s0) * inv_det;
            result.m[idx(2, 3)] = (-a.m[idx(2, 0)] * s4 + a.m[idx(2, 1)] * s2 - a.m[idx(2, 3)] * s0) * inv_det;

            result.m[idx(3, 0)] = (-a.m[idx(1, 0)] * c3 + a.m[idx(1, 1)] * c1 - a.m[idx(1, 2)] * c0) * inv_det;
            result.m[idx(3, 1)] = (a.m[idx(0, 0)] * c3 - a.m[idx(0, 1)] * c1 + a.m[idx(0, 2)] * c0) * inv_det;
            result.m[idx(3, 2)] = (-a.m[idx(3, 0)] * s3 + a.m[idx(3, 1)] * s1 - a.m[idx(3, 2)] * s0) * inv_det;
            result.m[idx(3, 3)] = (a.m[idx(2, 0)] * s3 - a.m[idx(2, 1)] * s1 + a.m[idx(2, 2)] * s0) * inv_det;

            return result;
        }

        // ── 4x4 only ──

        pub fn perspective(fov: T, aspect: T, near: T, far: T) Self {
            comptime {
                if (C != 4 or R != 4) @compileError("perspective() requires a 4x4 matrix");
            }
            const tan_half_fov = @tan(fov / 2.0);
            var result = Self{ .m = [_]T{0} ** 16 };

            result.m[idx(0, 0)] = 1.0 / (aspect * tan_half_fov);

            switch (config.graphics_api) {
                .vulkan => {
                    result.m[idx(1, 1)] = -1.0 / tan_half_fov;
                    result.m[idx(2, 2)] = far / (near - far);
                    result.m[idx(2, 3)] = -1.0;
                    result.m[idx(3, 2)] = -(far * near) / (far - near);
                },
                .opengl => {
                    result.m[idx(1, 1)] = 1.0 / tan_half_fov;
                    result.m[idx(2, 2)] = -(far + near) / (far - near);
                    result.m[idx(2, 3)] = -1.0;
                    result.m[idx(3, 2)] = -(2.0 * far * near) / (far - near);
                },
            }

            return result;
        }

        pub fn lookAt(eye: GenVec3(T), target: GenVec3(T), up: GenVec3(T)) Self {
            comptime {
                if (C != 4 or R != 4) @compileError("lookAt() requires a 4x4 matrix");
            }
            const Vec3T = GenVec3(T);
            const f = Vec3T.normalize(Vec3T.sub(target, eye));
            const s = Vec3T.normalize(Vec3T.cross(f, up));
            const u = Vec3T.cross(s, f);

            var result = Self.identity();

            result.m[idx(0, 0)] = s.x;
            result.m[idx(1, 0)] = s.y;
            result.m[idx(2, 0)] = s.z;

            result.m[idx(0, 1)] = u.x;
            result.m[idx(1, 1)] = u.y;
            result.m[idx(2, 1)] = u.z;

            result.m[idx(0, 2)] = -f.x;
            result.m[idx(1, 2)] = -f.y;
            result.m[idx(2, 2)] = -f.z;

            result.m[idx(3, 0)] = -Vec3T.dot(s, eye);
            result.m[idx(3, 1)] = -Vec3T.dot(u, eye);
            result.m[idx(3, 2)] = Vec3T.dot(f, eye);

            return result;
        }
    };
}
