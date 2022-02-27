using IntervalSets, DimensionalData

gaussian(x, σ=3) = exp(-(x^2) / (2σ^2))

# WIP

function pulse(DM, f_start, f_stop; snr=1, channels=1024, samples=2048, tstep=1e-4, σ=1)
    freqs = Freq(range(; start=f_start, stop=f_stop, length=channels))
    time = Ti(range(; start=0, step=tstep, length=samples))
    dyn_spec = rand(time, freqs)
    pulse_shape = [gaussian(x, σ) for x in (-5σ):(5σ)] .* snr
    for freq in freqs
        dt = Δt(DM, f_start, freq)
        shift_samp = Int(dt ÷ tstep)
        dyn_spec[Ti=(1+shift_samp):(length(pulse_shape) + shift_samp),Freq(At(freq))] += pulse_shape
    end
    return Filterbank(dyn_spec, Dict("tsamp" => tstep))
end

# pulse(950,1200,1500,5;tstep=1e-3,samples=1500,σ=1)

export pulse