module IndividualTest
using ..NetworkEpistemology

using Test, Distributions, LightGraphs, Printf

@testset "Individual Unit Tests" begin

    test_indiv = BetaIndividual(BetaBeliefs([1, 2, 3, 4], [4, 5, 6, 7]))

    true_expectations = [
        mean(Beta(alpha, beta)) for (alpha, beta) in
        zip(test_indiv.beliefs.alphaValues, test_indiv.beliefs.betaValues)]

    @test true_expectations == expectations(test_indiv.beliefs)
    @test argmax(true_expectations) == select_fact_to_observe(test_indiv)

end

end
