module IndividualTest
import ..NetworkEpistemology

using NetworkEpistemology.Individuals

using Test, Distributions, LightGraphs, Printf

@testset "Individual Unit Tests" begin

    test_indiv = BetaIndividual(2, [1, 2, 3, 4], [4, 5, 6, 7])

    true_expecations = [
        mean(Beta(alpha, beta)) for (alpha, beta) in
        zip(test_indiv.alphaValues, test_indiv.betaValues)]

    @test true_expecations == expectations(test_indiv)
    @test argmax(true_expecations) == select_action(test_indiv)

end

end
