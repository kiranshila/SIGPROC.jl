function snr(data,boxcar_width)
    first_quant = quantile(data |> vec, 0.25)
    noise_std = std(filter(x->x<first_quant,data))
    data ./ noise_std
end