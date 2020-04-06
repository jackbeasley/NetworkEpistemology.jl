module TransientDiversityModel

using LightGraphs
using Distributions
using ..Interface
using ..Facts
using ..ObservationRules
using ..Individuals
using ..Beliefs

export step_model, TransientDiversityModelState


const TransientDiversityModelState = ModelState{LightGraphs.SimpleDiGraph{Int64}, BinomialActionFacts, BetaIndividual}

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
