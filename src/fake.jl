using DimensionalData

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
- 'δt`: The time step (s) represented by one sample
- `w`: Width of the pulse in time samples
- `A`: Amplitude of pulse in SNR
- `α`: Spectral index, i.e. attenuation of pulse over frequency
- `start`: Index of start of pulse
- `noise_floor`: Value of the top of the noise floor. This is 1 for `dtype` of Floats and one tenth `typemax` for integers by default.
- `dtype`: Data type of data
"""
function fake_pulse(DM, f_low, f_high;
                    channels=1024,
                    samples=1024,
                    δt=1e-3,
                    w=8,
                    A=2,
                    α=4,
                    start=1,
                    noise_floor::Union{T,Nothing}=nothing,
                    dtype::Type{T}=Float32) where {T}
    @assert start < samples "Starting sample must be less than the number of samples"

    if isnothing(noise_floor)
        if dtype <: Integer
            # Default to one tenth the range of the integer type
            noise_floor = typemax(T) ÷ 0xA
        else
            noise_floor = one(T)
        end
    end

    freqs = range(; start=f_high, stop=f_low, length=channels)
    time = range(; start=0, step=δt, length=samples)

    t_start = start * δt

    # Caclulate shifts
    shifts = @. Δt(DM, freqs', f_high)

    # Generate the raw pulse, these are floats at this point
    raw_pulse = @. gaussian(time, t_start + shifts, w * δt) * A * noise_floor * (freqs' / f_high)^α

    # Prep the dynamic spectrum with the background noise
    dyn_spec = rand(zero(T):noise_floor, samples, channels)

    # Add in the pulse
    if dtype <: Integer
        dyn_spec += round.(dtype,raw_pulse)
    else
        dyn_spec += raw_pulse
    end

    # Build Filterbank
    return Filterbank(DimArray(dyn_spec,
                               (Ti(time),
                                Freq(freqs))),
                      Dict("tsamp" => δt,
                           "nbits" => sizeof(dtype) * 8,
                           "nsamples" => samples,
                           "nchans" => channels,
                           "fch1" => f_high,
                           "foff" => step(freqs)))
end

export fake_pulse
