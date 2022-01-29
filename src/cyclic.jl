_tri(t, period) = (2 / π) * abs(asin(sin(π * (t - 1) / period)))
_sin(t, period) = abs(sin(π * (t - 1) / period))
_cycle(λ0, λ1, g) = abs(λ0 - λ1) * g + min(λ0, λ1)

"""
    Triangle{T, S<:Integer}(range0, range1, period)
    Triangle(;λ0, λ1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period`.
The output conforms to
```text
abs(λ0 - λ1) * (2 / π) * abs(asin(sin(π * (t - 1) / period))) + min(λ0, λ1)
```

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct Triangle{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
end
Triangle(;λ0, λ1, period) = Triangle(λ0, λ1, period)

Base.eltype(::Type{<:Triangle{T}}) where T = T

(schedule::Triangle)(t) = _cycle(schedule.range0, schedule.range1, _tri(t, schedule.period))

"""
    TriangleDecay2{T, S<:Integer}(range0, range1, period)
    TriangleDecay2(;λ0, λ1, period)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and half the amplitude each cycle.
The output conforms to
```text
abs(λ0 - λ1) * Triangle(t) / (2^floor((t - 1) / period)) + min(λ0, λ1)
```
where `Triangle(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))` (see [`Triangle`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct TriangleDecay2{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
end
TriangleDecay2(;λ0, λ1, period) = TriangleDecay2(λ0, λ1, period)

Base.eltype(::Type{<:TriangleDecay2{T}}) where T = T

(schedule::TriangleDecay2)(t) = _cycle(schedule.range0, schedule.range1,
                                       _tri(t, schedule.period) / (2^fld(t - 1, schedule.period)))

"""
    TriangleExp{T, S<:Integer}(range0, range1, period, decay)
    TriangleExp(λ0, λ1, period, γ)
    TriangleExp(;λ0, λ1, period, γ)

A [triangle wave](https://en.wikipedia.org/wiki/Triangle_wave) schedule
with `period` and an exponentially decaying amplitude.
The output conforms to
```text
abs(λ0 - λ1) * Triangle(t) * γ^(t - 1) + min(λ0, λ1)
```
where `Triangle(t)` is `(2 / π) * abs(asin(sin(π * (t - 1) / schedule.period)))` (see [`Triangle`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
- `decay`/`γ`: the decay rate
"""
struct TriangleExp{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
    decay::T
end
TriangleExp(;λ0, λ1, period, γ) = TriangleExp(λ0, λ1, period, γ)

Base.eltype(::Type{<:TriangleExp{T}}) where T = T

(schedule::TriangleExp)(t) = _cycle(schedule.range0, schedule.range1,
                                    _tri(t, schedule.period) * schedule.decay^(t - 1))

"""
    Sin{T, S<:Integer}(range0, range1, period)
    Sin(;λ0, λ1, period)

A sine wave schedule with `period`.
The output conforms to
```text
abs(λ0 - λ1) * abs(sin(π * (t - 1) / period)) + min(λ0, λ1)
```

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct Sin{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
end
Sin(;λ0, λ1, period) = Sin(λ0, λ1, period)

Base.eltype(::Type{<:Sin{T}}) where T = T

(schedule::Sin)(t) = _cycle(schedule.range0, schedule.range1, _sin(t, schedule.period))

"""
    SinDecay2{T, S<:Integer}(range0, range1, period)
    SinDecay2(;λ0, λ1, period)

A sine wave schedule with `period` and half the amplitude each cycle.
The output conforms to
```text
abs(λ0 - λ1) * Sin(t) / (2^floor((t - 1) / period)) + min(λ0, λ1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
"""
struct SinDecay2{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
end
SinDecay2(;λ0, λ1, period) = SinDecay2(λ0, λ1, period)

Base.eltype(::Type{<:SinDecay2{T}}) where T = T

(schedule::SinDecay2)(t) = _cycle(schedule.range0, schedule.range1,
                                  _sin(t, schedule.period) / (2^fld(t - 1, schedule.period)))

"""
    SinExp{T, S<:Integer}(range0, range1, period, decay)
    SinDecay2(;λ0, λ1, period, γ)

A sine wave schedule with `period` and an exponentially decaying amplitude.
The output conforms to
```text
abs(λ0 - λ1) * Sin(t) * γ^(t - 1) + min(λ0, λ1)
```
where `Sin(t)` is `abs(sin(π * (t - 1) / period))` (see [`Sin`](#)).

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
- `decay`/`γ`: the decay rate
"""
struct SinExp{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
    decay::T
end
SinExp(;λ0, λ1, period, γ) = SinExp(λ0, λ1, period, γ)

Base.eltype(::Type{<:SinExp{T}}) where T = T

(schedule::SinExp)(t) = _cycle(schedule.range0, schedule.range1,
                               _sin(t, schedule.period) * schedule.decay^(t - 1))

"""
    CosAnneal{T, S<:Integer}(range0, range1, period, restart)
    CosAnneal(;λ0, λ1, period, restart = true)

A cosine annealing schedule
(see ["SGDR: Stochastic Gradient Descent with Warm Restarts"](https://arxiv.org/abs/1608.03983v5))
The output conforms to
```text
t̂ = restart ? (t - 1) : mod(t - 1, period)
abs(λ0 - λ1) * (1 + cos(π * t̂ / period)) / 2 + min(λ0, λ1)
```
This schedule is also referred to as "cosine annealing (with warm restarts)"
in machine learning literature.

# Arguments
- `range0`/`λ0`: the first range endpoint
- `range1`/`λ1`: the second range endpoint
- `period::Integer`: the period
- `restart::Bool`: use warm-restarts
"""
struct CosAnneal{T, S<:Integer} <: AbstractSchedule{false}
    range0::T
    range1::T
    period::S
    restart::Bool
end
CosAnneal(;λ0, λ1, period, restart = true) = CosAnneal(λ0, λ1, period, restart)

Base.eltype(::Type{<:CosAnneal{T}}) where T = T

function (schedule::CosAnneal)(t)
    t̂ = schedule.restart ? mod(t - 1, schedule.period) : (t - 1)

    return _cycle(schedule.range0, schedule.range1,
                  (1 + cos(π * t̂ / schedule.period)) / 2)
end

Base.@deprecate Cos(range0, range1, period) CosAnneal(range0, range1, period, true)
Base.@deprecate Cos(;λ0, λ1, period) CosAnneal(λ0 = λ0, λ1 = λ1, period = period)
