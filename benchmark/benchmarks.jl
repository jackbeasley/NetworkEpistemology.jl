using BenchmarkTools, LightGraphs, Distributions

using NetworkEpistemology, NetworkEpistemology.WorldTests, NetworkEpistemology.Worlds

const SUITE = BenchmarkGroup()

SUITE["step"] = BenchmarkGroup([])

struct TestWorldParams
    g::LightGraphs.AbstractGraph
    trialsPerStep::Integer
    actionPrbs::Vector{Float64}
    numTests::Integer
end

test_world_graphs = [
    ("small cycle", cycle_graph(4)),
    ("big cycle", cycle_graph(100)),
    ("small complete", complete_graph(4)),
    ("big complete", complete_graph(100)),
]


test_action_probabilities = [
    ("two action", [0.5, 0.499]),
    ("twenty actions", [i/30.0 for i in 1:20]),
]

test_trials_per_step = [
    ("1 trial per step", 1),
    ("1000 trials per step", 1000)
]

function test_world(world::World, iterations::Integer)
    for _ in 1:iterations
        world = step_world(world)
    end
end

for (graph_label, graph) in test_world_graphs
    for (trials_per_step_label, trials_per_step) in test_trials_per_step
        for (action_probabilities_label, action_probabilities) in test_action_probabilities
            SUITE["step"][
            (graph_label, trials_per_step_label, action_probabilities_label)
            ] = @benchmarkable test_world(w, 100) setup=(
                w = World($graph, $trials_per_step, $action_probabilities, Uniform(0, 4), Uniform(0, 4)))
        end
    end
end
