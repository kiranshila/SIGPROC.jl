using IntervalSets, DimensionalData

@inline gaussian(t, t₀, w) = exp(-((t - t₀) / w)^2)

const KDM = 4.148808e3 # MHz^2 pc^-1 cm^3 s

"""
Δt(DM, ν₁, ν₂)
Calculates the time delay corresponding to a dispersed pulse at dispersion measure `DM` in pc/cc between
frequencies `ν₁` and `ν₂`
"""
Δt(DM, ν₁, ν₂) = KDM * DM * (ν₁^-2 - ν₂^-2)

"""
fake_pulse(DM,f_low,f_high)

Generates a `Filterbank` file corresponding to a fake pulse of dispersion measure `DM`
from frequencies `f_low` to `f_high` (MHz).

# Optional Arguments
- `channels`: Number of frequency channels
- `samples`: Number of time samples
- 't_step`: The time step (s) represented by one sample
- `w`: Width of the pulse in time samples
- `A`: Amplitude of pulse in SNR
- `α`: Spectral index, i.e. attenuation of pulse over frequency
- `start`: Index of start of pulse
- `dtype`: Data type of data
"""
function fake_pulse(DM, f_low, f_high;
                    channels=1024,
                    samples=1024,
                    t_step=1e-3,
                    w=8,
                    A=2,
                    α=4,
                    start=samples / 2,
                    dtype=Float32)
    @assert start < samples "Starting sample must be less than the number of samples"

    freqs = range(; start=f_high, stop=f_low, length=channels)
    time = range(; start=0, step=t_step, length=samples)

    t_start = start * t_step

    shifts = @. Δt(DM, freqs', f_high)
    dyn_spec = rand(dtype, samples, channels)
    raw_pulse = @. gaussian(time, t_start + shifts, w * t_step) * A * (freqs' / f_high)^α
    if dtype <: Integer
        dyn_spec += round.(dtype,raw_pulse)
    else
        dyn_spec += raw_pulse
    end

    return Filterbank(DimArray(dyn_spec, (Ti(time), Freq(freqs))), Dict("tsamp" => t_step))
end

function fake_pulse!(dyn_spec, DM, f_low, f_high;
                     t_step=1e-3,
                     w=8,
                     A=2,
                     α=4,
                     start=nothing,
                     dtype=Float32)
    samples, channels = size(dyn_spec)

    freqs = range(; start=f_high, stop=f_low, length=channels)
    time = range(; start=0, step=t_step, length=samples)

    if isnothing(start)
        start = samples ÷ 2
    end

    t_start = start * t_step

    shifts = @. Δt(DM, freqs', f_high)
    dyn_spec .= rand(dtype, samples, channels)
    return dyn_spec .+= @. gaussian(time, t_start + shifts, w * t_step) * A *
                           (freqs' / f_high)^α
end

export fake_pulse, fake_pulse!
