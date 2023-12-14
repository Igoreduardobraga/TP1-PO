
using JuMP
using HiGHS

mutable struct ColoracaoData
    n::Int                          # Quantidade de vertices
    vizinhos::Array{Array{Int}}
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
	return ColoracaoData(n,vizinhos)
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = readData(file)

@variable(model, x[i=1:data.n], Bin) # variável que indica se a cor i já foi utilizada para colorir um vértice

@variable(model, y[i=1:data.n, j=1:data.n], Bin) # variável que indica que a cor i foi atribuida para o vértice j

for i=1:data.n, j=1:data.n, l in data.vizinhos[i]
	@constraint(model, y[i,j] + y[l,j] <= x[j])
end

for i=1:data.n
    @constraint(model, sum(y[i,j] for j=1:data.n) == 1)
    @constraint(model, sum(y[i,j] for j=1:data.n) >= x[i])
end

@objective(model, Min, sum(x))

optimize!(model)

sol = objective_value(model)
println("TP1 2022425671 = ", sol)