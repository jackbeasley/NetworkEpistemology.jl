include("./test_fixture.jl")

using NetworkEpistemology
using StatsPlots, LightGraphs, Printf, Distributions, DataFrames, IterableTables, EzXML, GraphIO

g = loadgraph("social_epistemology.graphml", "digraph", GraphIO.GraphML.GraphMLFormat())
social_spec = TransientDiversityExperimentSpec(
    TransientDiversityModelState(g, 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4)),
    10000,
    100,
    100
)
social_results = run_experiment(social_spec)

@save "social-results-directed.jld2"  social_results g

