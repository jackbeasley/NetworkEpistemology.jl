module WorldsTests

using ..NetworkEpistemology.Interface
using ..NetworkEpistemology.Facts
using ..NetworkEpistemology.ObservationRules
using ..NetworkEpistemology.Individuals
using ..NetworkEpistemology.Beliefs
using ..NetworkEpistemology.TestBench
using ..NetworkEpistemology.TransientDiversityModel: step_model, TransientDiversityModelState

using Statistics, HypothesisTests
using Test, Distributions, LightGraphs, Printf, DataFrames, CSV

function TestBench.should_stop(stats::TransientDiversityStepStats)::Bool
    return false
end

function test_params(graph::Function, size::Int)
    binomial_probs = [0.5, 0.499]
    return TransientDiversityModelState(
            SimpleDiGraph(graph(size)),
            BinomialActionFacts{2}(binomial_probs, 1000),
            [BetaIndividual{2}(BetaBeliefs{2}(
                [rand(Uniform(0, 4)) for _ = 1:length(binomial_probs)], 
                [rand(Uniform(0, 4)) for _ = 1:length(binomial_probs)]
                )) for i in 1:size]
        )
end

cycle_sizes = collect(4:11)
complete_sizes = collect(3:11)
wheel_sizes = collect(5:11)

function run_test(graph_type::Function, graph_sizes::AbstractVector{Int}, correct_results, epsilon)
    for (graph_size, correct_result) in zip(graph_sizes, correct_results)
        @testset "Graph size: $graph_size" begin
            results = run_experiments([test_params(graph_type, graph_size) for _ in 1:1000], TransientDiversityStepStats, 10000)

            ratio = mean([res.agree for res in results[:, end]])

            (low, high) = confint(BinomialTest([res.agree for res in results[:, end]]); level = .99)
            println(@sprintf "size: %d ratio: %f low: %f high: %f actual: %f" graph_size ratio low high correct_result)
            @test correct_result > low
            @test correct_result < high
        end
    end
end

const CYCLE_GRAPH_RESULTS_FILE = "cycle_graphs_test.csv"
const COMPLETE_GRAPH_RESULTS_FILE = "complete_graphs_test.csv"
const WHEEL_GRAPH_RESULTS_FILE = "wheel_graphs_test.csv"

@testset "ZollmanReplication" begin
    @testset "Cycle Graphs" begin
        run_test(cycle_graph, cycle_sizes, CSV.read(CYCLE_GRAPH_RESULTS_FILE).PrbAgree, 0.1)
    end

    @testset "Complete Graphs" begin
        run_test(complete_graph, complete_sizes, CSV.read(COMPLETE_GRAPH_RESULTS_FILE).PrbAgree, 0.1)
    end

    @testset "Wheel Graphs" begin
        run_test(wheel_graph, wheel_sizes, CSV.read(WHEEL_GRAPH_RESULTS_FILE).PrbAgree, 0.1)
    end
end

end
