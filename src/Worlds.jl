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

mutable struct World
    structure::LightGraphs.AbstractGraph
    individuals::Vector{BetaIndividual}
    actionProbabilities::Vector{Real}
    trialsPerStep::Integer
end



function World(g::LightGraphs.AbstractGraph,
               trialsPerStep::Integer,
               actionPrbs::Vector{Float64},
               alphaDist::Distributions.Distribution, betaDist::Distributions.Distribution)
    individuals = [BetaIndividual(i, size(actionPrbs)[1], alphaDist, betaDist) for i in 1:nv(g)]
    return World(g, individuals, actionPrbs, trialsPerStep)
end

function run_trials(w::World, indiv::BetaIndividual, numTrials::Number)::TrialResult
    actionID = select_action(indiv)

    numSuccess = rand(Binomial(numTrials, w.actionProbabilities[actionID]))

    return TrialResult(indiv.id, actionID, numSuccess, numTrials)
end

function step_world(w::World)
    trialResults = [run_trials(w, indiv, w.trialsPerStep) for indiv in w.individuals]


    for indiv in w.individuals
        neighbors = outneighbors(w.structure, indiv.id)

        neighborResults = filter(res -> res.individualID == indiv.id || res.individualID in neighbors, trialResults)

        update_with_results(indiv, neighborResults)
    end
end

export World, run_trials, step_world

end
