module TestBench

using DataFrames

using ..Core
using ..Individuals

abstract type AbstractStepStats end

struct ExperimentSpec{MT <: AbstractModelState}
    initialState::MT
    maxSteps::Int
    statCheckInterval::Int
    maxTrials::Int
end

macro step(stateType, stepStatsType, )
end


function run_experiment(spec::ExperimentSpec)::DataFrame

    prevMeasurementState = spec.initialState
    prevState = spec.initialState
    for i in 1:spec.maxTrials
        prevState = step_model(prevState)
        if i % spec.statCheckInterval
            
        end
    end
end

# function run_trial_for_world(state::ModelState, iterations::Integer)
#     for i in 1:iterations
#         state = step_model(state)
#     end
# 
#     resulting_actions = [select_fact_to_observe(indiv) for indiv in state.individuals]
# 
#     return all(elem -> elem == argmax(state.facts.actionProbabilities), resulting_actions)
# end

# function test_world(s::TestSettings, numTests::Int)
#     numSuccess = Threads.Atomic{Int}(0)
#     Threads.@threads for _ in 1:numTests
#         if run_trial_for_world(TransientDiversityModelState(s.g, s.trialsPerStep, s.actionPrbs, s.alphaDist, s.betaDist), s.numSteps)
#             Threads.atomic_add!(numSuccess, 1)
#         end
#     end
#     return (numSuccess[] / numTests)
# end

export AbstractStepStats, ExperimentSpec


end
