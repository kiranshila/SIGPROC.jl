# Examples

## Reading Filterbanks

```@setup examples
using RadioTransients, IntervalSets, DimensionalData
```

First, let's grab some filterbank data, we can find one from [Berkeley's SETI Research Center](http://breakthroughinitiatives.org/opendatasearch). Julia's `download` function will grab the file from a URL and give us the filename back.

```@example examples
filename = download("https://github.com/UCBerkeleySETI/breakthrough/blob/master/GBT/filterbank_tutorial/blc04_guppi_57563_69862_HIP35136_0011.gpuspec.0002.fil?raw=true")
```

Now, we can read it into a `Filterbank`. By default, it will read all the time samples, we can however supply `start` and `stop` arguments if we want to look at a limited chunk. This is usefull as these files can get quite large.

```@example examples
fb = Filterbank(filename)
```

The data is stored as a `DimArray` from the [DimensionalData](https://github.com/rafaqz/DimensionalData.jl) package in the `data` attribute. This provides zero-cost abstractions for named indexing and fast index lookups. Our filterbank data has axes `Freq` and `Ti`, which we can use for indexing.

```@example examples
fb.data
```

Additionally, `DimArray`s have plot recipies that make visualization super easy. We can call [Plots.jl](https://github.com/JuliaPlots/Plots.jl)'s `heatmap` function to get a waterfall.

```@example examples
using Plots
fb.data |> heatmap
```

We can use this indexing to perform all sorts of analysis. Here we are using `..` from [IntervalSets.jl](https://github.com/JuliaMath/IntervalSets.jl) to create the range object.

```@example examples
fb.data[Freq = 1350..1450] |> heatmap
```

We can also index by time to get the nth integration

```@example examples
fb.data[Ti = 99] |> plot
```

We can also combine this indexing with Julia's builtin array operations such as looking at the time-averaged slice of spectrum. In this window, we get a nice look at the [21-centimeter line](https://en.wikipedia.org/wiki/Hydrogen_line)

```@example examples
using Statistics
dropdims(mean(fb.data,dims=Ti)[Freq = 1419..1422],dims=Ti) |> plot
```

## Dedispersing

Let's look at some real data now! Here, we'll use [FRB121102 data from the Lovell Telescope](https://zenodo.org/record/3974768)

First we'll grab the filterbank (included in this documentation)

```@example examples
frb = Filterbank("test/57781_65987_J0532+3305_000010.fil")
```

There's a bit too much data here to look at all the dynamic spectra, so we'll look at the first three seconds

```@example
waterfall(frb.data[Ti(Between(0,3))])
```
There is a lot of RFI, but hidden in this data is a fast radio burst! According to the paper, the FRB arrives at 2.456s - they usually last only a few ms.

```@example
waterfall(frb.data[Ti(Between(2.256,3.056))])
```

Now we can see it a little better, showcasing the "sad trombone" from the dispersion. We can correct for this using `dedisperse`. The dispersion measure (DM) for this particular FRB (FRB 121102) is 562.1 pc/cc.

```@example
dedisperse(frb,562.1).data[Ti(Between(2.256,3.056))] |> waterfall
```

Now we see the high SNR spike at the arrival time indicated. Let's zoom in!

```@example
dedisperse(frb,562.1).data[Ti(Between(2.306,2.606))] |> waterfall
```

We cam certainly see that the pulse is clearly there! We could then do more analysis on structure, SNR, etc.