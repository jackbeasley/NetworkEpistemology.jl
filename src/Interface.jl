module Interface

using LightGraphs

abstract type AbstractFacts end
abstract type AbstractObservation end
abstract type AbstractObservationRule end
abstract type AbstractIndividual end
abstract type AbstractBeliefs end
abstract type AbstractModelState end

export AbstractFacts, AbstractObservation, AbstractObservationRule, AbstractIndividual, AbstractBeliefs, AbstractModelState


# General fact methods
num_facts(facts::AbstractFacts) = error("No num_facts method found on facts type $(typeof(facts))")
observe_fact(facts::AbstractFacts, actionID::Integer)::AbstractObservation = error("No observe_fact method found on facts type $(typeof(facts))")

export num_facts, observe_fact

# Specify observation behavior of individual for given observation type
begin_observation(indiv::AbstractIndividual, numFacts::Integer)::AbstractObservationRule = error("No begin_observation method defined for individual type $(typeof(indiv))")
observe_results(obs::AbstractObservation, rule::AbstractObservationRule) = error("No observe_results method found for observation type $(typeof(obs)) and observation rule $(typeof(obs))")

export begin_observation, observe_results

select_fact_to_observe(indiv::AbstractIndividual)::Integer = error("No select_fact_to_observe method for individual type $(typeof(indiv))")
pick_audience(indiv::AbstractIndividual, st::LightGraphs.AbstractGraph, id::Integer)::AbstractVector{Integer} = error("No pick_audience method for individual type $(typeof(indiv)) and structure type $(typeof(st))")
function should_observe(indiv::IT, st::LightGraphs.AbstractGraph, neighborId::Integer, neighbor::IT) where {IT <: AbstractIndividual}
    error("No should_observer method for individual type $(typeof(indiv)) and structure type $(typeof(st))")
end
function update_with_observations(indiv::IT, or::AbstractObservationRule)::IT where {IT <: AbstractIndividual}
    error("No update_with_observations method for individual type $(I) and observation rule $(typeof(or))")
end
export select_fact_to_observe, pick_audience, should_observe, update_with_observations

struct ModelState{ST <: AbstractGraph, FT <: AbstractFacts, IT <: AbstractIndividual} <: AbstractModelState
    structure::ST
    facts::FT
    individuals::Vector{IT}
end

evaluate_step(s::AbstractModelState) = error("No evaluate_step method defined for state type $(typeof(s))")

function step_model(prev::ModelState)::ModelState
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
    return ModelState(prev.structure, prev.facts, new_individuals)
end

export ModelState, step_model, evaluate_step

end