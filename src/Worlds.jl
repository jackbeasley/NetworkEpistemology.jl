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
    actionDistributions::Vector{Distribution}
    trialsPerStep::Integer
end

function World(g::LightGraphs.AbstractGraph,
               trialsPerStep::Integer,
               actionPrbs::Vector{Float64},
               alphaDist::Distributions.Distribution, betaDist::Distributions.Distribution)
    individuals = [BetaIndividual(i, size(actionPrbs)[1], alphaDist, betaDist) for i in 1:nv(g)]
    actionDists = [
    Binomial(trialsPerStep, actionPrb) for actionPrb in actionPrbs]
    return World(g, individuals, actionPrbs, actionDists, trialsPerStep)
end

function run_trials(w::World)::Tuple{Matrix{UInt16}, Matrix{UInt16}}
    shape = (length(w.actionProbabilities), length(w.individuals))
    numSuccesses = zeros(UInt16, shape)
    numTrials = zeros(UInt16, shape)

    for indivID in 1:length(w.individuals)
        actionID = select_action(w.individuals[indivID])

        numSuccesses[actionID, indivID] = rand(w.actionDistributions[actionID])
        numTrials[actionID, indivID] = w.trialsPerStep
    end

    return (numSuccesses, numTrials)
end

function step_world(w::World)
    (numSuccesses, numTrials) = run_trials(w)

    for indiv in w.individuals
        neighbors = outneighbors(w.structure, indiv.id)
        append!(neighbors, indiv.id)

        successesByAction = zeros(UInt16, length(w.actionProbabilities))
        trialsByAction = zeros(UInt16, length(w.actionProbabilities))

        for neighborID in neighbors
            for actionID in 1:length(w.actionProbabilities)
                trialsByAction[actionID] += numTrials[actionID, neighborID]
                successesByAction[actionID] += numSuccesses[actionID, neighborID]
            end
        end

        update_with_results(indiv, TrialCountObservations(successesByAction, trialsByAction))
    end
end

export World, run_trials, step_world

end
