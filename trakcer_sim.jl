using Plots, CSV, DataFrames

df = CSV.read("data.csv", DataFrame)

x1 = df.x_m1
y1 = df.y_m1
x2 = df.x_m2
y2 = df.y_m2

@gif for i in 1:1:length(x1)
    plot([0, x1[i], x2[i]], [0, y1[i], y2[i]], lw=3, xlims=(-1000, 1000), ylims=(-1000, 1000), aspect_ratio=:equal, legend=false, title="Double pendule")
    scatter!([0, x1[i], x2[i]], [0, y1[i], y2[i]], ms=6)
end
