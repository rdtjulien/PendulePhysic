using Plots, CSV, DataFrames

#Read CSV
df = CSV.read("data.csv", DataFrame)

tracker_x1 = df.x_m1
tracker_y1 = df.y_m1
tracker_x2 = df.x_m2
tracker_y2 = df.y_m2

N_tracker = length(tracker_x1)

video_duration = 2.0
dt_frame = video_duration / N_tracker
fps_video = 1 / dt_frame

tracker_angle1 = zeros(N_tracker)
tracker_angle2 = zeros(N_tracker)
tracker_l1 = zeros(N_tracker)
tracker_l2 = zeros(N_tracker)

for i in 1:N_tracker
    tracker_angle1[i] = atan(tracker_x1[i], -tracker_y1[i])

    dx = tracker_x2[i] - tracker_x1[i]
    dy = tracker_y2[i] - tracker_y1[i]
    tracker_angle2[i] = atan(dx, -dy)

    tracker_l1[i] = sqrt(tracker_x1[i]^2 + tracker_y1[i]^2)
    tracker_l2[i] = sqrt(dx^2 + dy^2)
end

tracker_l1 = 0.09174
tracker_l2 = 0.06933

#Paramètres
g = 9.81
l1 = 0.09174
l2 = 0.06933
m1 = 9.25791172370327
m2 = 0.8153846153846154

c1 = 0.00
c2 = 0.00

angle1 = tracker_angle1[1]
angle2 = tracker_angle2[1]
v_angulaire1 = 0
v_angulaire2 = 0

res1 = zeros(N_tracker)
res2 = zeros(N_tracker)

dt = dt_frame

tada= []

function derivatives(angle1, v_angulaire1, angle2, v_angulaire2, g, l1, l2, m1, m2, c1, c2)

    delta = angle1 - angle2
    denom = 2*m1 + m2 - m2*cos(2*delta)

    a1 = (-g*(2*m1 + m2)*sin(angle1) - m2*g*sin(angle1 - 2*angle2) - 2*m2*sin(delta)*(v_angulaire2^2*l2 + v_angulaire1^2*l1*cos(delta))) / (l1 * denom)
    a2 = (2*sin(delta)*(v_angulaire1^2*l1*(m1 + m2) + g*(m1 + m2)*cos(angle1) + v_angulaire2^2*l2*m2*cos(delta))) / (l2 * denom)

    a1 -= c1 * v_angulaire1
    a2 -= c2 * v_angulaire2

    return v_angulaire1, a1, v_angulaire2, a2
end


function rk4_step(angle1, v_angulaire1, angle2, v_angulaire2, dt, g, l1, l2, m1, m2, c1, c2)

    k1_angle1, k1_v_angulaire1, k1_angle2, k1_v_angulaire2 = derivatives(angle1, v_angulaire1, angle2, v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    k2_angle1, k2_v_angulaire1, k2_angle2, k2_v_angulaire2 = derivatives(angle1 + 0.5*dt*k1_angle1, v_angulaire1 + 0.5*dt*k1_v_angulaire1, angle2 + 0.5*dt*k1_angle2, v_angulaire2 + 0.5*dt*k1_v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    k3_angle1, k3_v_angulaire1, k3_angle2, k3_v_angulaire2 = derivatives(angle1 + 0.5*dt*k2_angle1, v_angulaire1 + 0.5*dt*k2_v_angulaire1, angle2 + 0.5*dt*k2_angle2, v_angulaire2 + 0.5*dt*k2_v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    k4_angle1, k4_v_angulaire1, k4_angle2, k4_v_angulaire2 = derivatives(angle1 + dt*k3_angle1, v_angulaire1 + dt*k3_v_angulaire1, angle2 + dt*k3_angle2, v_angulaire2 + dt*k3_v_angulaire2, g, l1, l2, m1, m2, c1, c2)

    angle1 += dt/6 * (k1_angle1 + 2*k2_angle1 + 2*k3_angle1 + k4_angle1)
    v_angulaire1 += dt/6 * (k1_v_angulaire1 + 2*k2_v_angulaire1 + 2*k3_v_angulaire1 + k4_v_angulaire1)
    angle2 += dt/6 * (k1_angle2 + 2*k2_angle2 + 2*k3_angle2 + k4_angle2)
    v_angulaire2 += dt/6 * (k1_v_angulaire2 + 2*k2_v_angulaire2 + 2*k3_v_angulaire2 + k4_v_angulaire2)

    return angle1, v_angulaire1, angle2, v_angulaire2
end

for i in 1:N_tracker
    res1[i] = angle1
    res2[i] = angle2

    if i < N_tracker
        angle1, v_angulaire1, angle2, v_angulaire2 = rk4_step(angle1, v_angulaire1, angle2, v_angulaire2, dt, g, l1, l2, m1, m2, c1, c2)
    end
end

#Animation
anim = @animate for i in 1:N_tracker
    x1 = l1 * sin(res1[i])
    y1 = -l1 * cos(res1[i])
    x2 = x1 + l2 * sin(res2[i])
    y2 = y1 - l2 * cos(res2[i])

    x1_t = l1 * sin(tracker_angle1[i])
    y1_t = -l1 * cos(tracker_angle1[i])
    x2_t = x1_t + l2 * sin(tracker_angle2[i])
    y2_t = y1_t - l2 * cos(tracker_angle2[i])

    plot(xlims=(-0.2,0.2), ylims=(-0.2,0.2), aspect_ratio=:equal, legend=false)
    plot!([0,x1_t,x2_t],[0,y1_t,y2_t], lw=3, color=:red)
    plot!([0,x1,x2],[0,y1,y2], lw=2, color=:blue)

    scatter!([x1_t, x2_t], [y1_t, y2_t], color=:red, ms=5)
    scatter!([x1, x2], [y1, y2], color=:blue, ms=4)

end
mp4(anim, "test.mp4", fps=30)

t = range(0, video_duration, length=N_tracker)

#Positions sim en pixels
sum_dist = 0.0
for i in 1:N_tracker
    sum_dist += sqrt(tracker_x1[i]^2 + tracker_y1[i]^2)
end
scale_factor = sum_dist / N_tracker / l1

x1_sim = zeros(N_tracker)
y1_sim = zeros(N_tracker)
x2_sim = zeros(N_tracker)
y2_sim = zeros(N_tracker)

for i in 1:N_tracker
    x1_sim[i] = l1 * sin(res1[i]) * scale_factor
    y1_sim[i] = -l1 * cos(res1[i]) * scale_factor

    x2_sim[i] = (x1_sim[i] / scale_factor + l2 * sin(res2[i])) * scale_factor
    y2_sim[i] = (y1_sim[i] / scale_factor - l2 * cos(res2[i])) * scale_factor
end
#Positions tracker
x1_track = tracker_x1
y1_track = tracker_y1
x2_track = tracker_x2
y2_track = tracker_y2

#Graphe
p1 = plot(t, x1_track, lw=3, label="Tracker", title="x1", xlabel="t", ylabel="valeur")
plot!(p1, t, x1_sim, lw=2, label="Simulation")

p2 = plot(t, y1_track, lw=3, label="Tracker", title="y1", xlabel="t", ylabel="valeur")
plot!(p2, t, y1_sim, lw=2, label="Simulation")

p3 = plot(t, x2_track, lw=3, label="Tracker", title="x2", xlabel="t", ylabel="valeur")
plot!(p3, t, x2_sim, lw=2, label="Simulation")

p4 = plot(t, y2_track, lw=3, label="Tracker", title="y2", xlabel="t", ylabel="valeur")
plot!(p4, t, y2_sim, lw=2, label="Simulation")

plot(p1, p2, p3, p4, layout=(2,2), size=(900,700))
