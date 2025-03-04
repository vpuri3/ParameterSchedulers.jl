module ParameterSchedulers

using Base.Iterators
using Flux
using InfiniteArrays: OneToInf

include("interface.jl")

include("decay.jl")
export Step, Exp, Poly, Inv

include("cyclic.jl")
export Triangle, TriangleDecay2, TriangleExp,
       Sin, SinDecay2, SinExp,
       CosAnneal

include("complex.jl")
export Sequence, Loop, Interpolator, Shifted, ComposedSchedule

include("utils.jl")

# TODO
# Remove this once Optimisers.jl has support
# for schedules + optimizers
"""
    Scheduler{T, O, F}(schedule::AbstractSchedule, opt, update_func)
    Scheduler(schedule, opt; update_func = (o, s) -> (o.eta = s))

Wrap a `schedule` and `opt` together with a `Scheduler`.
The `schedule` is iterated on every call to
[`Flux.apply!`](https://github.com/FluxML/Flux.jl/blob/master/src/optimise/optimisers.jl).
The `Scheduler` can be used anywhere a Flux optimizer is used.

By default, the learning rate (i.e. `opt.eta`) is scheduled.
Set `update_func = (opt, schedule_val) -> ...` to schedule an alternate field.
If `opt` does not have a field `eta`, then there is no default behavior
(you must manually set `update_func`).

# Arguments
- `schedule`: the schedule to use
- `opt`: a Flux optimizer
- `update_func`: a mutating function of with inputs `(optim, param)`
                 that mutates `optim`'s fields based on the current `param` value

# Examples
```julia
# cosine annealing schedule for Descent
julia> s = CosAnneal(λ0 = 0.1, λ1 = 0.8, period = 10);

julia> opt = Scheduler(s, Descent())
Scheduler(CosAnneal{Float64,Int64}(0.1, 0.8, 10), Descent(0.1))

# schedule the momentum term of Momentum
julia> opt = Scheduler(s, Momentum(); update_func = (o, s) -> o.rho = s)
Scheduler(CosAnneal{Float64,Int64}(0.1, 0.8, 10), Momentum(0.01, 0.9, IdDict{Any,Any}()))
```
"""
mutable struct Scheduler{T, O, F} <: Flux.Optimise.AbstractOptimiser
    state::IdDict{Any, Int}
    schedule::T
    optim::O
    update_func::F

    function Scheduler(state::IdDict{Any, Int},
                       schedule::T,
                       optim::O,
                       update_func::F) where {T, O, F}
        Base.depwarn("""`Scheduler` will transition to explicit Optimisers.jl style
                        optimizers in the next release""", :Scheduler)

        return new{T, O, F}(state, schedule, optim, update_func)
    end
end
Scheduler(schedule, opt, update_func) =
    Scheduler(IdDict{Any, Int}(), schedule, opt, update_func)

Base.show(io::IO, s::Scheduler) =
    print(io, "Scheduler(", s.schedule, ", ", s.optim, ")")

function Flux.Optimise.apply!(opt::Scheduler, x, Δ)
    # get iteration
    t = get!(opt.state, x, 1)
    opt.state[x] = t + 1

    # set param
    opt.update_func(opt.optim, opt.schedule(t))

    # do normal apply
    return Flux.Optimise.apply!(opt.optim, x, Δ)
end

for Opt in (Descent, Momentum, Nesterov, RMSProp,
            Adam, RAdam, AdaMax, OAdam, AdaGrad,
            AdaDelta, AMSGrad, NAdam, AdaBelief)
    @eval begin
        Scheduler(schedule, opt::$Opt; update_func = (o, s) -> (o.eta = s)) =
            Scheduler(schedule, opt, update_func)
    end
end

end