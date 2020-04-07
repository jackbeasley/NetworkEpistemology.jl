module ObservationRules

using StaticArrays
using ..Interface
using ..Facts: BinomialActionObservation

mutable struct TallyObservations{N} <: AbstractObservationRule
    numSuccesses::Vector{Int}
    numTrials::Vector{Int}
end

TallyObservations{N}() where {N} = TallyObservations{N}(zeros(Int, N), zeros(Int, N))

function Interface.observe_results(baf::BinomialActionObservation, observations_ref::TallyObservations{N}) where {N}
    observations_ref.numSuccesses[baf.factID] += Int64(baf.numSuccesses)
    observations_ref.numTrials[baf.factID] += Int64(baf.numTrials)
end

export TallyObservations, observe_results

end