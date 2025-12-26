using Plots

#Paramètres
g = 9.81
l1 = 0.09174
l2 = 0.06933
m1 = 1.0
m2 = 0.2

angle1 = 181.6 * pi / 180
angle2 = 183.2 * pi / 180
v_angulaire1 = 0.0
v_angulaire2 = 0.0

pas = 0.002
tmax = 10.0
N = Int(tmax / pas)

res1 = zeros(N)
res2 = zeros(N)

#Simulation
for i in 1:N
    res1[i] = angle1
    res2[i] = angle2

    delta = angle1 - angle2
    denom = 2*m1 + m2 - m2*cos(2*delta)

    a_angulaire1 = (-g*(2*m1 + m2)*sin(angle1)-m2*g*sin(angle1 - 2*angle2)-2*m2*sin(delta)*(v_angulaire2^2*l2 + v_angulaire1^2*l1*cos(delta))) / (l1 * denom)

    a_angulaire2 = (2*sin(delta)*(v_angulaire1^2*l1*(m1 + m2) + g*(m1 + m2)*cos(angle1) + v_angulaire2^2*l2*m2*cos(delta))) / (l2 * denom)

    #Euler
    v_angulaire1 += pas * a_angulaire1
    v_angulaire2 += pas * a_angulaire2
    angle1    += pas * v_angulaire1
    angle2    += pas * v_angulaire2
end

#Animation
anim = @gif for i in 1:5:N
    #Pendule 1
    x1 = l1 * sin(res1[i])
    y1 = -l1 * cos(res1[i])

    #Pendule 2
    x2 = x1 + l2 * sin(res2[i])
    y2 = y1 - l2 * cos(res2[i])

    plot([0, x1, x2], [0, y1, y2],lw=3,xlims=(-0.2, 0.2),ylims=(-0.2, 0.2),aspect_ratio=:equal,legend=false,title="Double pendule")
    scatter!([0, x1, x2], [0, y1, y2], ms=6)
end
