module WorldsTests
import ..NetworkEpistemology
import Base.Threads.@threads

using NetworkEpistemology.Worlds
using NetworkEpistemology.Individuals

using Test, Distributions, LightGraphs, Printf, DataFrames, CSV

struct TestSettings
    g::LightGraphs.AbstractGraph
    trialsPerStep::Integer
    actionPrbs::Vector{Float64}
    alphaDist::Distributions.Distribution
    betaDist::Distributions.Distribution
    numSteps::Int
end

cycle_params = [TestSettings(cycle_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4), 10000) for i in 4:12]

complete_params = [
    TestSettings(
        complete_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4), 10000)
    for i in 3:11]

wheel_params = [
    TestSettings(
        wheel_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4), 10000)
    for i in 4:12]

function run_trial_for_world(state::ZollmanModelState, iterations::Integer)
    for i in 1:iterations
        state = step_model(state)
    end

    resulting_actions = [select_action(indiv) for indiv in state.individuals]

    return all(elem -> elem == argmax(state.facts.actionProbabilities), resulting_actions)
end

function test_world(s::TestSettings, numTests::Int)
    numSuccess = 0
    Threads.@threads for _ in 1:numTests
        if run_trial_for_world(ZollmanModelState(s.g, s.trialsPerStep, s.actionPrbs, s.alphaDist, s.betaDist), s.numSteps)
            numSuccess += 1
        end
    end
    return (numSuccess / numTests)
end

function run_test(params, correct_results, epsilon)
    for (param, correct_result) in zip(params, correct_results)
        graph_size = nv(param.g)
        @testset "Graph size: $graph_size" begin
            result = test_world(param, 250)
            @test result < correct_result + epsilon
            @test result > correct_result - epsilon
        end
    end
end

function train_test(params, filename)
    results = DataFrame(
        PrbAgree = [test_world(param, 1500) for param in params], # We use even higher precision than Zollman so test values are trustworthy
        GraphSize = [nv(param.g) for param in params]
    )
    CSV.write(filename, results)
end

const TRAIN = false
const CYCLE_GRAPH_RESULTS_FILE = "cycle_graphs_test.csv"
const COMPLETE_GRAPH_RESULTS_FILE = "complete_graphs_test.csv"
const WHEEL_GRAPH_RESULTS_FILE = "wheel_graphs_test.csv"

@testset "ZollmanReplication" begin
    @testset "Cycle Graphs" begin
        if TRAIN
            train_test(cycle_params, CYCLE_GRAPH_RESULTS_FILE)
        else
            run_test(cycle_params, CSV.read(CYCLE_GRAPH_RESULTS_FILE).PrbAgree, 0.1)
        end
    end

    @testset "Complete Graphs" begin
        if TRAIN
            train_test(complete_params, COMPLETE_GRAPH_RESULTS_FILE)
        else
            run_test(complete_params, CSV.read(COMPLETE_GRAPH_RESULTS_FILE).PrbAgree, 0.1)
        end
    end

    @testset "Wheel Graphs" begin
        if TRAIN
            train_test(wheel_params, WHEEL_GRAPH_RESULTS_FILE)
        else
            run_test(wheel_params, CSV.read(WHEEL_GRAPH_RESULTS_FILE).PrbAgree, 0.1)
        end
    end
end

end
