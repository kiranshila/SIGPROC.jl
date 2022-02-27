using RecipesBase, Statistics

@recipe f(::Type{Filterbank}, fb::Filterbank) = fb.data

@userplot Waterfall

@recipe function f(h::Waterfall)
    #@assert h.args[1] isa AbstractVector && size(h.args[1]) "Waterfall plots are for a matrix of 2D data"

   data = h.args[1]

    # set up the subplots
    legend := false
    link := :both
    framestyle := [:none :axes :none]
    grid := false
    layout := @layout [topav              _
                       heatmap{0.9w,0.9h} rightav]
    
    # Main Waterfall
    @series begin
        seriestype := :heatmap
        subplot := 2
        yflip := true
        data
    end

    # these are common to both average plots
    linecolor := :black
    seriestype := :line

    # upper
    @series begin
        subplot := 1
        y := mean(data,dims=Samp)
    end

    # right histogram
    @series begin
        orientation := :h
        subplot := 3
        y := mean(data',dims=Freq)
    end
end