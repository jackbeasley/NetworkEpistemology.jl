module WorldTests

using ..Worlds
using ..Individuals

using LightGraphs, Distributions

struct TestSettings
    g::LightGraphs.AbstractGraph
    trialsPerStep::Integer
    actionPrbs::Vector{Float64}
    alphaDist::Distributions.Distribution
    betaDist::Distributions.Distribution
    numTests::Integer
    numSteps::Integer
end

function run_trial_for_world(world::World, iterations::Integer)
    for _ in 1:iterations
        step_world(world)
    end

    resulting_actions = [select_action(indiv) for indiv in world.individuals]

    return all(elem -> elem == argmax(world.actionProbabilities), resulting_actions)
end

function test_world(s::TestSettings)
    numSuccess = 0
    for _ in 1:s.numTests
        if run_trial_for_world(World(s.g, s.trialsPerStep, s.actionPrbs, s.alphaDist, s.betaDist), s.numSteps)
            numSuccess += 1
        end
    end
    return (numSuccess / s.numTests)
end

export TestSettings, run_trial_for_world, test_world
end
