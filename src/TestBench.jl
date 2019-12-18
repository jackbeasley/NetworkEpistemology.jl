module TestBench

using DataFrames, Printf

using ..Core
using ..Individuals

abstract type AbstractStepStats end

abstract type AbstractExperimentSpec end

macro gen_df_helper(stepStatsType, specType, statName)
    functionName = Symbol(@sprintf "%s_by_run_df" statName)
    return esc(:( 
        function $functionName(stats::Matrix{$(stepStatsType)}, spec::$(specType))::DataFrame
            df = DataFrame(
                StepNumber = 1:spec.statCheckInterval:spec.maxSteps,
            )
            for i in 1:size(stats)[1]
                colName = Symbol(@sprintf "Run%d" i)
                df[!, colName] = [stats[i,j].$statName for j in 1:size(stats)[2]]
            end
            return df
        end
    ))
end

macro gen_test_fixture(stateType, stepStatsType, experimentName)

    experimentSpecType = Symbol(@sprintf "%sExperimentSpec" experimentName)

    experimentSpecDef = :(struct $(esc(experimentSpecType))
        initialState::$(esc(stateType))
        maxSteps::Int
        statCheckInterval::Int
        maxTrials::Int
    end)

    runTrialDef = esc(:(function run_trial(spec::$experimentSpecType)::Vector{$stepStatsType}
        stats = Vector{$stepStatsType}(undef, Int(spec.maxSteps/spec.statCheckInterval))
        prevMeasurementState = spec.initialState
        for i in 1:length(stats)
            tmpState = step_model(prevMeasurementState)
            for _ in 2:spec.statCheckInterval
                tmpState = step_model(tmpState)
            end
            stats[i] = evaluate_step(tmpState, prevMeasurementState)
            if should_stop(stats[i])
                finalStepStats = evaluate_step(tmpState, tmpState)
                for j in (i+1):length(stats)
                    stats[j] = finalStepStats
                end
                return stats
            end
            prevMeasurementState = tmpState
        end
        return stats
    end))

    runExperimentDef = esc(:(function run_experiment(spec::$experimentSpecType)::Matrix{$stepStatsType}
        stats = Matrix{$stepStatsType}(undef, 
        (spec.maxTrials, Int(spec.maxSteps/spec.statCheckInterval)))
        for i in 1:spec.maxTrials
            stats[i,:] = run_trial(spec)
        end
        return stats
    end))

    return quote
        $experimentSpecDef

        $runTrialDef

        $runExperimentDef
    end
end

export AbstractStepStats, @gen_df_helper, @gen_test_fixture


end
