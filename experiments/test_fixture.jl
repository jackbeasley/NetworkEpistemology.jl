using NetworkEpistemology, Printf
using GraphPlot, Compose, Cairo, FileIO, Images, VideoIO

struct TransientDiversityStepStats
    agree::Bool
    incorrectNodes::Vector{Int64}
    fractionCorrect::Rational{Int16}
    totalBeliefChange::Float64
end


function evaluate_step(cur::TransientDiversityModelState, prev::TransientDiversityModelState)::TransientDiversityStepStats
    correct_action = argmax(cur.facts.actionProbabilities)

    number_correct = 0
    total_change = 0.0
    incorrectNodes = Vector{Int64}()
    for i in 1:length(cur.individuals)
        if select_fact_to_observe(cur.individuals[i]) == correct_action
            number_correct += 1
        else
            append!(incorrectNodes, i)
        end
        total_change += sum(
            abs.(expectations(cur.individuals[i].beliefs) .- expectations(prev.individuals[i].beliefs))
        )
    end
    fraction = number_correct // length(cur.individuals)

    return TransientDiversityStepStats(
        fraction == 1,
        incorrectNodes,
        fraction,
        total_change
    )
end

function should_stop(stats::TransientDiversityStepStats)::Bool
    return false
end

@gen_test_fixture TransientDiversityModelState TransientDiversityStepStats TransientDiversity

@gen_df_helper TransientDiversityStepStats TransientDiversityExperimentSpec agree

@gen_df_helper TransientDiversityStepStats TransientDiversityExperimentSpec fractionCorrect

@gen_df_helper TransientDiversityStepStats TransientDiversityExperimentSpec totalBeliefChange

function convergence_grouping(step_stats::TransientDiversityStepStats, graph::LightGraphs.AbstractGraph)
    return [i in step_stats.incorrectNodes ? 1 : 2 for i in 1:nv(graph)]
end

function plot_coloring(step_stats::TransientDiversityStepStats, graph::LightGraphs.AbstractGraph, locs_x, locs_y)
    colors = [colorant"red", colorant"green"]
    coloring = colors[convergence_grouping(step_stats, graph)]
    return gplot(graph, locs_x, locs_y, nodefillc=coloring)
end

function rasterize_plot(plot, size=100)
    mktemp() do path,io
        draw(PNG(io, size, size), plot)
        seekstart(io)
        return load(io)
    end
end

function make_image_stack(results::Vector{TransientDiversityStepStats}, graph::LightGraphs.AbstractGraph, layout::Function, size::Int)
    (locs_x, locs_y) = layout(graph)
    return [RGB.(rasterize_plot(plot_coloring(step_stats, graph, locs_x, locs_y), size)) for step_stats in results]
end

function make_video(results::Vector{TransientDiversityStepStats}, graph::LightGraphs.AbstractGraph, layout::Function, size::Int, outfile::String)
    stack = make_image_stack(results, graph, layout, size)
    encodevideo(outfile,stack,framerate=10,AVCodecContextProperties=props, codec_name="libx264")
end