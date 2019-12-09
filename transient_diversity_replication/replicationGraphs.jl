using StatsPlots
##
@df CSV.read("figure3-data.csv") plot(
    :Size,
    [:Cycle :Complete :Wheel],
    title="Probablility agents select best action by graph size",
    xlims = (0,12),
    xlabel = "Number of agents in graph",
    ylabel = "Probablility all agents select best action",
    ylims = (0.5,1)
)

##

@df CSV.read("figure4-data.csv") scatter(
    :Density,
    :Probability,
    title="Probablility agents select best action by graph density",
    xlims = (0,1.1),
    xlabel = "Density of size 6 graph",
    ylabel = "Probablility all agents select best action",
    ylims = (0,1.1)
)
