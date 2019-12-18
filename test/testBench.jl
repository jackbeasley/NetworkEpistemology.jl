module BenchTests

using Test, Printf, DataFrames

using ..NetworkEpistemology

struct TestModelState <: AbstractModelState
    value::Int
end

function copy(state::TestModelState)::TestModelState
    return TestModelState(state.value)
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

StepStatsType() = TestModelStepStats

const TestExperimentSpec = ExperimentSpec{TestModelState}

struct ExperimentResults{ST <: AbstractStepStats}

end

function run_trial(spec::TestExperimentSpec)::Vector{TestModelStepStats}
    stats = Vector{TestModelStepStats}(undef, Int(spec.maxSteps/spec.statCheckInterval))
    statsIndex = 1
    prevMeasurementState = copy(spec.initialState)
    state = spec.initialState
    for i in 1:spec.maxSteps
        state = step_model(state)
        if i % spec.statCheckInterval == 0
            stats[statsIndex] = evaluate_step(state, prevMeasurementState)
            if should_stop(stats[statsIndex])
                finalStepStats = evaluate_step(state, state)
                for j in (statsIndex+1):length(stats)
                    stats[j] = finalStepStats
                end
                return stats
            end
            prevMeasurementState = copy(state)
            statsIndex += 1
        end
    end
    return stats
end

function run_experiment(spec::TestExperimentSpec)::Matrix{TestModelStepStats}
    stats = Matrix{TestModelStepStats}(undef, 
    (spec.maxTrials, Int(spec.maxSteps/spec.statCheckInterval)))
    for i in 1:spec.maxTrials
        stats[i,:] = run_trial(spec)
    end
    return stats
end

function stat_by_run_df(stats::Matrix{TestModelStepStats}, spec::TestExperimentSpec, statName::Symbol)::DataFrame
    df = DataFrame(
        StepNumber = 1:spec.statCheckInterval:spec.maxSteps,
    )
    for i in 1:size(stats)[1]
        colName = Symbol(@sprintf "Run%d" i)
        df[!, colName] = [getproperty(stats[i,j], statName) for j in 1:size(stats)[2]]
    end
    return df
end

#function to_df(vec::Vector{TestModelStepStats})::DataFrame
#    df = DataFrame(
#    )
#
#    for (i, name) in enumerate(fieldnames(stats[1]))
#        insertcols!(df, i+1, name = [s.name for s in stats])
#    end
#end

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

    df = stat_by_run_df(results, spec, :change)
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