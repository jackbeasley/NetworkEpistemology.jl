module Individuals

using Distributions

#mutable struct Individual{T <: Distributions.Distribution}
#    id::Int64
#    beliefs::Vector{T}
#end

struct BetaIndividual
    id::Int64
    alphaValues::Vector{Float64}
    betaValues::Vector{Float64}
end

function BetaIndividual(id::Int64,
                        numActions::Int,
                        alphaDist::Distributions.Distribution, betaDist::Distributions.Distribution)
    alphaValues = [rand(alphaDist) for _ = 1:numActions]
    betaValues = [rand(betaDist) for _ = 1:numActions]
    return BetaIndividual(id, alphaValues, betaValues)
end

struct TrialResult
    individualID::Int64
    actionID::Int
    numSuccesses::Int
    numTrials::Int
end

function expectations(indiv::BetaIndividual)::Vector{Float64}
    return indiv.alphaValues ./ (indiv.alphaValues .+ indiv.betaValues)
end

# Returns index (id) of chosen action based on internal belief distributions and decision process
function select_action(indiv::BetaIndividual)::Int
    return argmax(expectations(indiv))
end

const TrialCounts = NamedTuple{(:successes, :trials), Tuple{Integer, Integer}}

# Converts a stream of TrialResults into
function group_results_by_action(results::Vector{TrialResult})::Dict{Int, TrialCounts}
    function groupResultByAction(dict::Dict{Int, TrialCounts}, result::TrialResult)
        initTuple = TrialCounts((successes=0, trials=0))
        curCounts = get(dict, result.actionID, initTuple)

        dict[result.actionID] = TrialCounts((
            result.numSuccesses + curCounts.successes,
            result.numTrials + curCounts.trials,
        ))
        return dict
    end

    return reduce(groupResultByAction, results; init = Dict{Int, TrialCounts}([]))
end

function update_with_results(indiv::BetaIndividual, successesByAction::Vector{Int64}, trialsByAction::Vector{Int64})
    new_alpha_values = copy(indiv.alphaValues)
    new_beta_values = copy(indiv.betaValues)
    for actionID in 1:length(indiv.alphaValues)
        numSuccesses = successesByAction[actionID]
        numTrials = trialsByAction[actionID]
        new_alpha_values[actionID] += numSuccesses
        new_beta_values[actionID] += numTrials - numSuccesses
    end
    return BetaIndividual(indiv.id, new_alpha_values, new_beta_values)
end

export BetaIndividual, TrialResult, TrialCounts, update_with_results, select_action, expectations

end
