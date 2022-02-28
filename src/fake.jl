using IntervalSets, DimensionalData

gaussian(t, t₀, w) = exp(-((t - t₀) / w)^2)

"""
pulse(DM,f_low,f_high)

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
function pulse(DM, f_low, f_high;
                channels=1024,
                samples=2048,
                t_step=1e-3,
                w=8,
                A=2,
                α=4,
                start=samples/2,
                dtype = Float16)
    freqs = Freq(range(; start=f_high, stop=f_low, length=channels))
    time = Ti(range(; start=0, step=t_step, length=samples))

    dyn_spec = rand(dtype,time, freqs)

    t_start = start * t_step

    for j in 1:samples, i in 1:channels
        t = time[j]
        f = freqs[i]
        t_f = t_start + Δt(DM,f,f_high)
        dyn_spec[j,i] += A * (f / f_high)^α * gaussian(t,t_f,w*t_step)
    end

    return Filterbank(dyn_spec, Dict("tsamp" => t_step))
end

export pulse