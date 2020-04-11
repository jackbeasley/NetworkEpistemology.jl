module TransientDiversityModel

using LightGraphs, Distributions
using ..Interface
using ..Facts
using ..ObservationRules
using ..Individuals
using ..Beliefs
using ..TestBench

export step_model, TransientDiversityModelState, TransientDiversityStepStats


const TransientDiversityModelState = ModelState{LightGraphs.SimpleDiGraph{Int64}, BinomialActionFacts{2}, BetaIndividual{2}}

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

struct TransientDiversityStepStats <: TestBench.AbstractStepStats
    agree::Bool
    incorrectNodes::Vector{Int64}
    fractionCorrect::Rational{Int16}
    totalBeliefChange::Float64
end

function Interface.evaluate_step(cur::TransientDiversityModelState, prev::TransientDiversityModelState)::TransientDiversityStepStats
    correct_action = argmax(cur.facts.actionProbabilities)

    number_correct = 0
    total_change = 0.0
    incorrectNodes = Vector{Int64}()
    for i in 1:length(cur.individuals)
        if select_fact_to_observe(cur.individuals[i]) == correct_action
            number_correct += 1
        end
        if select_fact_to_observe(prev.individuals[i]) != correct_action
            append!(incorrectNodes, i)
        end
        total_change += sum(
            abs.(expectations(cur.individuals[i].beliefs) .- expectations(prev.individuals[i].beliefs))
        )
    end
    fraction = number_correct // length(cur.individuals)

    return TransientDiversityStepStats(
        fraction == 1,
        incorrectNodes,
        fraction,
        total_change
    )
end



end
