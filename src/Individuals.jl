module Individuals

using Distributions

mutable struct Individual{T <: Distributions.Distribution}
    id::Int64
    beliefs::Vector{T}
end

mutable struct BetaIndividual
    id::Int64
    beliefs::Vector{Distributions.Beta}
end

function BetaIndividual(id::Int64,
                        numActions::Int,
                        alphaDist::Distributions.Distribution, betaDist::Distributions.Distribution)
    initBeliefs = [Distributions.Beta(rand(alphaDist), rand(betaDist)) for _ = 1:numActions]
    return BetaIndividual(id, initBeliefs)
end

struct TrialResult
    individualID::Int64
    actionID::Int
    numSuccesses::Int
    numTrials::Int
end

# Returns index (id) of chosen action based on internal belief distributions and decision process
function select_action(indiv::BetaIndividual)::Int
    return argmax([mean(belief) for belief = indiv.beliefs])
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

function update_with_results(indiv::BetaIndividual, results::Vector{TrialResult})
    groupedResults = group_results_by_action(results)

    for (actionID, (numSuccesses, numTrials)) in groupedResults
        existingDist = indiv.beliefs[actionID]
        indiv.beliefs[actionID] = Beta(
            params(existingDist)[1] + numSuccesses,
            params(existingDist)[2] + numTrials - numSuccesses,
        )
    end
end

export BetaIndividual, Individual, TrialResult, TrialCounts, update_with_results, select_action

end
