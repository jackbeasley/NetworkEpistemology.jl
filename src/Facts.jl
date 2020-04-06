module Facts

using Distributions: Binomial

using ..Interface

struct BinomialActionFacts <: AbstractFacts
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

function Interface.num_facts(baf::BinomialActionFacts)
    return length(baf.actionProbabilities)
end

function Interface.observe_fact(baf::BinomialActionFacts, factID::Int)::BinomialActionObservation
    return BinomialActionObservation(
        factID,
        rand(baf.actionDistributions[factID]),
        baf.trialsPerStep
    )
end

export BinomialActionFacts, BinomialActionObservation, num_facts, observe_fact

end