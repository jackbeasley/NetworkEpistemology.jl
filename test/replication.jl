module WorldsTests
import ..NetworkEpistemology

using NetworkEpistemology.Worlds
using NetworkEpistemology.WorldTests
using NetworkEpistemology.Individuals

using Test, Distributions, LightGraphs, Printf

cycle_params = [TestSettings(cycle_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4),
80) for i in 4:12]

cycle_correct_results = [
    0.657,
    0.729,
    0.759,
    0.826,
    0.872,
    0.909,
    0.909,
    0.927,
    0.954,
]

complete_params = [
    TestSettings(
        complete_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4),
        80)
    for i in 2:12]

complete_correct_results = [
    0.541,
    0.553,
    0.570,
    0.584,
    0.603,
    0.583,
    0.562,
    0.573,
    0.624,
    0.642,
    0.589,
]

wheel_params = [
    TestSettings(
        wheel_graph(i), 1000, [0.5, 0.499], Uniform(0, 4), Uniform(0, 4),
        80)
    for i in 4:12]

wheel_correct_results = [
    0.608,
    0.637,
    0.696,
    0.730,
    0.765,
    0.812,
    0.844,
    0.863,
    0.878,
]

function run_test(params, correct_results, epsilon)
    for (param, correct_result) in zip(params, correct_results)
        graph_size = nv(param.g)
        @testset "Graph size: $graph_size" begin
            result = test_world(param)
            @test result < correct_result + epsilon
            @test result > correct_result - epsilon
        end
    end
end

@testset "ZollmanReplication" begin
    @testset "Cycle Graphs" begin
        run_test(cycle_params, cycle_correct_results, 0.1)
    end

    @testset "Complete Graphs" begin
        run_test(complete_params, complete_correct_results, 0.1)
    end

    @testset "Wheel Graphs" begin
        run_test(wheel_params, wheel_correct_results, 0.11)
    end
end

end
