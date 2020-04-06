module Beliefs

using Distributions: Distribution
using ..Interface: AbstractBeliefs
using ..ObservationRules: TallyObservations
struct BetaBeliefs <: AbstractBeliefs
    alphaValues::Vector{Float64}
    betaValues::Vector{Float64}
end
struct BetaBeliefParams
    numFacts::Int
    alphaDist::Distribution
    betaDist::Distribution
end

BetaBeliefs(params::BetaBeliefParams) = BetaBeliefs(
    [rand(params.alphaDist) for _ = 1:params.numFacts], 
    [rand(params.betaDist) for _ = 1:params.numFacts])

function expectations(beliefs::BetaBeliefs)::Vector{Float64}
    return beliefs.alphaValues ./ (beliefs.alphaValues .+ beliefs.betaValues)
end

function update_beliefs(beliefs::BetaBeliefs, observations::TallyObservations)::BetaBeliefs
    new_alpha_values = beliefs.alphaValues .+ observations.numSuccesses
    new_beta_values = beliefs.betaValues .+ observations.numTrials .- observations.numSuccesses
    return BetaBeliefs(new_alpha_values, new_beta_values)
end

export BetaBeliefs, BetaBeliefParams, expectations, update_beliefs

end