using RadioTransients, Plots, Statistics

frb = Filterbank("candidate_ovro_20200428.fil")

heatmap(frb.data)

dm = estimate_dm(frb)

frb_dedisp = dedisperse(frb, dm)

heatmap(frb_dedisp)

plot(dropdims(mean(frb_dedisp,dims=Freq),dims=Freq))