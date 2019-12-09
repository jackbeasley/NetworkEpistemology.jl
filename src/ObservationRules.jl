module ObservationRules

using ..Core: AbstractObservationRule
using ..Facts: BinomialActionObservation

mutable struct TallyObservations <: AbstractObservationRule
    numSuccesses::Vector{Int}
    numTrials::Vector{Int}
end

TallyObservations(numActions::Int) = TallyObservations(Vector([0 for _ in 1:numActions]), Vector([0 for _ in 1:numActions]))

function observe_results(baf::BinomialActionObservation, observations_ref::TallyObservations)
    observations_ref.numSuccesses[baf.factID] += baf.numSuccesses
    observations_ref.numTrials[baf.factID] += baf.numTrials
end

export TallyObservations, observe_results

end