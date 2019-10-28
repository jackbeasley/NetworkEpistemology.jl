module Individuals

using Distributions

#mutable struct Individual{T <: Distributions.Distribution}
#    id::Int64
#    beliefs::Vector{T}
#end

mutable struct BetaIndividual
    id::Int64
    alphas::Vector{Float64}
    betas::Vector{Float64}
end

function BetaIndividual(id::Int64,
                        numActions::Int,
                        alphaDist::Distributions.Distribution, betaDist::Distributions.Distribution)
    return BetaIndividual(id, rand(alphaDist, numActions), rand(betaDist, numActions))
end

struct TrialResult
    individualID::Int64
    actionID::Int
    numSuccesses::Int
    numTrials::Int
end

# Returns index (id) of chosen action based on internal belief distributions and decision process
function select_action(indiv::BetaIndividual)::Int

    return argmax([mean(Beta(alpha, beta)) for (alpha, beta) = zip(indiv.alphas, indiv.betas)])
end

const TrialCounts = NamedTuple{(:successes, :trials), Tuple{Integer, Integer}}

# Converts a stream of TrialResults into 
function group_results_by_action(numActions::Int, results::Vector{TrialResult})::Tuple{Vector{Int}, Vector{Int}}

    numTrials = zeros(numActions)
    numSuccesses = zeros(numActions)

    for result in results
        while size(numTrials)[1] < result.actionID
            println(size(numTrials)[1])
            push!(numTrials, 0)
            push!(numSuccesses, 0)
        end

        numTrials[result.actionID] += result.numTrials
        numSuccesses[result.actionID] += result.numSuccesses
    end

    return (numSuccesses, numTrials)
end

function update_with_results(indiv::BetaIndividual, results::Vector{TrialResult})
    (numSuccessesByAction, numTrialsByAction) = group_results_by_action(size(indiv.alphas)[1], results)

    indiv.alphas = indiv.alphas .+ numSuccessesByAction
    indiv.betas = indiv.betas .+ numTrialsByAction .- numSuccessesByAction
end

export BetaIndividual, TrialResult, TrialCounts, update_with_results, select_action

end
