using PeriodicMedia

setup = "2D1D"

if setup == "2D1D"
    k = [10.68, 20.]
    θ = π/4.
    L = 2.0
    P = Problem(k,θ,L; ambdim = 2, geodim = 1)
    Shape = PeriodicMedia.ParametricSurfaces.Kite
    Fig = Obstacle(Shape,L/3)
elseif setup == "3D2D"
    k = [4.5, 8.0]
    θ = [π/4.,π/4.]
    L = [1.0, 1.0]
    P = Problem(k,θ,L; ambdim = 3, geodim = 2)
    Shape = PeriodicMedia.ParametricSurfaces.Sphere
    Fig = Obstacle(Sphere,minimum(L)/3)
end

# Mesh parameters
ppw = 8
dim = 5

# Experiment
windowsizes = 2π/k[1] * collect(10:1:20)
err = Vector{Float64}(undef,0)
for w in windowsizes
    println("Solving with A = "*string(round(w*k[1]/2π,digits=1))*"λ")
    WGF = Window(0.5, w)
    Γs = unitcell(P,Fig, WGF; ppw = ppw, dimorder = dim)
    Γt = extendedcell(P,Fig, WGF; ppw = ppw, dimorder = dim)
    ϕ = solver(P,Γs,Γt,WGF; FRO = false)
    @show eb = energytest(P,Γt,WGF, ϕ; FRO = false, H = 1.0)
    push!(err,eb)
end

import Plots
semilog = Plots.plot(windowsizes, log10.(err); title = "Semilog")
loglog  = Plots.plot(log10.(windowsizes), log10.(err), title = "Log-Log")
Plots.plot(semilog,loglog, legend = false, xlabel = "A/λ", ylabel = "EB", ylims = (-8,0))