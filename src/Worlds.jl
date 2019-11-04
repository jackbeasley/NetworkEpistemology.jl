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

#function run_trials(w::World, indiv::BetaIndividual, numTrials::Number)::TrialResult
#    actionID = select_action(indiv)
#
#    numSuccess = rand(Binomial(numTrials, w.actionProbabilities[actionID]))
#
#    return TrialResult(indiv.id, actionID, numSuccess, numTrials)
#end

function run_trials(w::World)
    shape = (length(w.individuals), length(w.actionProbabilities))
    numSuccesses = zeros(shape)
    numTrials = zeros(shape)

    for (indivID, indiv) in enumerate(w.individuals)
        actionID = select_action(indiv)
        numSuccesses[indivID, actionID] = rand(Binomial(w.trialsPerStep, w.actionProbabilities[actionID]))
        numTrials[indivID, actionID] = w.trialsPerStep
    end

    return (numSuccesses, numTrials)
end

function step_world(w::World)
    (numSuccesses, numTrials) = run_trials(w)

    for indiv in w.individuals
        neighbors = vcat(outneighbors(w.structure, indiv.id), indiv.id)
        update_with_results(indiv,
        vec(sum(numSuccesses[neighbors, :], dims=1)),
        vec(sum(numTrials[neighbors, :], dims=1)))
    end
end

export World, run_trials, step_world

end
