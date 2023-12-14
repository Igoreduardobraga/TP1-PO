
using JuMP
using HiGHS

mutable struct SubgrafoInduzidoData
    n::Int                          # Quantidade de vertices
	w::Array{Int}					# Pesos
    vizinhos::Array{Array{Int}}		# Arestas
	
end

function readData(file)
	n = 0
	vizinhos = [[]]
	w = zeros(Int64, 0, 0)
	
	for l in eachline(file)
		q = split(l, "\t")

		if q[1] == "n"
			n = parse(Int64, q[2])
			vizinhos = [[] for i=1:n]
			w = zeros(n,n)
		elseif q[1] == "e"
			v = parse(Int64, q[2])
			u = parse(Int64, q[3])
			w[u, v] = parse(Int64, q[4])
			push!(vizinhos[v], u)
			push!(vizinhos[u], v)
		end
	end
	return SubgrafoInduzidoData(n,w,vizinhos)
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = readData(file)

@variable(model, y[i=1:data.n, j=1:data.n], Bin) # variável que indica que a aresta i,j esta no grafo
@variable(model, x[i=1:data.n], Bin) # variável que indica que o vertice i foi selecionado

for i=1:data.n
	for j in data.vizinhos[i]
        @constraint(model, y[i, j] <= x[i])
		@constraint(model, y[i, j] <= x[j])
		@constraint(model, x[i] + x[j] <= 1 + y[i, j])
	end
end

@objective(model, Max, sum((y[i, j] * data.w[i, j]) for i=1:data.n, j in data.vizinhos[i]))

optimize!(model)

sol = objective_value(model)
println("TP1 2022425671 = ", sol)