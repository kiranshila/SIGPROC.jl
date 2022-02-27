using DimensionalData, Statistics, Optim, IntervalSets

const KDM = 4.148808e3 # MHz^2 pc^-1 cm^3 s

"""
Δt(DM, ν₁, ν₂)

Calculates the time delay corresponding to a dispersed pulse at dispersion measure `DM` in pc/cc between
frequencies `ν₁` and `ν₂`
"""
Δt(DM, ν₁, ν₂) = KDM * DM * (ν₁^-2 - ν₂^-2)

"""
dedisperse(dyn_spec, DM)

Creates a de-dispersed dynamic spectrum for dispersion measure `DM` in pc/cc given
that the source filterbank dynamic_spectrum `dyn_spec` has samples with time step `t_step` in seconds.
"""
function dedisperse(dyn_spec::Filterbank, DM)
    tsamp = dyn_spec.headers["tsamp"]
    time = dyn_spec.data.dims[1]
    freqs = dyn_spec.data.dims[2]
    f_min, f_max = extrema(freqs)
    max_shift_time = Δt(DM, f_min, f_max)
    time_max = maximum(time) - max_shift_time
    samp_max = Int(time_max ÷ tsamp)

    dedisp = fill(NaN, Ti(range(start=0,stop=time_max,length=samp_max)), freqs)

    for freq in dyn_spec.data.dims[2]
        shift_t = Δt(DM, f_min, freq)
        shift_samp = Int(shift_t ÷ tsamp)
        dedisp[Freq(At(Val(freq)))] .= dyn_spec.data[Freq(At(Val(freq))),
                                                     Ti=(1 + shift_samp):(samp_max + shift_samp)]
    end

    return dedisp
end

function cost(dyn_spec, DM)
    tsamp = dyn_spec.headers["tsamp"]
    time = dyn_spec.data.dims[1]
    freqs = dyn_spec.data.dims[2]
    f_min, f_max = extrema(freqs)
    max_shift_time = Δt(DM, f_min, f_max)
    time_max = maximum(time) - max_shift_time
    samp_max = Int(time_max ÷ tsamp)

    s = zeros(samp_max)

    for freq in freqs
        shift_t = Δt(DM, f_min, freq)
        shift_samp = Int(shift_t ÷ tsamp)
        s .+= dyn_spec.data[Ti=(1 + shift_samp):(samp_max + shift_samp),
                                  Freq(At(Val(freq)))]
    end
    return -std(s)
end

"""
estimate_dm(dyn_spec)

Estimates the dispersion measure for filterbank dynamic_spectrum `dyn_spec` by
maximizing the standard deviation of the folded spectrum.
"""
function estimate_dm(dyn_spec)
    results = Optim.optimize(dm -> cost(dyn_spec, dm), 1.0, 700.0)
    return Optim.minimizer(results)
end

export Δt, dedisperse, estimate_dm
