using Plots, CSV, DataFrames, Optim

#Read CSV
df = CSV.read("src/data.csv", DataFrame)

tracker_x1 = df.x_m1
tracker_y1 = df.y_m1
tracker_x2 = df.x_m2
tracker_y2 = df.y_m2

N_tracker = length(tracker_x1)

video_duration = 4.0
dt = video_duration / N_tracker

#Convert positions to angles
tracker_angle1 = zeros(N_tracker)
tracker_angle2 = zeros(N_tracker)

for i in 1:N_tracker
    tracker_angle1[i] = atan(tracker_x1[i], -tracker_y1[i])
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
    delta = angle1 - angle2
    denom = 2*m1 + m2 - m2*cos(2*delta)

    a1 = (-g*(2*m1 + m2)*sin(angle1) - m2*g*sin(angle1 - 2*angle2) - 2*m2*sin(delta)*(v_angulaire2^2*l2 + v_angulaire1^2*l1*cos(delta))) / (l1 * denom)
    a2 = (2*sin(delta)*(v_angulaire1^2*l1*(m1 + m2) + g*(m1 + m2)*cos(angle1) + v_angulaire2^2*l2*m2*cos(delta))) / (l2 * denom)

    a1 -= c1 * v_angulaire1
    a2 -= c2 * v_angulaire2

    return v_angulaire1, a1, v_angulaire2, a2
end

#RK4
function rk4_step(angle1, v_angulaire1, angle2, v_angulaire2, dt, g, l1, l2, m1, m2, c1, c2)

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

m1 = 0.8738
m2 = 0.1122
c1 = 0.033436
c2 = 4.0e-6
v_angulaire1 = 0.1974
v_angulaire2 = 2.1604

angle1 = tracker_angle1[1]
angle2 = tracker_angle2[1]

res1 = zeros(N_tracker)
res2 = zeros(N_tracker)

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
    plot(xlims=(-0.2,0.2), ylims=(-0.2,0.2), aspect_ratio=:equal, legend=true)

    plot!([0,x1,x2],[0,y1,y2], lw=2, color=:blue, label="Simulation")

    scatter!([x1, x2], [y1, y2], color=:blue, ms=5)
end

mp4(anim, "video/prediciton4sec.mp4", fps=50)