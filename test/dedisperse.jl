using RadioTransients, Plots, Statistics, DimensionalData

frb = Filterbank("candidate_ovro_20200428.fil")

chunk = frb.data
waterfall(chunk)

dedisperse(frb,333.3).data |> waterfall