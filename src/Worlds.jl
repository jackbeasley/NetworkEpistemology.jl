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

function run_trials(w::World)::Tuple{Matrix{Int64}, Matrix{Int64}}
    shape = (length(w.individuals), length(w.actionProbabilities))
    numSuccesses = zeros(Int64, shape)
    numTrials = zeros(Int64, shape)

    for indivID in 1:length(w.individuals)
        actionID = select_action(w.individuals[indivID])

        numSuccesses[indivID, actionID] = rand(w.actionDistributions[actionID])
        numTrials[indivID, actionID] = w.trialsPerStep
    end

    return (numSuccesses, numTrials)
end

function step_world(w::World)
    (numSuccesses, numTrials) = run_trials(w)

    for indiv in w.individuals
        neighbors = outneighbors(w.structure, indiv.id)

        successesByAction = zeros(Int64, length(w.actionProbabilities))
        trialsByAction = zeros(Int64, length(w.actionProbabilities))

        for neighborID in neighbors
            for actionID in 1:length(w.actionProbabilities)
                successesByAction[actionID] += numSuccesses[neighborID, actionID]
                trialsByAction[actionID] += numTrials[neighborID, actionID]
            end
        end

        for actionID in 1:length(w.actionProbabilities)
            successesByAction[actionID] += numSuccesses[indiv.id, actionID]
            trialsByAction[actionID] += numTrials[indiv.id, actionID]
        end

        #neighborResults = filter(res -> res.individualID in neighbors, trialResults)

        update_with_results(indiv, successesByAction, trialsByAction)
    end
end

export World, run_trials, step_world

end
