module Individuals

using ..Interface
using ..Beliefs: BetaBeliefs, BetaBeliefParams, expectations, update_beliefs
using ..ObservationRules: TallyObservations

using LightGraphs

struct BetaIndividual{N} <: AbstractIndividual
    beliefs::BetaBeliefs{N}
end

BetaIndividual{N}(beliefParams::BetaBeliefParams) where {N} = BetaIndividual{N}(BetaBeliefs(beliefParams))

# Returns index (id) of chosen action based on internal belief distributions and decision process
function Interface.select_fact_to_observe(indiv::BetaIndividual)::Int
    # Myopic / greedy decision making
    return argmax(expectations(indiv.beliefs))
end

function Interface.begin_observation(indiv::BetaIndividual{N}, num_facts::Int64) where {N}
    return TallyObservations{N}()
end

function Interface.should_observe(indiv::BetaIndividual, g::AbstractGraph, idToObserve::Int, indivToObserve::BetaIndividual)::Bool
    return true
end

function Interface.pick_audience(indiv::BetaIndividual, g::AbstractGraph, id::Int)
    # Send to all listening neigbhors
    return inneighbors(g, id)
end

function Interface.update_with_observations(indiv::BetaIndividual{N}, observations::TallyObservations{N})::BetaIndividual{N} where {N}
    return BetaIndividual{N}(update_beliefs(indiv.beliefs, observations))
end

export BetaIndividual, select_fact_to_observe, begin_observation, pick_audience, should_observe, update_with_observations

end
