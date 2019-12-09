using Distributed

function set_workers(n::Int64)
    numWorkers = size(workers())[1]

    if n > numWorkers
        workersToAdd = n - numWorkers
        addprocs(workersToAdd)
    elseif n < numWorkers
        workersToRemove = numWorkers - n
        rmprocs(workers()[end - workersToRemove + 1:end])
    end
    return (workers())
end
@everywhere using Pkg
@everywhere using Revise
@everywhere Pkg.activate(".")

set_workers(12)
##

@everywhere using NetworkEpistemology

@everywhere using NetworkEpistemology.Worlds
@everywhere using NetworkEpistemology.Individuals
@everywhere using NetworkEpistemology.WorldTests
##
@everywhere using LightGraphs, Distributions, DataFrames, CSV, GraphIO

##
@time test_world(
TestSettings(cycle_graph(100), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4), 10))

##
@time test_world_t(cycle_graph(4), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4), 1000)

##
cycle_params = [TestSettings(cycle_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4),
1000) for i in 4:12]
@time cycle_results = pmap(test_world, cycle_params)

##
complete_params = [
    TestSettings(
        complete_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4),
        1000)
    for i in 2:12]
@time complete_results = pmap(test_world, complete_params)
##
wheel_params = [
    TestSettings(
        wheel_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4),
        1000)
    for i in 4:12]
@time wheel_results = pmap(test_world, wheel_params)
##
resultsfig3 = DataFrame(
    Size = collect(2:12),
    Cycle = [missing, missing, cycle_results...],
    Complete = complete_results,
    Wheel = [missing, missing, wheel_results...]
)
##
CSV.write("figure3-data.csv", resultsfig3)

##
graphs_of_size_6 = collect(values(loadgraphs("graph6c.g6", GraphIO.Graph6.Graph6Format())))
all_6_graphs_params = [TestSettings(g, 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4), 1000)
    for g in graphs_of_size_6]
@time all_6_graphs_results = pmap(test_world, all_6_graphs_params)
##
resultsfig4 = DataFrame(
    Density = collect([LightGraphs.density(g) for g in graphs_of_size_6]),
    Probability = all_6_graphs_results,
)
CSV.write("figure4-data.csv", resultsfig4)
##
cycle_priors_params = [TestSettings(cycle_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 1000:1000:10000]
@time cycle_priors_results = pmap(test_world, cycle_priors_params)
##
complete_priors_params = [TestSettings(complete_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 1000:1000:10000]
@time complete_priors_results = pmap(test_world, complete_priors_params)
##
wheel_priors_params = [TestSettings(wheel_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 1000:1000:10000]
@time wheel_priors_results = pmap(test_world, wheel_priors_params)
##
resultsfig6 = DataFrame(
    MaxPrior = collect(1000:1000:10000),
    Cycle = cycle_priors_results,
    Complete = complete_priors_results,
    Wheel = wheel_priors_results
)
##
CSV.write("figure6-data.csv", resultsfig6)


##
cycle_priors_small_params = [TestSettings(cycle_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 10:10:100]
@time cycle_priors_small_results = pmap(test_world, cycle_priors_small_params)
##
complete_priors_small_params = [TestSettings(complete_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 10:10:100]
@time complete_priors_small_results = pmap(test_world, complete_priors_small_params)
##
wheel_priors_small_params = [TestSettings(wheel_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 10:10:100]
@time wheel_priors_small_results = pmap(test_world, wheel_priors_small_params)
##
resultsfig6_small = DataFrame(
    MaxPrior = collect(10:10:100),
    Cycle = cycle_priors_small_results,
    Complete = complete_priors_small_results,
    Wheel = wheel_priors_small_results
)
##
CSV.write("figure6_small-data.csv", resultsfig6_small)

##
cycle_priors_med_params = [TestSettings(cycle_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 100:100:1000]
@time cycle_priors_med_results = pmap(test_world, cycle_priors_med_params)
##
complete_priors_med_params = [TestSettings(complete_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 100:100:1000]
@time complete_priors_med_results = pmap(test_world, complete_priors_med_params)
##
wheel_priors_med_params = [TestSettings(wheel_graph(7), 1000, [0.5, 0.499], Uniform(0, maxPrior), Uniform(0, maxPrior),
1000) for maxPrior in 100:100:1000]
@time wheel_priors_med_results = pmap(test_world, wheel_priors_med_params)
##
resultsfig6_med = DataFrame(
    MaxPrior = collect(100:100:1000),
    Cycle = cycle_priors_med_results,
    Complete = complete_priors_med_results,
    Wheel = wheel_priors_med_results
)
##
CSV.write("figure6_med-data.csv", resultsfig6_med)
