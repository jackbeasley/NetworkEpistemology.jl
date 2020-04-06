module TestBench

using DataFrames, Printf
import Base.Threads.@spawn

using ..Interface
using ..Individuals

abstract type AbstractStepStats end

should_stop(s::AbstractStepStats) = error("No should_stop method defined for step stats type $(typeof(s))")

function run_trial(initialState::StateT, statType::Type{StatT}, maxSteps::Integer, statCheckInterval::Integer = 1)::Vector{StatT} where {StateT <: AbstractModelState, StatT <: AbstractStepStats}
    stats = Vector{StatT}(undef, Int(maxSteps/statCheckInterval))

    prevMeasurementState = initialState
    for i in 1:length(stats)
        tmpState = step_model(prevMeasurementState)
        for _ in 2:statCheckInterval
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
end

function run_experiments(initialStates::Vector{StateT}, statType::Type{StatT}, maxSteps::Integer, statCheckInterval::Integer = 1)::Matrix{StatT} where {StatT<:AbstractStepStats, StateT<:AbstractModelState}
        tasks = [@spawn run_trial(state, statType, maxSteps, statCheckInterval) for state in initialStates]
        results = map(fetch, tasks) # Wait for tasks to complete

        #results = [run_trial(state, statType, maxSteps, statCheckInterval) for state in initialStates]

        stats = Matrix{StatT}(undef, 
        (length(initialStates), Int(maxSteps/statCheckInterval)))
        for (i, trialTask) in enumerate(results)
            stats[i,:] = fetch(trialTask)
        end
        return stats
end

export AbstractStepStats, run_experiments, run_trial


end
