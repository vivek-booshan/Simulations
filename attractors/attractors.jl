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

Base.@kwdef mutable struct FourWing
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 4
    β::Float64 = 6
    ς::Float64 = 10
    δ::Float64 = 5
    κ::Float64 = 1
end

Base.@kwdef mutable struct GenesioTesi
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.44
    β::Float64 = 1.1
    δ::Float64 = 1
end

Base.@kwdef mutable struct Hadley
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.2
    β::Float64 = 4
    ζ::Float64 = 8
    δ::Float64 = 1
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

Base.@kwdef mutable struct LorenzMod1
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.1
    β::Float64 = 4
    ζ::Float64 = 14
    δ::Float64 = 0.08
end

Base.@kwdef mutable struct LorenzMod2
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.9
    β::Float64 = 5
    ζ::Float64 = 9.9
    δ::Float64 = 1
end

Base.@kwdef mutable struct NoseHoover
    #(-5, 5, -7, 5, -5, 5)
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 1.5
end

Base.@kwdef mutable struct QiChen
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 38
    β::Float64 = 8/3
    ς::Float64 = 80
end

Base.@kwdef mutable struct RayleighBenard
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 9
    r::Float64 = 12
    β::Float64 = 5
end

Base.@kwdef mutable struct Rossler
    #(-10, 15, -20, 0, 0, 30)
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.2
    β::Float64 = 0.2
    ζ::Float64 = 5.7
end

Base.@kwdef mutable struct Thomas
    dt::Float64 = 0.01

    x::Float64 = 0.1
    y::Float64 = 0.1
    z::Float64 = 0.1

    β::Float64 = 0.19
end

Base.@kwdef mutable struct WangSun
    dt::Float64 = 0.01

    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1

    α::Float64 = 0.2
    β::Float64 = -0.01
    ς::Float64 = 1
    δ::Float64 = -0.4
    ε::Float64 = -1
    ζ::Float64 = -1
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

function step!(f::FourWing)
    dx = f.α*f.x - f.β*f.y*f.z
    dy = -f.ς*f.y + f.x*f.z
    dz = f.κ*f.x -f.δ*f.z + f.x*f.z

    f.x += f.dt * dx
    f.y += f.dt * dy
    f.z += f.dt * dz

    Point3f(f.x, f.y, f.z)
end

function step!(gt::GenesioTesi)
    dx = gt.y
    dy = gt.z
    dz = -gt.δ*gt.x - gt.β*gt.y - gt.α*gt.z + gt.x^2

    gt.x += gt.dt * dx
    gt.y += gt.dt * dy
    gt.z += gt.dt * dz

    Point3f(gt.x, gt.y, gt.z)
end

function step!(h::Hadley)
    dx = -h.y^2 - h.z^2 - h.α*h.x + h.α*h.ζ
    dy = h.x*h.y - h.β*h.x*h.z - h.y + h.δ
    dz = h.β*h.x*h.y + h.x*h.z - h.z

    h.x += h.dt * dx
    h.y += h.dt * dy
    h.z += h.dt * dz

    Point3f(h.x, h.y, h.z)
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

function step!(l::LorenzMod1)
    dx = -l.α*l.x + l.y^2 - l.z^2 + l.α*l.ζ
    dy = l.x*(l.y - l.β*l.z) + l.δ
    dz = l.z + l.x*(l.β*l.y + l.z)

    l.x += l.dt * dx
    l.y += l.dt * dy
    l.z += l.dt * dz

    Point3f(l.x, l.y, l.z)
end

function step!(l::LorenzMod2)
    dx = -l.α*l.x + l.y^2 - l.z^2 + l.α*l.ζ
    dy = l.x*(l.y - l.β*l.z) + l.δ
    dz = -l.z + l.x*(l.β*l.y + l.z)

    l.x += l.dt * dx
    l.y += l.dt * dy
    l.z += l.dt * dz

    Point3f(l.x, l.y, l.z)
end

function step!(nh::NoseHoover)
    dx = nh.y 
    dy = -nh.x + nh.y * nh.z
    dz = nh.α - nh.y^2

    nh.x += nh.dt * dx
    nh.y += nh.dt * dy
    nh.z += nh.dt * dz

    Point3f(nh.x, nh.y, nh.z)
end

function step!(qc::QiChen)
    dx = qc.α*(qc.y - qc.x) + qc.y*qc.z
    dy = qc.ς*qc.x + qc.y - qc.x*qc.z
    dz =  qc.x*qc.y - qc.β*qc.z

    qc.x += qc.dt * dx
    qc.y += qc.dt * dy
    qc.y += qc.dt * dz

    Point3f(qc.x, qc.y, qc.z)
end

function step!(rb::RayleighBenard)
    dx = -rb.α*rb.x + rb.α*rb.y
    dy = rb.r*rb.x - rb.y - rb.x*rb.z
    dz = rb.x*rb.y - rb.β*rb.z

    rb.x += rb.dt * dx
    rb.y += rb.dt * dy
    rb.z += rb.dt * dz

    Point3f(rb.x, rb.y, rb.z)
end

function step!(r::Rossler)
    dx = -(r.y + r.z)
    dy = r.x + r.α*r.y
    dz = r.β + r.z * (r.x - r.ζ)
    
    r.x += r.dt * dx
    r.y += r.dt * dy
    r.z += r.dt * dz
    
    Point3f(r.x, r.y, r.z)
end

function step!(t::Thomas)
    dx = sin(t.y) + t.β*t.x
    dy = sin(t.z) - t.β*t.y
    dz = sin(t.x) - t.β*t.z

    t.x += t.dt * dx
    t.y += t.dt * dy
    t.z += t.dt * dz

    Point3f(t.x, t.y, t.z)
end

function step!(ws::WangSun)
    #(-1, 1, -1, 1, -1, 1)
    dx = ws.x*ws.α + ws.ς * ws.y * ws.z
    dy = ws.x * ws.β + ws.δ * ws.y - ws.x * ws.z
    dz = ws.ε*ws.z + ws.ζ * ws.x * ws.y

    ws.x += ws.dt * dx
    ws.y += ws.dt * dy
    ws.z += ws.dt * dz

    Point3f(ws.x, ws.y, ws.z)
end
