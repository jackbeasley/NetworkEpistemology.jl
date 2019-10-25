module IndividualTests
import ..NetworkEpistemology

using NetworkEpistemology.Individuals
using NetworkEpistemology.Individuals: group_results_by_action, update_with_results

using Test, Distributions

@testset "Individual" begin

    results1 = Vector{TrialResult}([
        TrialResult(1, 1, 10, 20),
        TrialResult(1, 2, 1, 2),
        TrialResult(1, 3, 20, 30),
        TrialResult(1, 3, 3, 4),
        TrialResult(1, 2, 11, 22),
    ])

    groupedResults1 = group_results_by_action(results1)

    @test groupedResults1[1] == TrialCounts((10, 20))
    @test groupedResults1[2] == TrialCounts((12, 24))
    @test groupedResults1[3] == TrialCounts((23, 34))

    results2 = Vector{TrialResult}([
        TrialResult(1, 1, 10, 20),
        TrialResult(1, 2, 1, 2),
        TrialResult(1, 2, 11, 22),
    ])

    indiv = BetaIndividual(1, [Beta(1,2), Beta(1,2)])
    update_with_results(indiv, results2)
    @test indiv.beliefs == [Beta(11,12), Beta(13,14)]
end
end
