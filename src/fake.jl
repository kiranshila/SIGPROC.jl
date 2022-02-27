using IntervalSets, DimensionalData

gaussian(x,σ=3) = exp(-(x^2)/(2σ^2))

# WIP

function pulse(DM,f_start,f_stop,snr;channels=1024,samples=1024,tstep=1e-4,σ=1,samp_start = 30e-2)
    freqs = Freq(range(start=f_start,stop=f_stop,length=channels))
    samps = Samp(range(start=1,stop=samples,step=1))
    dyn_spec = rand(samps,freqs)
    pulse_shape = [gaussian(x,σ) for x ∈ -5σ:5σ] .* snr
    for freq ∈ freqs
        dt = Δt(DM, f_start, freq)
        # In which sample does this dispersed frequency arrive?
        t = samp_start + dt
        samp = t ÷ tstep
        dyn_spec[Freq(At(freq)), Samp(Between(samp-5σ,samp+5σ))] += pulse_shape
    end
    dyn_spec
end

# pulse(950,1200,1500,5;tstep=1e-3,samples=1500,σ=1)