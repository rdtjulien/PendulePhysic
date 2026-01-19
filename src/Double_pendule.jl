using Plots, CSV, DataFrames, Optim

#Read CSV
df = CSV.read("src/data.csv", DataFrame)

#Positions from csv
tracker_x1 = df.x_m1
tracker_y1 = df.y_m1
tracker_x2 = df.x_m2
tracker_y2 = df.y_m2

#total frame
N_tracker = length(tracker_x1)

#Video duration
video_duration = 2.0
dt = video_duration / N_tracker

#Convert positions to angles
tracker_angle1 = zeros(N_tracker)
tracker_angle2 = zeros(N_tracker)

for i in 1:N_tracker
    #Angle 1
    tracker_angle1[i] = atan(tracker_x1[i], -tracker_y1[i])

    #Angle 2
    dx = tracker_x2[i] - tracker_x1[i]
    dy = tracker_y2[i] - tracker_y1[i]
    tracker_angle2[i] = atan(dx, -dy)
end

#Constante
g  = 9.81
l1 = 0.09174
l2 = 0.06933

#Movement equation
function derivatives(angle1, v_angulaire1, angle2, v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    
    #Relative angle
    delta = angle1 - angle2

    #Common denominator
    denom = 2*m1 + m2 - m2*cos(2*delta)

    #Angular speed
    a1 = (-g*(2*m1 + m2)*sin(angle1) - m2*g*sin(angle1 - 2*angle2) - 2*m2*sin(delta)*(v_angulaire2^2*l2 + v_angulaire1^2*l1*cos(delta))) / (l1 * denom)
    a2 = (2*sin(delta)*(v_angulaire1^2*l1*(m1 + m2) + g*(m1 + m2)*cos(angle1) + v_angulaire2^2*l2*m2*cos(delta))) / (l2 * denom)

    #Friction
    a1 -= c1 * v_angulaire1
    a2 -= c2 * v_angulaire2

    return v_angulaire1, a1, v_angulaire2, a2
end

#RK4
function rk4_step(angle1, v_angulaire1, angle2, v_angulaire2, dt, g, l1, l2, m1, m2, c1, c2)

    #Intermediate slopes
    k1_angle1, k1_v_angulaire1, k1_angle2, k1_v_angulaire2 = derivatives(angle1, v_angulaire1, angle2, v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    k2_angle1, k2_v_angulaire1, k2_angle2, k2_v_angulaire2 = derivatives(angle1 + 0.5*dt*k1_angle1, v_angulaire1 + 0.5*dt*k1_v_angulaire1, angle2 + 0.5*dt*k1_angle2, v_angulaire2 + 0.5*dt*k1_v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    k3_angle1, k3_v_angulaire1, k3_angle2, k3_v_angulaire2 = derivatives(angle1 + 0.5*dt*k2_angle1, v_angulaire1 + 0.5*dt*k2_v_angulaire1, angle2 + 0.5*dt*k2_angle2, v_angulaire2 + 0.5*dt*k2_v_angulaire2, g, l1, l2, m1, m2, c1, c2)
    k4_angle1, k4_v_angulaire1, k4_angle2, k4_v_angulaire2 = derivatives(angle1 + dt*k3_angle1, v_angulaire1 + dt*k3_v_angulaire1, angle2 + dt*k3_angle2, v_angulaire2 + dt*k3_v_angulaire2, g, l1, l2, m1, m2, c1, c2)

    #Update
    angle1 += dt/6 * (k1_angle1 + 2*k2_angle1 + 2*k3_angle1 + k4_angle1)
    v_angulaire1 += dt/6 * (k1_v_angulaire1 + 2*k2_v_angulaire1 + 2*k3_v_angulaire1 + k4_v_angulaire1)
    angle2 += dt/6 * (k1_angle2 + 2*k2_angle2 + 2*k3_angle2 + k4_angle2)
    v_angulaire2 += dt/6 * (k1_v_angulaire2 + 2*k2_v_angulaire2 + 2*k3_v_angulaire2 + k4_v_angulaire2)

    return angle1, v_angulaire1, angle2, v_angulaire2
end

#RMSE sim / tracker
function compute_rmse(p)

    #optimization parameters
    m1, m2, c1, c2, v_a1, v_a2 = p

    #Reject parameters
    if m1 <= 0 || m2 <= 0 || c1 < 0 || c2 < 0
        return 1e6
    end

    #Initial conditions
    a1 = tracker_angle1[1]
    a2 = tracker_angle2[1]
    w1 = v_a1
    w2 = v_a2

    err = 0.0

    #integration
    for i in 1:N_tracker

        #Sim positions
        x1 =  l1*sin(a1)
        y1 = -l1*cos(a1)
        x2 = x1 + l2*sin(a2)
        y2 = y1 - l2*cos(a2)

        #Error 
        err += (x1 - tracker_x1[i])^2
        err += (y1 - tracker_y1[i])^2
        err += (x2 - tracker_x2[i])^2
        err += (y2 - tracker_y2[i])^2

        #integration forward
        if i < N_tracker
            a1, w1, a2, w2 = rk4_step(a1, w1, a2, w2, dt, g, l1, l2, m1, m2, c1, c2)
        end

        #Securtity
        if !isfinite(a1) || !isfinite(a2)
            return 1e6
        end
    end

    #Normalized RMSE
    return sqrt(err / (4N_tracker))
end

#Optim multi-start
best_global_rmse = Inf
best_global_params = nothing

#Multiple optimization
for k in 1:30
    #Initial parameters
    initial = [k, 3.0, 0.0, 0.0, 0.0, 0.0]

    #Upper and lower bounds for the parameters
    lower = [0.1, 0.1, 0.0, 0.0, -10.0, -10.0]
    upper = [30.0, 30.0, 1.0, 1.0,  10.0,  10.0]

    #Constrained optimization using Nelder–Mead wrapped in Fminbox
    result = optimize(compute_rmse, lower, upper, initial, Fminbox(NelderMead()), Optim.Options(iterations=50_000, show_trace=false))

    #local optimum
    local_params = Optim.minimizer(result)
    local_rmse   = Optim.minimum(result)

    amp_x1 = maximum(tracker_x1) - minimum(tracker_x1)
    amp_y1 = maximum(tracker_y1) - minimum(tracker_y1)
    amp_x2 = maximum(tracker_x2) - minimum(tracker_x2)
    amp_y2 = maximum(tracker_y2) - minimum(tracker_y2)

    #Average amplitude for RMSE
    amp_moyenne = (amp_x1 + amp_y1 + amp_x2 + amp_y2) / 4

    #NRMSE
    local_nrmse = (local_rmse / amp_moyenne) * 100

    println("$k")

    #Best solution
    if local_rmse < best_global_rmse
        best_global_rmse = local_rmse
        best_global_params = copy(local_params)
        println("Best ", local_nrmse)
    end
end

#Best params
println("m1 = ", best_global_params[1])
println("m2 = ", best_global_params[2])
println("c1 = ", best_global_params[3])
println("c2 = ", best_global_params[4])
println("v_angulaire1 = ", best_global_params[5])
println("v_angulaire2 = ", best_global_params[6])

#Optimal parameters
m1 = best_global_params[1]
m2 = best_global_params[2]
c1 = best_global_params[3]
c2 = best_global_params[4]
v_angulaire1 = best_global_params[5]
v_angulaire2 = best_global_params[6]

angle1 = tracker_angle1[1]
angle2 = tracker_angle2[1]

res1 = zeros(N_tracker)
res2 = zeros(N_tracker)

#integration
for i in 1:N_tracker
    res1[i] = angle1
    res2[i] = angle2

    if i < N_tracker
        angle1, v_angulaire1, angle2, v_angulaire2 = rk4_step(angle1, v_angulaire1, angle2, v_angulaire2, dt, g, l1, l2, m1, m2, c1, c2)
    end
end

#Animation with best params
anim = @animate for i in 1:N_tracker
    #Sim
    x1 = l1 * sin(res1[i])
    y1 = -l1 * cos(res1[i])
    x2 = x1 + l2 * sin(res2[i])
    y2 = y1 - l2 * cos(res2[i])

    #Tracker
    x1_t = l1 * sin(tracker_angle1[i])
    y1_t = -l1 * cos(tracker_angle1[i])
    x2_t = x1_t + l2 * sin(tracker_angle2[i])
    y2_t = y1_t - l2 * cos(tracker_angle2[i])

    plot(xlims=(-0.2,0.2), ylims=(-0.2,0.2), aspect_ratio=:equal, legend=true)

    plot!([0,x1_t,x2_t],[0,y1_t,y2_t], lw=3, color=:red, label="Tracker")
    plot!([0,x1,x2],[0,y1,y2], lw=2, color=:blue, label="Simulation")

    scatter!([x1_t, x2_t], [y1_t, y2_t], color=:red, ms=5)
    scatter!([x1, x2], [y1, y2], color=:blue, ms=5)
end

mp4(anim, "video/Pendule.mp4", fps=100)

#Time
t = range(0, video_duration, length=N_tracker)

#Positions sim to pixels
sum_dist = 0.0
for i in 1:N_tracker
    sum_dist += sqrt(tracker_x1[i]^2 + tracker_y1[i]^2)
end

scale_factor = sum_dist / N_tracker / l1

#Convert simulated angles to pixel coordinates
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

#Compare plots
p1 = plot(t, x1_track, lw=3, label="Tracker", title="x1")
plot!(p1, t, x1_sim, lw=2, label="Simulation")

p2 = plot(t, y1_track, lw=3, label="Tracker", title="y1")
plot!(p2, t, y1_sim, lw=2, label="Simulation")

p3 = plot(t, x2_track, lw=3, label="Tracker", title="x2")
plot!(p3, t, x2_sim, lw=2, label="Simulation")

p4 = plot(t, y2_track, lw=3, label="Tracker", title="y2")
plot!(p4, t, y2_sim, lw=2, label="Simulation")

plot(p1, p2, p3, p4, layout=(2,2), size=(900,700))
 