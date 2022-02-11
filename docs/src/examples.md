# Examples

```@setup examples
using SIGPROC, IntervalSets, DimensionalData
```

First, let's grab some filterbank data, we can find one from [Berkeley's SETI Research Center](http://breakthroughinitiatives.org/opendatasearch). Julia's `download` function will grab the file from a URL and give us the filename back.

```@example examples
filename = download("https://github.com/UCBerkeleySETI/breakthrough/blob/master/GBT/filterbank_tutorial/blc04_guppi_57563_69862_HIP35136_0011.gpuspec.0002.fil?raw=true")
```

Now, we can read it into a `Filterbank`. By default, it will read all the time samples, we can however supply `start` and `stop` arguments if we want to look at a limited chunk. This is usefull as these files can get quite large.

```@example examples
fb = Filterbank(filename)
```

The data is stored as a `DimArray` from the [DimensionalData](https://github.com/rafaqz/DimensionalData.jl) package in the `data` attribute. This provides zero-cost abstractions for named indexing and fast index lookups. Our filterbank data has axes `Freq` and `Samp`, which we can use for indexing.

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

We can also index by sample to get the nth integration

```@example examples
fb.data[Samp = At(99)] |> plot
```

We can also combine this indexing with Julia's builtin array operations such as looking at the time-averaged slice of spectrum. In this window, we get a nice look at the [21-centimeter line](https://en.wikipedia.org/wiki/Hydrogen_line)

```@example examples
mean(fb.data,dims=Samp)[Freq = 1419..1422] |> plot
```