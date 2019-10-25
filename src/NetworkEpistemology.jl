module NetworkEpistemology
using LightGraphs
using Distributions

# World returns result for selected action back
#function proccess_action_results(indiv::BetaIndividual, results::Vector{TrialResult})

include("Individuals.jl")
#
#end

# TODO: Subtype Individual with constructors for different models/methods

mutable struct World{AT <: Distributions.Distribution, IT <: Individuals.Individual}
    structure::LightGraphs.AbstractGraph
    individuals::Vector{IT}
    actions::Vector{AT}
end

function World(g::LightGraphs.AbstractGraph)
end

end # module

