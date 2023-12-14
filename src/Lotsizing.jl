
using JuMP
using HiGHS

mutable struct LotSizingComBackLogData
    n::Int          # tamanho do horizonte de planejamento
    c::Array{Int}   # custo de produção no período
    d::Array{Int}   # demanda pelo produto no período
    s::Array{Int}   # valor da estocagem no período
    p::Array{Int}   # valor da multa no período
end

function readData(file)
    n = 0
	c = []
	d = []
	s = []
    p = []
	for l in eachline(file)
		q = split(l, "\t")
		num = parse(Int64, q[2])
		if q[1] == "n"
			n = num
			c = [0 for i=1:n]
			d = [0 for i=1:n]
			s = [0 for i=1:n]
            p = [0 for i=1:n]
		elseif q[1] == "c"
			num = parse(Int64, q[2])
			c[num] = parse(Float64, q[3])
		elseif q[1] == "d"
			num = parse(Int64, q[2])
			d[num] = parse(Float64, q[3])									
		elseif q[1] == "s"
			num = parse(Int64, q[2])
			s[num] = parse(Float64, q[3])
        elseif q[1] == "p"
			num = parse(Int64, q[2])
			p[num] = parse(Float64, q[3])
		end
	end
	return LotSizingComBackLogData(n,c,d,s,p)
end

function printSolution(data, x)
	println("Esquema de produção:")
	for i = 1: data.n
		println("No periodo $i é produzido $(value(x[i]))")
	end
	println()
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = readData(file)

@variable(model, x[i=1:data.n] >= 0) # variável que indica a quantidade de produtos produzidos no periodo i
@variable(model, y[i=1:data.n] >= 0) # variável que indica o estoque no período i
@variable(model, z[i=1:data.n] >= 0) # variável que indica pedidos não atendidos
@variable(model, w[i=1:data.n], Bin) # variável que indica se teve produção ou não no periodo i

@constraint(model, x[1] == data.d[1] + y[1] - z[1])

@constraint(model, y[data.n] == 0)

@constraint(model, z[data.n] == 0)

for i=2:data.n
	@constraint(model, y[i-1] - z[i-1] + x[i] == data.d[i] + y[i] - z[i])
end

for i=1:data.n
	@constraint(model, sum(data.d[i] for i=1:data.n) * w[i] >= x[i])
end

@objective(model, Min, sum(x[i]*data.c[i] + y[i]*data.s[i] + z[i]*data.p[i] for i=1:data.n))

optimize!(model)

sol = objective_value(model)
println("TP1 2022425671 = ", sol)