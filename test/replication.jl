module WorldsTests
import Base.Threads.@threads

using ..NetworkEpistemology.Core
using ..NetworkEpistemology.Facts
using ..NetworkEpistemology.ObservationRules
using ..NetworkEpistemology.Individuals
using ..NetworkEpistemology.Beliefs
using ..NetworkEpistemology.TestBench
using ..NetworkEpistemology.TransientDiversityModel: step_model, TransientDiversityModelState

using Test, Distributions, LightGraphs, Printf, DataFrames, CSV
import Base.Threads.@spawn

cycle_params = [TransientDiversityModelState(SimpleDiGraph(cycle_graph(i)), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4)) for i in 4:12]

complete_params = [
    TransientDiversityModelState(SimpleDiGraph(complete_graph(i)), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4))
    for i in 3:11]

wheel_params = [
    TransientDiversityModelState(
        SimpleDiGraph(wheel_graph(i)), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4))
    for i in 4:12]

struct TransientDiversityStepStats
    agree::Bool
    fractionCorrect::Rational{Int8}
    totalBeliefChange::Float64
end

function evaluate_step(cur::TransientDiversityModelState, prev::TransientDiversityModelState)::TransientDiversityStepStats
    correct_action = argmax(cur.facts.actionProbabilities)

    number_correct = 0
    total_change = 0.0
    for i in 1:length(cur.individuals)
        if select_fact_to_observe(cur.individuals[i]) == correct_action
            number_correct += 1
        end
        total_change += sum(
            abs.(expectations(cur.individuals[i].beliefs) .- expectations(prev.individuals[i].beliefs))
        )
    end
    fraction = number_correct // length(cur.individuals)

    return TransientDiversityStepStats(
        fraction == 1,
        fraction,
        total_change
    )
end

function should_stop(stats::TransientDiversityStepStats)::Bool
    return false
end

@gen_test_fixture TransientDiversityModelState TransientDiversityStepStats TransientDiversity

@gen_df_helper TransientDiversityStepStats TransientDiversityExperimentSpec agree

@gen_df_helper TransientDiversityStepStats TransientDiversityExperimentSpec fractionCorrect

@gen_df_helper TransientDiversityStepStats TransientDiversityExperimentSpec totalBeliefChange

function calculate_agreement_ratio(experimentSpec)
    println(experimentSpec.initialState.structure)
    results = run_experiment(experimentSpec)
    ratio = mean([res.agree for res in results[:, end]])
    println(ratio)
    println()
    return ratio
end

function run_test(params, correct_results, epsilon)
    for (param, correct_result) in zip(params, correct_results)
        graph_size = nv(param.structure)
        @testset "Graph size: $graph_size" begin
            result = calculate_agreement_ratio(TransientDiversityExperimentSpec(
                param,
                10000,
                10000,
                300
            ))
            @test result < correct_result + epsilon
            @test result > correct_result - epsilon
        end
    end
end

function train_test(params, filename)
    results = DataFrame(
        GraphSize = [nv(param.structure) for param in params],
        PrbAgree = [
            calculate_agreement_ratio(TransientDiversityExperimentSpec(
                param,
                10000,
                1,
                3000
            )) for param in params], # We use even higher precision than Zollman so test values are trustworthy
    )
    CSV.write(filename, results)
end

const TRAIN = true
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
