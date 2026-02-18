# zlm

Comptime-generic linear algebra library for Zig. Built for graphics programming — supports Vulkan, OpenGL, GLSL, and HLSL conventions with no hidden defaults.

## Usage

```zig
const zlm = @import("zlm").init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });

const Vec3 = zlm.Vec3(f32);
const Mat4 = zlm.Mat4(f32);

const eye = Vec3.init(0, 0, 5);
const target = Vec3.init(0, 0, 0);
const up = Vec3.init(0, 1, 0);

const view = Mat4.lookAt(eye, target, up);
const proj = Mat4.perspective(std.math.pi / 4.0, 16.0 / 9.0, 0.1, 100.0);
const vp = Mat4.mul(proj, view);
```

### Multiple APIs in one project

If your engine supports both Vulkan and OpenGL via an RHI abstraction, you can use both configs in the same compilation unit:

```zig
const zlm = @import("zlm");
const vk = zlm.init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });
const gl = zlm.init(.{ .graphics_api = .opengl, .shader_lang = .glsl });

// both available in the same file
const proj_vk = vk.Mat4(f32).perspective(fov, aspect, near, far);
const proj_gl = gl.Mat4(f32).perspective(fov, aspect, near, far);
```

### Mixed precision

Scalar type is per-type, so you can mix precisions freely:

```zig
const zlm = @import("zlm").init(.{ .graphics_api = .vulkan, .shader_lang = .glsl });

const pos = zlm.Vec3(f32).init(1, 2, 3);
const view = zlm.Mat4(f64).lookAt(...);
```

## Configuration

### `graphics_api`

Affects projection matrices only.

| | Y direction | Depth range |
|---|---|---|
| `.vulkan` | flipped (clip Y points down) | [0, 1] |
| `.opengl` | standard | [-1, 1] |

`lookAt` is API-agnostic.

### `shader_lang`

Affects Mat4 memory layout.

| | Layout |
|---|---|
| `.glsl` | column-major (`m[col * 4 + row]`) |
| `.hlsl` | row-major (`m[row * 4 + col]`) |

## Types

- **`Vec3(T)`** — 3-component vector: add, sub, scale, dot, length, normalize, cross
- **`Vec4(T)`** — 4-component vector
- **`Mat4(T)`** — 4x4 matrix: identity, mul, perspective, lookAt

## Building

Requires Zig 0.16.0.

```
zig build bench    # run benchmarks
```
