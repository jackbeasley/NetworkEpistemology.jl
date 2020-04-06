module TransientDiversityModel

using LightGraphs
using Distributions
using ..Interface
using ..Facts
using ..ObservationRules
using ..Individuals
using ..Beliefs

export step_model, TransientDiversityModelState

struct TransientDiversityModelState <: AbstractModelState
    structure::LightGraphs.SimpleDiGraph
    facts::BinomialActionFacts
    individuals::Vector{BetaIndividual}
end

function Interface.step_model(prev::TransientDiversityModelState)::TransientDiversityModelState
    facts_for_state = num_facts(prev.facts)
    per_individual_observations = [begin_observation(indiv, facts_for_state) for indiv in prev.individuals]
    for (id, indiv) in enumerate(prev.individuals)
        # TODO: Action -> Fact to observe
        actionID = select_fact_to_observe(indiv)
        observation = observe_fact(prev.facts, actionID)
        observe_results(observation, per_individual_observations[id])

        # Send observations to everyone who can access them (in theory observe_results could ignore results)
        for neighborID in pick_audience(indiv, prev.structure, id)
            if should_observe(prev.individuals[neighborID], prev.structure, id, indiv)
                observe_results(observation, per_individual_observations[neighborID])
            end
        end
    end

    new_individuals = [update_with_observations(indiv, observation) for (indiv, observation) in zip(prev.individuals, per_individual_observations)]
    return TransientDiversityModelState(
        prev.structure,
        prev.facts,
        new_individuals)
end

TransientDiversityModelState(
    g::LightGraphs.AbstractGraph, 
    trialsPerStep::Integer, 
    actionPrbs::Vector{Float64}, 
    alphaDist::Distributions.Distribution,
    betaDist::Distributions.Distribution) = TransientDiversityModelState(
        g,
        BinomialActionFacts(actionPrbs, trialsPerStep),
        [BetaIndividual(BetaBeliefParams(size(actionPrbs)[1], alphaDist, betaDist)) for i in 1:nv(g)]
)

end
