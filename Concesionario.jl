using Random, Distributions

# M/M/s

lambda = 70/9 #Clientes/h
mu = 3 #Clientes/h
s = 4
rho = lambda / (mu*s)
pi0 = (sum(n -> (lambda/mu)^n / factorial(n), 0:s-1) + (lambda/mu)^s / (factorial(s) * (1 - rho)))^-1
Lq = (pi0 * (lambda/mu)^s * rho) / (factorial(s) * (1 - rho)^2)
Wq = round(Lq / lambda, digits=4)
W = Wq + 1/mu
L = lambda * W
Cq = 2 
Cs = 2200
CTs = Cs * s + Lq * Cq   
println("cada cliente espera de media $(Wq*60) minutos en la cola y hay en promedio $(round(L, digits=4)) clientes en el sistema")
println("El sistema está ocupado el $(round(rho*100, digits=2))% del tiempo de media")
println("El tiempo total que un cliente pasa en el sistema es de $(round(W*60, digits=2)) minutos de media")

