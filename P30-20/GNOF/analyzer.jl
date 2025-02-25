using YAML
using Printf
using Statistics

wd = split(pwd(), "/")
nof = wd[end]
superset = wd[end-1]
######## Change this
data = YAML.load_file("Reactions.yaml")
data = sort(collect(pairs(data)))
sets = YAML.load_file("Sets.yaml")
natoms = parse(Int, split(superset, "-")[2])
#set_names = collect(keys(data))
########

function get_nof_E(filename)
    Emol = 0

    open(nof * ".dat", "r") do fmol
        for linemol in readlines(fmol)
            if filename[1:end-4] == split(linemol)[1]
                Emol = parse(Float64, split(linemol)[2])
            end
        end
    end
    if Emol != 0
        return Emol
    end

    try
        open(filename[1:end-4] * ".out", "r") do fmol
            for linemol in readlines(fmol)
                if occursin("Final NOF", linemol)
                    Emol = parse(Float64, split(linemol)[6])
                end
            end
        end
        println(
            filename[1:end-4] *
            " is not in " *
            nof *
            ".dat but is in " *
            filename[1:end-4] *
            ".out",
        )
    catch
        println(
            filename[1:end-4] *
            " is not in " *
            nof *
            ".dat and " *
            filename[1:end-4] *
            ".out does not exist",
        )
    end

    return Emol
end

results = Dict()
for (name, reaction) in data
    set_name, system_name = split(name, ":")
    results[set_name] = sets[set_name]
end
for (set_name, set_description) in results
    println("$set_name: $set_description")
    results[set_name] = Dict()
end

for (reaction_name, reaction) in data
    set_name, system_name = split(reaction_name, ":")
    dE = 0.0
    dE_NOF = 0.0
    system = Dict()
    system["Species"] = Dict()
    mol_data = system["Species"]

    for info in reaction
        if typeof(info) <: AbstractFloat
            dE = info
            system["dE_Ref"] = dE
        else
            count, filename = info
            molecule_name = filename[1:end-4]
            E_NOF = get_nof_E(filename)
            dE_NOF += count * E_NOF
            mol_data[molecule_name] = Dict("E_NOF" => E_NOF, "Count" => count)
        end
    end
    system["dE_NOF"] = dE_NOF
    AD = min(100, abs(dE - dE_NOF * 627.15))
    APD = min(100, abs(dE - dE_NOF * 627.15) / dE * 100)
    system["AD"] = AD
    system["APD"] = AD
    results[set_name][system_name] = system
end

MADs = Dict()
MAPDs = Dict()
for (set_name, set) in results
    println("--------------------------------------")
    println(set_name)
    println("--------------------------------------")
    ADs = []
    APDs = []
    for (system_name, system) in set
        println("---------------")
        @printf("  %s dE_ref: %.4f \n", system_name, system["dE_Ref"])
        println("---------------")
        molecules = system["Species"]
        dE_NOF = system["dE_NOF"]
        for (molecule_name, molecule) in molecules
            E_NOF = molecule["E_NOF"]
            @printf("    %-20s %3d %10.4f \n", molecule_name, molecule["Count"], E_NOF)
        end
        AD = system["AD"]
        push!(ADs, AD)
        APD = system["APD"]
        push!(APDs, APD)
        @printf("  dE NOF: %.4f   AD: %.1f\n", dE_NOF * 627.15, AD)
    end
    MADs[set_name] = mean(ADs)
    MAPDs[set_name] = mean(APDs)
end

YAML.write_file(superset * "-" * nof * ".yaml", results)

using Plots

cg = cgrad(:RdYlGn, rev = true)
colors = get.(Ref(cg), (values(MADs) .- minimum(values(MADs))) ./ maximum(values(MADs)))
set_names = collect(keys(MADs))
p = bar(
    collect(keys(MADs)),
    collect(values(MADs)),
    title = nof,
    ylabel = "Mean Abs. Dev. (kcal/mol)",
    ylims = (0, 40),
    xrotation = 90,
    xticks = (0.5:1:size(set_names)[1], keys(MADs)),
    color = colors,
    legend = false,
)
display(p)
println("Press the enter key to quit:")
readline()

cg = cgrad(:RdYlGn, rev = true)
colors = get.(Ref(cg), (values(MAPDs) .- minimum(values(MAPDs))) ./ maximum(values(MAPDs)))
p = bar(
    collect(keys(MAPDs)),
    collect(values(MAPDs)),
    title = nof,
    ylabel = "MAPD (%)",
    ylims = (0, 100),
    xrotation = 90,
    xticks = (0.5:1:size(set_names)[1]-0.5, keys(MAPDs)),
    color = colors,
    legend = false,
)
display(p)
println("Press the enter key to quit:")
readline()


#
#
##WTMAD2 = 0
#set_name_old = nothing
#for (name, system) in data
#    set_name, system_name = split(name, ":")
#    if set_name != set_name_old
#        println("--------------------------------------")
#        println(set_name)
#        println("--------------------------------------")
#        global set_name_old = set_name
#    end
#    dE = 0
#    dE_NOF = 0
#    for info in reaction
#        if typeof(info) <: AbstractFloat
#            dE = info
#            println("---------------")
#            @printf("  %s dE_ref: %.4f \n", system_name, dE)
#            println("---------------")
#        else
#            count, filename = info
#            E_NOF = get_nof_E(filename)
#            dE_NOF += count * E_NOF
#            @printf("    %-20s %3d %10.4f \n", filename[1:end-4], count, E_NOF)
#        end
#    end
#    AD = abs(dE - dE_NOF * 627.15)
#    @printf("  dE NOF: %.4f   AD: %.1f\n", dE_NOF * 627.15, AD)#, system["Weight"], system["Weight"]*AD/30)
#end
##WTMAD2 = WTMAD2/nsystems
##@printf("WTMAD2 = %.1f\n", WTMAD2)
##
#using Plots
#
#MADs = Dict()
#set_name_old = nothing
#ADs = []
#for (name, reaction) in data
#    set_name, system_name = split(name, ":")
#    if set_name != set_name_old
#        if (set_name_old != nothing)
#            MADs[set_name_old] = mean(ADs)
#        end
#        global ADs = []
#    end
#    global set_name_old = set_name
#    dE = 0
#    dE_NOF = 0
#    for info in reaction
#        if typeof(info) <: AbstractFloat
#            dE = info
#        else
#            count, filename = info
#            E_NOF = get_nof_E(filename)
#            dE_NOF += count * E_NOF
#        end
#    end
#    AD = abs(dE - dE_NOF * 627.15)
#    push!(ADs, AD)
#end
#MADs[set_name_old] = mean(ADs)
#println(MADs)
#
#
#cg = cgrad(:RdYlGn, rev = true)
#colors = get.(Ref(cg), (values(MADs) .- minimum(values(MADs))) ./ maximum(values(MADs)))
#set_names = collect(keys(MADs))
#p = bar(
#    collect(keys(MADs)),
#    collect(values(MADs)),
#    title = nof,
#    ylabel = "Mean Abs. Dev. (kcal/mol)",
#    ylims = (0, 40),
#    xrotation = 90,
#    xticks = (0.5:1:size(set_names)[1], keys(MADs)),
#    color = colors,
#    legend = false,
#)
#display(p)
#println("Press the enter key to quit:")
#readline()
#
#MAPDs = Dict()
#set_name_old = nothing
#APDs = []
#for (name, reaction) in data
#    set_name, system_name = split(name, ":")
#    if set_name != set_name_old
#        if (set_name_old != nothing)
#            MAPDs[set_name_old] = mean(APDs)
#        end
#        global APDs = []
#    end
#    global set_name_old = set_name
#    dE = 0
#    dE_NOF = 0
#    for info in reaction
#        if typeof(info) <: AbstractFloat
#            dE = info
#        else
#            count, filename = info
#            E_NOF = get_nof_E(filename)
#            dE_NOF += count * E_NOF
#        end
#    end
#    APD = abs(dE - dE_NOF * 627.15) / dE * 100
#    push!(APDs, APD)
#end
#MAPDs[set_name_old] = mean(APDs)
#println(MAPDs)
#
#cg = cgrad(:RdYlGn, rev = true)
#colors = get.(Ref(cg), (values(MAPDs) .- minimum(values(MAPDs))) ./ maximum(values(MAPDs)))
#p = bar(
#    collect(keys(MAPDs)),
#    collect(values(MAPDs)),
#    title = nof,
#    ylabel = "MAPD (%)",
#    ylims = (0, 100),
#    xrotation = 90,
#    xticks = (0.5:1:size(set_names)[1]-0.5, keys(MAPDs)),
#    color = colors,
#    legend = false,
#)
#display(p)
#println("Press the enter key to quit:")
#readline()
