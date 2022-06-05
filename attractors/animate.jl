begin
    #change to desired attractor
	attractor = Aizawa()
	
	points = Observable(Point3f[])
	colors = Observable(Int[])
	
	set_theme!(theme_black())
	
	fig, ax, l = lines(points, color = colors,
	    colormap = :inferno, transparency = true,
	    axis = (; type = Axis3, protrusions = (0, 0, 0, 0),
            #change limits to fit respective attractor
	        viewmode = :fit, limits = (-5, 5, -5, 5, -5, 5)))
	
	record(fig, "aizawa.mp4", 1:360) do frame
	    for i in 1:50
	        push!(points[], step!(attractor))
	        push!(colors[], frame)
	    end
	    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 120)
	    notify.((points, colors))
	    l.colorrange = (0, frame)
	end
end