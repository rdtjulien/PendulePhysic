using Plots

#Paramètres
g = 9.81
l = 1.0

angle_initial = pi/2
v_angulaire = 0.0

pas = 0.02
tmax = 10.0
N = Int(tmax / pas)

res = zeros(N)

#Simulation
for i in 1:N
    res[i] = angle_initial

    a_angulaire = -(g / l) * sin(angle_initial)

    v_angulaire = v_angulaire + pas * a_angulaire
    angle_initial    = angle_initial    + pas * v_angulaire
end

#Plots
anim = @gif for i in 1:5:N
    x = l * sin(res[i])
    y = -l * cos(res[i])

    plot([0, x], [0, y], lw = 3, xlims = (-1.2l, 1.2l), ylims = (-1.2l, 0.2), legend = false, title = "Pendule simple")

    scatter!([x], [y], ms = 8)
    scatter!([0.0], [0.0], ms = 4)
end
