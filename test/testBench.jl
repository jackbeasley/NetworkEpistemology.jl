module BenchTests

using Test, Printf, DataFrames

using ..NetworkEpistemology

struct TestModelState <: AbstractModelState
    value::Int
end

function step_model(state::TestModelState)::TestModelState
    return TestModelState(2 * state.value)
end

struct TestModelStepStats <: AbstractStepStats
    change::Int
end

function evaluate_step(cur::TestModelState, prev::TestModelState)::TestModelStepStats
    return TestModelStepStats(cur.value - prev.value)
end

function should_stop(stats::TestModelStepStats)::Bool
    return stats.change >= 100
end

@gen_test_fixture TestModelState TestModelStepStats Test

@gen_df_helper TestModelStepStats TestExperimentSpec change

@testset "Verify Test Experiment" begin

    spec = TestExperimentSpec(
        TestModelState(1),
        10,
        2,
        4
    )

    results = run_experiment(spec)
    expectedResults = [
        TestModelStepStats(3) TestModelStepStats(12) TestModelStepStats(48) TestModelStepStats(192) TestModelStepStats(0);
        TestModelStepStats(3) TestModelStepStats(12) TestModelStepStats(48) TestModelStepStats(192) TestModelStepStats(0);
        TestModelStepStats(3) TestModelStepStats(12) TestModelStepStats(48) TestModelStepStats(192) TestModelStepStats(0);
        TestModelStepStats(3) TestModelStepStats(12) TestModelStepStats(48) TestModelStepStats(192) TestModelStepStats(0);
    ]
    @test results == expectedResults

    df = change_by_run_df(results, spec)

    expectedDf = DataFrame(
        StepNumber = [1, 3, 5, 7, 9],
        Run1 = [3, 12, 48, 192, 0],
        Run2 = [3, 12, 48, 192, 0],
        Run3 = [3, 12, 48, 192, 0],
        Run4 = [3, 12, 48, 192, 0],
    )
    @test df == expectedDf
end


end