
using JuMP
using HiGHS

mutable struct EmpacotamentoData
    n::Int 						# Quantidade de objetos
    vetor_pesos::Array{Float64} # Pesos dos objetos
end

function readData(file)
	n = 0
    vetor_pesos = []
	for l in eachline(file)
		q = split(l, "\t")

		if q[1] == "n"
			n = parse(Int64, q[2])
		elseif q[1] == "o"
			peso = parse(Float64, q[3])
			push!(vetor_pesos, peso)
		end
	end
	return EmpacotamentoData(n,vetor_pesos)
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = readData(file)

@variable(model, y[i=1:data.n], Bin) # variável que indica se a caixa i foi ou não usada

@variable(model, x[i=1:data.n, j=1:data.n], Bin) # variável que indica se o objeto i é armazenado na caixa j

for i=1:data.n
    @constraint(model, sum(x[i,j] for j = 1:data.n) == 1)
end

for j=1:data.n
    @constraint(model, sum(data.vetor_pesos[i] * x[i,j] for i = 1:data.n) <= 20 * y[j])
end

@objective(model, Min, sum(y[j] for j = 1:data.n))

optimize!(model)

sol = objective_value(model)
println("TP1 2022425671 = ", sol)