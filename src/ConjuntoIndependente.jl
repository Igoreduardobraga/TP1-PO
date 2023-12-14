
using JuMP
using HiGHS

mutable struct ConjuntoIndependenteData
    n::Int 						# Quantidade de vertices
    vizinhos::Array{Array{Int}} # Arestas
end

function readData(file)
	n = 0
	vizinhos = [[]]
	for l in eachline(file)
		q = split(l, "\t")

		if q[1] == "n"
			n = parse(Int64, q[2])
			vizinhos = [[] for i=1:n]
		elseif q[1] == "e"
			v = parse(Int64, q[2])
			u = parse(Int64, q[3])
			push!(vizinhos[v], u)
			push!(vizinhos[u], v)
		end
	end
	return ConjuntoIndependenteData(n,vizinhos)
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = readData(file)

@variable(model, x[i=1:data.n], Bin) # variável que indica que o vértice i foi escolhido

for i = 1:data.n, j in data.vizinhos[i]
    @constraint(model, x[i] + x[j] <= 1)
end

@objective(model, Max, sum(x[i] for i=1:data.n))

optimize!(model)

sol = objective_value(model)
println("TP1 2022425671 = ", sol)