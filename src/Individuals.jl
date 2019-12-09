module Individuals

using ..Core: AbstractBeliefs, AbstractIndividual
using ..Beliefs: BetaBeliefs, BetaBeliefParams, expectations, update_beliefs
using ..ObservationRules: TallyObservations

using LightGraphs

struct MyopicIndividual{BT <: AbstractBeliefs} <: AbstractIndividual
    beliefs:: BT
end

const BetaIndividual = MyopicIndividual{BetaBeliefs}

BetaIndividual(beliefParams::BetaBeliefParams) = BetaIndividual(BetaBeliefs(beliefParams))

# Returns index (id) of chosen action based on internal belief distributions and decision process
function select_fact_to_observe(indiv::BetaIndividual)::Int
    # Myopic / greedy decision making
    return argmax(expectations(indiv.beliefs))
end

function begin_observation(indiv::BetaIndividual, num_facts::Int64) where {IT <: AbstractIndividual}
    return TallyObservations(num_facts)
end

function should_observe(indiv::BetaIndividual, g::AbstractGraph, idToObserve::Int, indivToObserve::BetaIndividual)::Bool
    return true
end

function pick_audience(indiv::BetaIndividual, g::AbstractGraph, id::Int)
    # Send to all listening neigbhors
    return inneighbors(g, id)
end

function update_with_observations(indiv::BetaIndividual, observations::TallyObservations)::BetaIndividual
    return BetaIndividual(update_beliefs(indiv.beliefs, observations))
end

observation_rule() = TallyObservations

export BetaIndividual, TrialResult, TrialCounts, update_with_results, select_fact_to_observe, expectations, begin_observation, pick_audience, should_observe, update_with_observations

end
