
include("./test_fixture.jl")

using NetworkEpistemology
using StatsPlots, LightGraphs, Printf, Distributions, DataFrames, IterableTables, EzXML, GraphIO

g = loadgraph("social_epistemology.graphml", "digraph", GraphIO.GraphML.GraphMLFormat())
ug = union(reverse(g), g)
comp = ug[connected_components(ug)[1]]

social_spec = TransientDiversityExperimentSpec(
    TransientDiversityModelState(comp, 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4)),
    10000,
    100,
    100
)
social_results = run_experiment(social_spec)

@save "social-results-directed.jld2"  social_results g ug comp