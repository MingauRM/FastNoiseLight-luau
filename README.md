# FastNoiseLight Luau

A noise generation module for Luau that is inspired by [FastNoiseLite](https://github.com/Auburn/FastNoiseLite).

## Features

This module is very simple, it has 4 main noise implementations. Those being:
- Perlin noise;
- Simplex noise;
- Voronoi noise;
- Value noise.

All of them have their 2D and 3D variants. The internal implementation uses Luau's built-in vector type for extreme speed.

## Usage

FastNoiseLight is simple to use, with a OOP architecture and descriptive function calls.

```luau
local FastNoiseLight = require(path.to.module)

local seed = 5
local Noise = FastNoiseLight.new(seed) -- Seed parameter is optional. Defaults to 0.

-- All values can be set like that. Those are the default values. (Noise.Seed also can be accessed.)

Noise.Frequency = 0.02
Noise.Lacunarity = 12
Noise.Octaves = 1
Noise.Gain = 0.6

print(Noise:Simplex(10, 3) -- Supports an z component for 3D sampling.
```

## API

```luau
Noise:Perlin(x: number, y: number): number
```
*Samples a 2D Perlin noise value in the specified x and y coordinates.*

```luau
Noise:Perlin(x: number, y: number, z: number): number
```
*Samples a 3D Perlin noise value in the specified x, y and z coordinates.*

---

```luau
Noise:Simplex(x: number, y: number): number
```
*Samples a 2D Simplex noise value in the specified x and y coordinates.*

```luau
Noise:Simplex(x: number, y: number, z: number): number
```
*Samples a 3D Simplex noise value in the specified x, y and z coordinates.*

---

```luau
Noise:Voronoi(x: number, y: number): number
```
*Samples a 2D Voronoi noise value in the specified x and y coordinates.*

```luau
Noise:Voronoi(x: number, y: number, z: number): number
```
*Samples a 3D Voronoi noise value in the specified x, y and z coordinates.*

---

```luau
Noise:Value(x: number, y: number): number
```
*Samples a 2D Value noise value in the specified x and y coordinates.*

```luau
Noise:Value(x: number, y: number, z: number): number
```
*Samples a 3D Value noise value in the specified x, y and z coordinates.*

---

```luau
Noise.Seed
```
*The object's seed.*

```luau
Noise.Frequency
```
*The object's frequency.*

```luau
Noise.Lacunarity
```
*The object's lacunarity.*

```luau
Noise.Gain
```
*The object's Gain.*

```luau
Noise.Octaves
```
*The object's Octave count.*

---

**Obs.: All noise properties are Read and Write.**
