module Individuals

using Distributions

mutable struct BetaBeliefs{T <: Real}
    alphaValues::Vector{T}
    betaValues::Vector{T}
end

struct BetaBeliefParams
    numActions::Int
    alphaDist::Distributions.Distribution
    betaDist::Distributions.Distribution
end

BetaBeliefs(params:: BetaBeliefParams) = BetaBeliefs(
    [rand(params.alphaDist) for _ = 1:params.numActions], # Alpha values
    [rand(params.betaDist) for _ = 1:params.numActions],  # Beta values
)

@inline function num_beliefs(beliefs::BetaBeliefs)::Int
    return length(beliefs.alphaValues)
end

@inline function belief_for_action(beliefs::BetaBeliefs, n::Integer)::Float64
    return mean(Beta(beliefs.alphaValues[n], beliefs.betaValues[n]))
end

# TODO: Maybe abstract away vectors????
struct TrialCountObservations
    successesByAction::Vector{Int64}
    trialsByAction::Vector{Int64}
end

function update_beliefs(beliefs::BetaBeliefs, observations::TrialCountObservations)
    for actionID in 1:length(beliefs.alphaValues)
        numSuccesses = observations.successesByAction[actionID]
        numTrials = observations.trialsByAction[actionID]
        beliefs.alphaValues[actionID] += numSuccesses
        beliefs.betaValues[actionID] += numTrials - numSuccesses
    end
end

mutable struct Individual{T}
    id::Int64
    beliefs::T
end

const BetaIndividual = Individual{BetaBeliefs}

Individual{BetaBeliefs}(id::Int64, numActions::Int64,
    alphaDist::Uniform{Float64},
    betaDist::Uniform{Float64}) = Individual{BetaBeliefs}(id, BetaBeliefs(BetaBeliefParams(numActions, alphaDist, betaDist)))


# Returns index (id) of chosen action based on internal belief distributions and decision process
function select_action(indiv::Individual)::Int
    maxAction = -1
    maxExpectation = 0.0
    for i in 1:num_beliefs(indiv.beliefs)
        expectation = belief_for_action(indiv.beliefs, i)
        if expectation > maxExpectation
            maxAction = i
            maxExpectation = expectation
        end
    end
    return maxAction
end

function update_with_results(indiv::Individual, observations::TrialCountObservations)
    update_beliefs(indiv.beliefs, observations)
end

function update_with_results(indiv::Individual, successesByAction::Vector{Int64}, trialsByAction::Vector{Int64})
    update_beliefs(indiv.beliefs, TrialCountObservations(successesByAction, trialsByAction))
end

# function BetaIndividual(id::Int64,
#                         ,
#                         )
#     return BetaIndividual(id, )
# end

struct TrialResult
    individualID::Int64
    actionID::Int
    numSuccesses::Int
    numTrials::Int
end

#function beliefs(indiv::BetaIndividual)
#
#end

export BetaIndividual, TrialCountObservations, TrialResult, update_with_results, select_action

end
