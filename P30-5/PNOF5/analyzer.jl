using YAML
using Printf
using Statistics

wd = split(pwd(), "/")
nof = wd[end]
superset = wd[end-1]

data = YAML.load_file("Reactions.yaml")
data = sort(collect(pairs(data)))
sets = YAML.load_file("Sets.yaml")
natoms = parse(Int, split(superset, "-")[2])

function build_path(rootdir, setname, nof, filename)
    # Construct the path to the output file.
    # The path is constructed by joining the root directory, set name, nof, and filename.

    path = joinpath("/", rootdir, setname, nof, filename * ".out")
    return path
end

function get_nof_fromfile(file)
    # Try to open the file and get the NOF ENergy. If it does not success, return 0.

    try
        Emol = 0
        open(file, "r") do fmol
            for linemol in readlines(fmol)
                if occursin("Final NOF", linemol)
                    Emol = parse(Float64, split(linemol)[6])
                end
            end
        end
        return Emol
    catch
        return 0
    end
end

function get_nof_E(nof, filename)
    # Try to get the NOF energy.
    # First, it looks the exact filename in P30-5, P30-10, and P30-20.
    # If it does not find, it looks the molecule in the other reactions within the same set.

    # Root directory. First part is empty. Last two parts are set and nof
    fileparts = split(pwd(), "/")[2:end-2]
    rootdir = join(fileparts, "/")

    # Look exact filename in all sets
    for setname in ["P30-5", "P30-10", "P30-20"]
        dir = build_path(rootdir, setname, nof, filename[1:end-4]) # end-4 to remove xyz
        Emol = get_nof_fromfile(dir)
        if Emol < 0
            return Emol
        end
    end

    # look the molecule in all reactions within the same set
    # only molecules start with capital letter
    molparts = split(filename[1:end-4], "_")
    if 'A' <= molparts[1][1] <= 'Z'
        for setname in ["P30-5", "P30-10", "P30-20"]
            for i in 1:200
                molparts[2] = string(i)
                mol = join(molparts, "_")
                dir = build_path(rootdir, setname, nof, mol)
                Emol = get_nof_fromfile(dir)
                if Emol < 0
                    println(filename[1:end-4], " not found, using ", mol, " in ", setname)
                    return Emol
                end
            end
        end
    end

    println("Energy not found:", filename)
    return 0
end

# Print Sets and its descriptions
results = Dict()
for (name, reaction) in data
    set_name, system_name = split(name, ":")
    results[set_name] = sets[set_name]
end
for (set_name, set_description) in results
    println("$set_name: $set_description")
    results[set_name] = Dict()
end

# Build structure for YAML file.
####################################################################
# - Sets: Each set has many systems (reactions) labeled by a number
#   Each system has:
#     - dE_Ref: Reaction Reference energy
#     - dE_NOF: Reaction Reference energy
#     - AD: Absolute Deviation
#     - APD: Absolute Percentage Deviation
#     - Species: Molecules
#       Each molecule has:
#         - E_NOF: NOF Energy
#         - Count: Stechiometry in reaction
####################################################################
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
            E_NOF = get_nof_E(nof, filename)
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

YAML.write_file(superset * "-" * nof * ".yaml", results)

#### Print results in terminal (just for visualization of data)

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

# For plotting

using Plots

function plot_bar(data, ylabel, ylims)
    cg = cgrad(:RdYlGn, rev=true)
    colors = get.(Ref(cg), (values(data) .- minimum(values(data))) ./ maximum(values(data)))
    set_names = collect(keys(data))
    p = bar(
        set_names,
        collect(values(data)),
        title=nof,
        ylabel=ylabel,
        ylims=ylims,
        xrotation=90,
        xticks=(0.5:1:size(set_names)[1], set_names),
        color=colors,
        legend=false,
    )
    display(p)
end

plot_bar(MADs, "Mean Abs. Dev. (kcal/mol)", (0, 40))
println("Press the enter key to quit:")
readline()

plot_bar(MAPDs, "MAPD (%)", (0, 100))
println("Press the enter key to quit:")
readline()