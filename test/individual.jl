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

    groupedResults = group_results_by_action(1, results1)

    @test groupedResults == ([10, 12, 23], [20, 24, 34])

    results2 = Vector{TrialResult}([
        TrialResult(1, 1, 10, 20),
        TrialResult(1, 2, 1, 2),
        TrialResult(1, 2, 11, 22),
    ])

    indiv = BetaIndividual(1, [1, 1], [2, 2])
    update_with_results(indiv, results2)
    @test indiv.alphas == [11, 13]
    @test indiv.betas == [12, 14]
end
end
