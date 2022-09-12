using StaticArrays
using Colors

configurations = (
    (1, 1, 1),
    (1, 1, 0),
    (1, 0, 1),
    (1, 0, 0),
    (0, 1, 1),
    (0, 1, 0),
    (0, 0, 1),
    (0, 0, 0)
)


function update(;transition_rule, current)
    new = copy(current)
    for (i, val) in enumerate(current)
        if (i != 1) && (i <= dim-1)
            transition = transition_rule[tuple(current[i-1:i+1]...)]
            new[i] = transition
        elseif i == 1
            transition = transition_rule[tuple(current[1:3]...)]
            new[2] = transition
        else
            transition = transition_rule[tuple(current[dim-2:end]...)]
            new[dim] = transition
        end
    end
    return new
end

function evolve_matrix(;transition_rule=transition_rule, matrix::Array{Int64, 2})
    for (i, row) in enumerate(eachrow(matrix))
        if (i+1)%(dim+1) != 0
            matrix[i+1, :] = update(transition_rule=transition_rule, current=row)
        else
            break
        end
    end
end

function show_evolution(matrix::Array{Int64, 2})
    return Gray.(matrix)
end

function initialize_EA(;rule_num::Int64, dim=81)  
    rule_num = rule_num
    rule = reverse(digits(rule_num, base=2, pad=8))
    # rule = reverse([i for i in digits(rule_num, base=2, pad=8)])

    transition_rule = Dict(i => j for (i, j) in zip(configurations, rule))
    # @assert dim ≥ dim "# of col must be greater than # of rows"
    matrix = zeros(Int64, dim, dim)
    matrix[1, (dim+1) ÷ 2] = 1
    return transition_rule, matrix
end

(transition_rule, matrix) = initialize_EA(rule_num=30)
evolve_matrix(transition_rule=transition_rule, matrix=matrix)
Gray.(matrix)

