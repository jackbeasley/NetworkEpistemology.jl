module Core

using LightGraphs

abstract type AbstractFacts end

# Determines how Facts are interpreted. Defined in terms of a specific Facts.
abstract type AbstractObservationRule end

abstract type AbstractBeliefs end

abstract type AbstractIndividual end

struct ModelState{ST <: AbstractGraph, FT <: AbstractFacts, IT <: AbstractIndividual}
    structure::ST
    facts::FT
    individuals::Vector{IT}
end

function num_facts
end

function begin_observation
end

macro step(expr)
    modelStateType = expr.args[1].args[1]

    return esc(:(
        $(expr);
        function step_model(prev::$(modelStateType))::$(modelStateType)
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
            return $(modelStateType)(
                prev.structure,
                prev.facts,
                new_individuals
            )
        end
    ))
end

export Facts, ObservationRule, Beliefs, Individual, ModelState, @step

end