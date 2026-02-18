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

Affects matrix memory layout.

| | Layout |
|---|---|
| `.glsl` | column-major (`m[col * rows + row]`) |
| `.hlsl` | row-major (`m[row * cols + col]`) |

## Types

### Vectors

- **`Vec2(T)`** — 2-component vector: add, sub, scale, dot, length, normalize
- **`Vec3(T)`** — 3-component vector: add, sub, scale, dot, length, normalize, cross
- **`Vec4(T)`** — 4-component vector: add, sub, scale, dot, length, normalize

### Matrices

All matrix types support: add, sub, scale, transpose, mul.

| Type | Size | Extra ops |
|---|---|---|
| `Mat2(T)` | 2x2 | identity, trace, determinant, inverse |
| `Mat3(T)` | 3x3 | identity, trace, determinant, inverse |
| `Mat4(T)` | 4x4 | identity, trace, determinant, inverse, perspective, lookAt |
| `Mat2x3(T)` | 2 cols, 3 rows | — |
| `Mat2x4(T)` | 2 cols, 4 rows | — |
| `Mat3x2(T)` | 3 cols, 2 rows | — |
| `Mat3x4(T)` | 3 cols, 4 rows | — |
| `Mat4x2(T)` | 4 cols, 2 rows | — |
| `Mat4x3(T)` | 4 cols, 3 rows | — |

`mul` supports cross-type multiplication — a `Mat3x4` times a `Mat4x2` returns a `Mat3x2` (dimensions checked at comptime).

## Building

Requires Zig 0.16.0.

```
zig build bench    # run benchmarks
```

## Benchmarks

1 billion iterations per test, ReleaseFast, Vulkan/GLSL config.

### Vec2

| Operation | f16 | f32 | f64 | f128 |
|---|---|---|---|---|
| add | 0.57 ns | 0.57 ns | 0.57 ns | 13.86 ns |
| sub | 0.61 ns | 0.57 ns | 0.57 ns | 20.97 ns |
| scale | 0.57 ns | 0.57 ns | 0.57 ns | 15.49 ns |
| dot | 0.57 ns | 0.26 ns | 0.27 ns | 28.26 ns |
| length | 0.57 ns | 0.27 ns | 0.26 ns | 65.86 ns |
| normalize | 0.57 ns | 0.57 ns | 0.57 ns | 121.16 ns |

### Vec3

| Operation | f16 | f32 | f64 | f128 |
|---|---|---|---|---|
| add | 0.57 ns | 0.57 ns | 0.56 ns | 20.46 ns |
| sub | 0.56 ns | 0.57 ns | 0.56 ns | 31.98 ns |
| scale | 0.57 ns | 0.56 ns | 0.57 ns | 23.01 ns |
| dot | 0.56 ns | 0.25 ns | 0.26 ns | 49.75 ns |
| length | 0.57 ns | 0.26 ns | 0.26 ns | 86.60 ns |
| normalize | 0.57 ns | 0.57 ns | 0.56 ns | 148.16 ns |
| cross | 0.57 ns | 0.56 ns | 0.57 ns | 88.57 ns |

### Vec4

| Operation | f16 | f32 | f64 | f128 |
|---|---|---|---|---|
| add | 0.57 ns | 0.56 ns | 0.63 ns | 27.11 ns |
| sub | 0.57 ns | 0.57 ns | 0.63 ns | 41.04 ns |
| scale | 0.56 ns | 0.56 ns | 0.64 ns | 30.30 ns |
| dot | 0.57 ns | 0.26 ns | 0.26 ns | 68.53 ns |
| length | 0.57 ns | 0.27 ns | 0.26 ns | 106.64 ns |
| normalize | 0.57 ns | 0.57 ns | 0.63 ns | 175.96 ns |

### Mat2

| Operation | f16 | f32 | f64 | f128 |
|---|---|---|---|---|
| mul | 0.57 ns | 0.56 ns | 0.63 ns | 88.92 ns |
| determinant | 0.56 ns | 0.26 ns | 0.25 ns | 18.34 ns |
| inverse | 0.57 ns | 0.57 ns | 0.63 ns | 74.11 ns |

### Mat3

| Operation | f16 | f32 | f64 | f128 |
|---|---|---|---|---|
| mul | 0.63 ns | 0.63 ns | 1.14 ns | 301.40 ns |
| determinant | 0.57 ns | 0.27 ns | 0.27 ns | 83.71 ns |
| inverse | 0.63 ns | 0.64 ns | 1.14 ns | 319.04 ns |

### Mat4

| Operation | f64 |
|---|---|
| mul | 1.51 ns |
| perspective | 1.52 ns |
| lookAt | 1.33 ns |
