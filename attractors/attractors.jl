using GLMakie

Base.@kwdef mutable struct Aizawa
	dt::Float64 = 0.01
	
	x::Float64 = 1
	y::Float64 = 1
	z::Float64 = 1

	ε::Float64 = 0.25
	α::Float64 = 0.95
	γ::Float64 = 0.6
	δ::Float64 = 3.5
	β::Float64 = 0.7
	ζ::Float64 = 0.1
end

Base.@kwdef mutable struct ChenLee
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 5
    β::Float64 = -10
    δ::Float64 = -0.38
end

Base.@kwdef mutable struct Chua
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 15.6
    β::Float64 = 1
    ζ::Float64 = 25.58
    δ::Float64 = -1
    ε::Float64 = 0
end

Base.@kwdef mutable struct Halvorsen
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 1.4
end

Base.@kwdef mutable struct Lorenz
	dt::Float64 = 0.01
	
	x::Float64 = 1
	y::Float64 = 1
	z::Float64 = 1
	
	σ::Float64 = 10
	ρ::Float64 = 28
	β::Float64 = 8/3
end

Base.@kwdef mutable struct Rossler
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.2
    β::Float64 = 0.2
    ζ::Float64 = 5.7
end

function step!(a::Aizawa)
	dx = (a.z - a.β) * a.x - a.δ * a.y
	dy = a.δ * a.x + (a.z - a.β) * a.y
	dz = a.γ + a.α * a.z - (a.z^3)/3 - (a.x^2 + a.y^2)*(1 + a.ε * a.z) + a.ζ * a.z * a.x^3

	a.x += a.dt * dx
	a.y += a.dt * dy
	a.z += a.dt * dz

	Point3f(a.x, a.y, a.z)
end

function step!(cl::ChenLee)
    dx = cl.α * cl.x - cl.y * cl.z
    dy = cl.β * cl.y + cl.x * cl.z
    dz = cl.δ * cl.x * (cl.y / 3)

    cl.x += cl.dt * dx
    cl.y += cl.dt * dy
    cl.z += cl.dt * dz
    
    Point3f(cl.x, cl.y, cl.z)
end

function step!(c::Chua)
    G = c.ε*c.x + (c.δ + c.ε)*(abs(c.x+1) - abs(c.x-1))
    dx = c.α * (c.y - c.x - G)
    dy = c.β * (c.x - c.y + c.z)
    dz = -c.ζ * c.y

    c.x += c.dt * dx
    c.y += c.dt * dy
    c.z += c.dt * dz

    Point3f(c.x, c.y, c.z)
end

function step!(h::Halvorsen)
    dx = -h.α * h.x - 4*h.y - 4*h.z - h.y^2
    dy = -h.α * h.y - 4*h.z - 4*h.x - h.z^2
    dz = -h.α * h.z - 48h.x - 4*h.y - h.x^2

    h.x += h.dt * dx
    h.y += h.dt * dy
    h.z += h.dt * dz

    Point3f(h.x, h.y, h.z)
end

function step!(l::Lorenz)
	dx = l.σ * (l.y - l.x)
	dy = l.x * (l.ρ - l.z) - l.y 
	dz = l.x * l.y - l.β * l.z
	
	l.x += l.dt * dx
	l.y += l.dt * dy
    l.z += l.dt * dz
	
    Point3f(l.x, l.y, l.z)
end

function step!(r::Rossler)
    dx = -(r.y + r.z)
    dy = r.x + r.α*r.y
    dz = β + r.z * (r.x - r.ζ)
    
    r.x += r.dt * dx
    r.y += r.dt * dy
    r.z += r.dt * dz
    
    Point3f(r.x, r.y, r.z)
end