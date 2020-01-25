include("./test_fixture.jl")

using NetworkEpistemology
using StatsPlots, LightGraphs, Printf, Distributions, DataFrames

cycle_spec = TransientDiversityExperimentSpec(
    TransientDiversityModelState(SimpleDiGraph(cycle_graph(500)), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4)),
    10000,
    100,
    100
)
cycle_results = run_experiment(cycle_spec)
@save "cycle-500-results.jld2" cycle_results
