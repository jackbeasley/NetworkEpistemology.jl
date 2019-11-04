module WorldsTests
import ..NetworkEpistemology

using NetworkEpistemology.Worlds
using NetworkEpistemology.Individuals

using Test, Distributions, LightGraphs

@testset "Worlds" begin
    world = World(cycle_graph(10), 1000, [0.1, 0.3], Uniform(0, 4), Uniform(0, 4))

    for _ in 1:10
        println([select_action(indiv) for indiv in world.individuals])
        step_world(world)
    end

    for action_selected in [select_action(indiv) for indiv in world.individuals]
        @test action_selected == 2
    end

end

end
