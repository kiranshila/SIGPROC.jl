using RecipesBase, Statistics, DimensionalData

@recipe f(::Type{Filterbank}, fb::Filterbank) = fb.data

@userplot Waterfall

@recipe function f(h::Waterfall)
    if h.args[1] isa Filterbank
        data = h.args[1].data
    elseif h.args[1] isa DimArray
        data = h.args[1]
    else
        @error "Argument must be a filterbank or DimArray"
    end

    # set up the subplots

    fc := :viridis
    legend := false
    link := :both
    framestyle := [:none :axes :none]
    grid := false
    layout := @layout [topav              _
                       heatmap{0.9w,0.9h} _]
    
    # Main Waterfall
    @series begin
        seriestype := :heatmap
        subplot := 2
        data
    end

    # these are common to both average plots
    linecolor := :black
    seriestype := :line

    # upper
    @series begin
        title := ""
        subplot := 1
        dropdims(mean(data,dims=Freq),dims=Freq)
    end
end