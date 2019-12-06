module Worlds

using LightGraphs
using Distributions
using ..Individuals

# TODO: Generalize

#mutable struct World{AT <: Distributions.Distribution, IT <: Individuals.Individual}
#    structure::LightGraphs.AbstractGraph
#    individuals::Vector{IT}
#    actions::Vector{AT}
#end

struct ModelState{ST, FT, IT}
    structure::ST
    facts::FT
    individuals::Vector{IT}
end

# ################## <Facts> ##################

# TODO: StaticArrays
struct BinomialActionFacts
    actionProbabilities::Vector{Float64}
    actionDistributions::Vector{Binomial}
    trialsPerStep::Int
end

BinomialActionFacts(actionPrbs::Vector{Float64}, trialsPerStep::Int) = BinomialActionFacts(
    actionPrbs,
    [Binomial(trialsPerStep, actionPrb) for actionPrb in actionPrbs],
    trialsPerStep
)

struct BinomialActionObservation
    factID::Int
    numSuccesses::Int
    numTrials::Int
end


function num_facts(baf::BinomialActionFacts)
    return length(baf.actionProbabilities)
end

function observe_fact(baf::BinomialActionFacts, factID::Int)::BinomialActionObservation
    return BinomialActionObservation(
        factID,
        rand(baf.actionDistributions[factID]),
        baf.trialsPerStep
    )
end

# ################## </Facts> ##################

# ################## <TO MOVE TO INDIV> ##################

# TODO: StaticArrays
mutable struct TotalObservations
    numSuccesses::Vector{Int}
    numTrials::Vector{Int}
end

TotalObservations(numActions::Int) = TotalObservations(Vector([0 for _ in 1:numActions]), Vector([0 for _ in 1:numActions]))

# TODO: Functional vs mutable style
function observe_results(baf::BinomialActionObservation, observations_ref::TotalObservations)
    observations_ref.numSuccesses[baf.factID] += baf.numSuccesses
    observations_ref.numTrials[baf.factID] += baf.numTrials
end

# ################## </TO MOVE TO INDIV> ##################

const ZollmanModelState = ModelState{LightGraphs.SimpleGraph, BinomialActionFacts, BetaIndividual}

ZollmanModelState(g::LightGraphs.AbstractGraph, trialsPerStep::Integer, actionPrbs::Vector{Float64}, 
    alphaDist::Distributions.Distribution, betaDist::Distributions.Distribution) = ZollmanModelState(
        g,
        BinomialActionFacts(actionPrbs, trialsPerStep),
        [BetaIndividual(i, size(actionPrbs)[1], alphaDist, betaDist) for i in 1:nv(g)]
)

function step_model(prev::ZollmanModelState)::ZollmanModelState
    per_individual_observations = [TotalObservations(num_facts(prev.facts)) for _ in 1:length(prev.individuals)]
    for indiv in prev.individuals
        # TODO: Action -> Fact to observe
        actionID = select_action(indiv)
        observation = observe_fact(prev.facts, actionID)
        observe_results(observation, per_individual_observations[indiv.id])

        # Send observations to everyone who can access them (in theory observe_results could ignore results)
        for neighborID in inneighbors(prev.structure, indiv.id)
            observe_results(observation, per_individual_observations[neighborID])
        end
    end

    new_individuals = [update_with_observations(indiv, observation) for (indiv, observation) in zip(prev.individuals, per_individual_observations)]
    return ZollmanModelState(
        prev.structure,
        prev.facts,
        new_individuals
    )
end



# TODO: vectorize with StaticArrays
function update_with_observations(indiv::BetaIndividual, observations::TotalObservations)
    new_alpha_values = copy(indiv.alphaValues)
    new_beta_values = copy(indiv.betaValues)
    for actionID in 1:length(indiv.alphaValues)
        numSuccesses = observations.numSuccesses[actionID]
        numTrials = observations.numTrials[actionID]
        new_alpha_values[actionID] += numSuccesses
        new_beta_values[actionID] += numTrials - numSuccesses
    end
    return BetaIndividual(indiv.id, new_alpha_values, new_beta_values)
end

export ZollmanModelState, step_model

end
