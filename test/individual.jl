module IndividualTests
import ..NetworkEpistemology

using NetworkEpistemology.Individuals

using Test, Distributions

@testset "Individual" begin
    indiv = BetaIndividual(1, 3, Uniform(0, 4), Uniform(0, 4))

    results = Vector{TrialResult}([
        TrialResult(1, 1, 10, 20),
        TrialResult(1, 2, 1, 2),
        TrialResult(1, 3, 20, 30),
        TrialResult(1, 3, 3, 4),
        TrialResult(1, 2, 11, 22),
    ])

    groupedResults = group_results_by_action(results)

    @test groupedResults[1] == TrialCounts((10, 20))
    @test groupedResults[2] == TrialCounts((12, 24))
    @test groupedResults[3] == TrialCounts((23, 34))
end
end
