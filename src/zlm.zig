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
        pub fn Mat4(comptime T: type) type {
            return GenMat4(T, config);
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

fn GenMat4(comptime T: type, comptime config: Config) type {
    return struct {
        const Self = @This();
        const Vec3T = GenVec3(T);

        m: [16]T,

        inline fn idx(col: usize, row: usize) usize {
            return switch (config.shader_lang) {
                .glsl => col * 4 + row,
                .hlsl => row * 4 + col,
            };
        }

        pub fn identity() Self {
            var result = Self{ .m = [_]T{0} ** 16 };
            result.m[idx(0, 0)] = 1;
            result.m[idx(1, 1)] = 1;
            result.m[idx(2, 2)] = 1;
            result.m[idx(3, 3)] = 1;
            return result;
        }

        pub fn mul(a: Self, b: Self) Self {
            var result: Self = undefined;
            var i: usize = 0;
            while (i < 4) : (i += 1) {
                var j: usize = 0;
                while (j < 4) : (j += 1) {
                    var sum: T = 0;
                    var k: usize = 0;
                    while (k < 4) : (k += 1) {
                        sum += a.m[idx(k, j)] * b.m[idx(i, k)];
                    }
                    result.m[idx(i, j)] = sum;
                }
            }
            return result;
        }

        pub fn perspective(fov: T, aspect: T, near: T, far: T) Self {
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

        pub fn lookAt(eye: Vec3T, target: Vec3T, up: Vec3T) Self {
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
