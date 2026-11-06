--!strict
--!optimize 2
--!native

--[[
	Copyright 2026 MingauRM / lu401940

	Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
	and associated documentation files (the “Software”), to deal in the Software without restriction, 
	including without limitation the rights to use, copy, modify, merge, publish, distribute, 
	sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all copies 
	or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
	THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
	OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

---------- | UTILS | ----------

local function frac(x: number): number
	return x - math.floor(x)
end

local function step(edge: number, x: number): number
	return x < edge and 0.0 or 1.0
end

local function hash2D(p: vector, SEED: number): vector
	local h = vector.create(p.x + SEED, p.y + SEED)

	local dot1 = vector.dot(h, vector.create(127.1, 311.7))
	local dot2 = vector.dot(h, vector.create(269.5, 183.3))

	local v = vector.create(dot1, dot2)
	local finalV = vector.create(
		-1.0 + 2.0 * frac(math.sin(v.x) * 43758.5453123),
		-1.0 + 2.0 * frac(math.sin(v.y) * 43758.5453123)
	)

	return finalV
end

local function hash3D(p: vector, SEED: number): vector
	local dot1 = vector.dot(vector.create(p.x + SEED, p.y + SEED, p.z + SEED), vector.create(127.1, 311.7, 74.7))
	local dot2 = vector.dot(vector.create(p.x + SEED, p.y + SEED, p.z + SEED), vector.create(269.5, 183.3, 246.1))
	local dot3 = vector.dot(vector.create(p.x + SEED, p.y + SEED, p.z + SEED), vector.create(113.5, 271.9, 124.3))

	return vector.create(
		-1.0 + 2.0 * frac(math.sin(dot1) * 43758.5453123),
		-1.0 + 2.0 * frac(math.sin(dot2) * 43758.5453123),
		-1.0 + 2.0 * frac(math.sin(dot3) * 43758.5453123)
	)
end

---------- | 2D | ----------

local function perlin2d(obj: NoiseObject, x: number, y: number): number
	const SEED = obj.Seed

	local i = vector.create(math.floor(x), math.floor(y))

	local f = vector.create(frac(x), frac(y))

	local u = vector.create(
		f.x * f.x * f.x * (f.x * (f.x * 6.0 - 15.0) + 10),
		f.y * f.y * f.y * (f.y * (f.y * 6.0 - 15.0) + 10)
	)

	local h00 = hash2D(i, SEED)
	local h10 = hash2D(i + vector.create(1.0, 0.0), SEED)
	local h01 = hash2D(i + vector.create(0.0, 1.0), SEED)
	local h11 = hash2D(i + vector.create(1.0, 1.0), SEED)

	local gradTopLeft = vector.dot(h00, f)
	local gradTopRight = vector.dot(h10, f - vector.create(1.0, 0.0))
	local gradBottomLeft = vector.dot(h01, f - vector.create(0.0, 1.0))
	local gradBottomRight = vector.dot(h11, f - vector.create(1.0, 1.0))

	local result =
		math.lerp(
			math.lerp(gradTopLeft, gradTopRight, u.x),
			math.lerp(gradBottomLeft, gradBottomRight, u.y),
			u.y
		)

	return result
end

local function simplex2d(obj: NoiseObject, x: number, y: number): number
	const SEED = obj.Seed

	const F2 = 0.366025403
	const G2 = 0.211324865

	local i = vector.create(math.floor(x + (x + y) * F2), math.floor(y + (x + y) * F2))

	local x0 = vector.create(x - i.x + (i.x + i.y) * G2, y - i.y + (i.x + i.y) * G2)

	local i1 = x0.x > x0.y and vector.create(1.0, 0.0) or vector.create(0.0, 1.0)

	local x1 = vector.create(x0.x - i1.x + G2, x0.y - i1.y + G2)

	local x2 = vector.create(x0.x - 1.0 + 2.0 * G2, x0.y - 1.0 + 2.0 * G2)

	local t0 = 0.5 - vector.dot(x0, x0)
	local n0 = 0.0
	if t0 >= 0.0 then
		t0 *= t0
		n0 = t0 * t0 * vector.dot(hash2D(i, SEED), x0)
	end

	local t1 = 0.5 - vector.dot(x1, x1)
	local n1 = 0.0
	if t1 >= 0.0 then
		t1 *= t1
		n1 = t1 * t1 * vector.dot(hash2D(i + i1, SEED), x1)
	end

	local t2 = 0.5 - vector.dot(x2, x2)
	local n2 = 0.0
	if t2 >= 0.0 then
		t2 *= t2
		n2 = t2 * t2 * vector.dot(hash2D(vector.create(i.x + 1.0, i.y + 1.0), SEED), x2)
	end

	return 70.0 * (n0 + n1 + n2)
end

local function voronoi2d(obj: NoiseObject, x: number, y: number): number
	const SEED = obj.Seed

	local iv = vector.create(math.floor(x), math.floor(y))

	local f = vector.create(frac(x), frac(y))

	local minDist = 8.0

	for i = -1, 1 do
		for j = -1, 1 do
			local p = hash2D(iv + vector.create(j, i), SEED)

			local r = vector.create(j + p.x - f.x, i + p.y - f.y)
			local dot = vector.dot(r, r)

			if dot < minDist then
				minDist = dot
			end
		end
	end

	return math.sqrt(minDist)
end

local function value2d(obj: NoiseObject, x: number, y: number): number
	const SEED = obj.Seed
	local function hash1D(p: vector): number
		local dot = vector.dot(vector.create(p.x + SEED, p.y + SEED), vector.create(127.1, 311.7))

		return frac(math.sin(dot) * 43758.5453123)
	end

	local i = vector.create(math.floor(x), math.floor(y))

	local f = vector.create(frac(x), frac(y))

	local a = hash1D(i, SEED)
	local b = hash1D(vector.create(i.x + 1.0, i.y), SEED)
	local c = hash1D(vector.create(i.x, i.y + 1.0), SEED)
	local d = hash1D(vector.create(i.x + 1.0, i.y + 1.0), SEED)

	local u = vector.create(f.x * f.x * (3.0 - 2.0 * f.x), f.y * f.y * (3.0 - 2.0 * f.y))

	return math.lerp(
		math.lerp(a, b, u.x),
		math.lerp(c, d, u.x),
		u.y
	)
end

---------- | 3D | ----------

local function perlin3d(obj: NoiseObject, x: number, y: number, z: number): number
	const SEED = obj.Seed

	local i = vector.create(math.floor(x), math.floor(y), math.floor(z))

	local f = vector.create(frac(x), frac(y), frac(z))

	local u = vector.create(
		f.x * f.x * f.x * (f.x * (f.x * 6.0 - 15.0) + 10.0),
		f.y * f.y * f.y * (f.y * (f.y * 6.0 - 15.0) + 10.0),
		f.z * f.z * f.z * (f.z * (f.z * 6.0 - 15.0) + 10.0)
	)

	local h000 = hash3D(i, SEED)
	local h100 = hash3D(i + vector.create(1.0, 0.0, 0.0), SEED)
	local h010 = hash3D(i + vector.create(0.0, 1.0, 0.0), SEED)
	local h110 = hash3D(i + vector.create(1.0, 1.0, 0.0), SEED)

	local h001 = hash3D(i + vector.create(0.0, 0.0, 1.0), SEED)
	local h101 = hash3D(i + vector.create(1.0, 0.0, 1.0), SEED)
	local h011 = hash3D(i + vector.create(0.0, 1.0, 1.0), SEED)
	local h111 = hash3D(i + vector.create(1.0, 1.0, 1.0), SEED)

	local n000 = vector.dot(h000, f)
	local n100 = vector.dot(h100, f - vector.create(1.0, 0.0, 0.0))
	local n010 = vector.dot(h010, f - vector.create(0.0, 1.0, 0.0))
	local n110 = vector.dot(h110, f - vector.create(1.0, 1.0, 0.0))

	local n001 = vector.dot(h001, f - vector.create(0.0, 0.0, 1.0))
	local n101 = vector.dot(h101, f - vector.create(1.0, 0.0, 1.0))
	local n011 = vector.dot(h011, f - vector.create(0.0, 1.0, 1.0))
	local n111 = vector.dot(h111, f - vector.create(1.0, 1.0, 1.0))

	local nx00 = math.lerp(n000, n100, u.x)
	local nx10 = math.lerp(n010, n110, u.x)
	local nx01 = math.lerp(n001, n101, u.x)
	local nx11 = math.lerp(n011, n111, u.x)

	local nxy0 = math.lerp(nx00, nx10, u.y)
	local nxy1 = math.lerp(nx01, nx11, u.y)

	return math.lerp(nxy0, nxy1, u.z)
end

local function simplex3d(obj: NoiseObject, x: number, y: number, z: number): number
	const SEED = obj.Seed

	const F3 = 0.333333333
	const G3 = 0.166666666

	local i = vector.create(
		math.floor(x + (x + y + z) * F3),
		math.floor(y + (x + y + z) * F3),
		math.floor(z + (x + y + z) * F3)
	)

	local x0 = vector.create(
		x - i.x + (i.x + i.y + i.z) * G3,
		y - i.y + (i.x + i.y + i.z) * G3,
		z - i.z + (i.x + i.y + i.z) * G3
	)

	local g = vector.create(step(x0.y, x0.x), step(x0.z, x0.y), step(x0.x, x0.z))

	local l = vector.create(1.0 - g.x, 1.0 - g.y, 1.0 - g.z)

	local i1 = vector.create(math.min(g.x, l.z), math.min(g.y, l.x), math.min(g.z, l.y))

	local i2 = vector.create(math.max(g.x, l.z), math.max(g.y, l.x), math.max(g.z, l.y))

	local x1 = vector.create(x0.x - i1.x + G3, x0.y - i1.y + G3, x0.z - i1.z + G3)

	local x2 = vector.create(x0.x - i2.x + 2.0 * G3, x0.y - i2.y + 2.0 * G3, x0.z - i2.z + 2.0 * G3)

	local x3 = vector.create(x0.x - 1.0 + 3.0 * G3, x0.y - 1.0 + 3.0 * G3, x0.z - 1.0 + 3.0 * G3)

	local h0 = hash3D(i, SEED)
	local h1 = hash3D(vector.create(i.x + i1.x, i.y + i1.y, i.z + i1.z), SEED)
	local h2 = hash3D(vector.create(i.x + i2.x, i.y + i2.y, i.z + i2.z), SEED)
	local h3 = hash3D(vector.create(i.x + 1.0, i.y + 1.0, i.z + 1.0), SEED)

	local t0 = 0.6 - vector.dot(x0, x0)
	local nX = t0 < 0.0 and 0.0 or (t0 * t0 * t0 * t0) * vector.dot(h0, x0)

	local t1 = 0.6 - vector.dot(x1, x1)
	local nY = t1 < 0.0 and 0.0 or (t1 * t1 * t1 * t1) * vector.dot(h1, x1)

	local t2 = 0.6 - vector.dot(x2, x2)
	local nZ = t2 < 0.0 and 0.0 or (t2 * t2 * t2 * t2) * vector.dot(h2, x2)

	local t3 = 0.6 - vector.dot(x3, x3)
	local nW = t3 < 0.0 and 0.0 or (t3 * t3 * t3 * t3) * vector.dot(h3, x3)

	return 32 * (nX + nY + nZ + nW)
end

local function voronoi3d(obj: NoiseObject, x: number, y: number, z: number): number
	const SEED = obj.Seed

	local iv = vector.create(math.floor(x), math.floor(y), math.floor(z))

	local f = vector.create(frac(x), frac(y), frac(z))

	local minDist = 8.0

	for i = -1, 1 do
		for j = -1, 1 do
			for k = -1, 1 do
				local p = hash3D(vector.create(iv.x + k, iv.y + j, iv.z + i), SEED)

				local r = vector.create(k + p.x - f.x, j + p.y - f.y, i + p.z - f.z)

				local dot = vector.dot(r, r)

				if dot < minDist then
					minDist = dot
				end
			end
		end
	end

	return math.sqrt(minDist)
end

local function value3d(obj: NoiseObject, x: number, y: number, z: number): number
	const SEED = obj.Seed
	local function hash1D(p: vector): number
		local dot = vector.dot(vector.create(p.x + SEED, p.y + SEED, p.z + SEED), vector.create(127.1, 311.7, 74.7))

		return frac(math.sin(dot) * 43758.5453123)
	end

	local i = vector.create(math.floor(x), math.floor(y), math.floor(z))

	local f = vector.create(frac(x), frac(y), frac(z))

	local u = vector.create(f.x * f.x * (3.0 - 2.0 * f.x), f.y * f.y * (3.0 - 2.0 * f.y), f.z * f.z * (3.0 - 2.0 * f.z))

	local a = hash1D(i, SEED)
	local b = hash1D(vector.create(i.x + 1.0, i.y, i.z), SEED)
	local c = hash1D(vector.create(i.x, i.y + 1.0, i.z), SEED)
	local d = hash1D(vector.create(i.x + 1.0, i.y + 1.0, i.z), SEED)

	local e = hash1D(vector.create(i.x, i.y, i.z + 1.0), SEED)
	local f = hash1D(vector.create(i.x + 1.0, i.y, i.z + 1.0), SEED)
	local g = hash1D(vector.create(i.x, i.y + 1.0, i.z + 1.0), SEED)
	local h = hash1D(vector.create(i.x + 1.0, i.y + 1.0, i.z + 1.0), SEED)

	return math.lerp(
		math.lerp(math.lerp(a, b, u.x), math.lerp(c, d, u.x), u.y),
		math.lerp(math.lerp(e, f, u.x), math.lerp(g, h, u.x), u.y),
		u.z
	)
end

---------- | CLASS | ----------

local Fnl = {}
local NoiseMethods = {}
NoiseMethods.__index = NoiseMethods

function Fnl.new(seed: number?): NoiseObject
	seed = seed or 0

	local self = setmetatable({}, NoiseMethods)

	self.Seed = seed
	self.Frequency = 0.02
	self.Octaves = 1
	self.Gain = 0.6
	self.Lacunarity = 2.0

	return self :: NoiseObject
end

---------- | METHODS | ----------

function NoiseMethods.Perlin(self: NoiseObject, x: number, y: number, z: number?): number
	local total = 0
	local freq = self.Frequency
	local ampl = 1.0
	local totalAmpl = 0.0

	const LACUNARITY = self.Lacunarity
	const GAIN = self.Gain
	const OCTAVES = self.Octaves

	for i = 1, OCTAVES do
		if z then
			total += perlin3d(self, x * freq, y * freq, z * freq) * ampl
		else
			total += perlin2d(self, x * freq, y * freq) * ampl
		end

		totalAmpl += ampl

		ampl *= GAIN
		freq *= LACUNARITY
	end

	return math.map(total / totalAmpl, -1, 1, 0, 1)
end

function NoiseMethods.Simplex(self: NoiseObject, x: number, y: number, z: number?): number
	local total = 0
	local freq = self.Frequency
	local ampl = 1.0
	local totalAmpl = 0.0

	const LACUNARITY = self.Lacunarity
	const GAIN = self.Gain
	const OCTAVES = self.Octaves

	for i = 1, OCTAVES do
		if z then
			total += simplex3d(self, x * freq, y * freq, z * freq) * ampl
		else
			total += simplex2d(self, x * freq, y * freq) * ampl
		end

		totalAmpl += ampl

		ampl *= GAIN
		freq *= LACUNARITY
	end

	return math.map(total / totalAmpl, -1, 1, 0, 1)
end

function NoiseMethods.Voronoi(self: NoiseObject, x: number, y: number, z: number?): number
	local total = 0
	local freq = self.Frequency
	local ampl = 1.0
	local totalAmpl = 0.0

	const LACUNARITY = self.Lacunarity
	const GAIN = self.Gain
	const OCTAVES = self.Octaves

	for i = 1, OCTAVES do
		if z then
			total += voronoi3d(self, x * freq, y * freq, z * freq) * ampl
		else
			total += voronoi2d(self, x * freq, y * freq) * ampl
		end

		totalAmpl += ampl

		ampl *= GAIN
		freq *= LACUNARITY
	end

	return math.clamp(total / totalAmpl, 0, 1)
end

function NoiseMethods.Value(self: NoiseObject, x: number, y: number, z: number?): number
	local total = 0
	local freq = self.Frequency
	local ampl = 1.0
	local totalAmpl = 0.0

	const LACUNARITY = self.Lacunarity
	const GAIN = self.Gain
	const OCTAVES = self.Octaves

	for i = 1, OCTAVES do
		if z then
			total += value3d(self, x * freq, y * freq, z * freq) * ampl
		else
			total += value2d(self, x * freq, y * freq) * ampl
		end

		totalAmpl += ampl

		ampl *= GAIN
		freq *= LACUNARITY
	end

	return total / totalAmpl
end

---------- | TYPES | ----------

type FastNoiseLight = typeof(Fnl)
type NoiseObject = {
	Seed: number,
	Frequency: number,
	Octaves: number,
	Gain: number,
	Lacunarity: number,
} & {
	Perlin: ((self: NoiseObject, x: number, y: number) -> number)
	& ((self: NoiseObject, x: number, y: number, z: number) -> number),
	Simplex: ((self: NoiseObject, x: number, y: number) -> number)
	& ((self: NoiseObject, x: number, y: number, z: number) -> number),
	Voronoi: ((self: NoiseObject, x: number, y: number) -> number)
	& ((self: NoiseObject, x: number, y: number, z: number) -> number),
	Value: ((self: NoiseObject, x: number, y: number) -> number)
	& ((self: NoiseObject, x: number, y: number, z: number) -> number),
}

---------- | END | ----------

return Fnl :: FastNoiseLight
