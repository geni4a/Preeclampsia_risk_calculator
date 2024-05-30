using Plots, CSV, DataFrames

# read and dataframe
df = DataFrame(CSV.File("/oscar/data/methods2024/2_projects/m24t06-Laborats/final_presentation/csv_files/final_for_real2.csv", header=1, delim=","))

# group
race_counts = combine(groupby(df, :race_source_value), nrow => :count)


#legend_labels = [string(labels[i], " (", percentages[i], "%)") for i in 1:length(labels)]

labels = race_counts.race_source_value
sizes = race_counts.count

# creat
p = pie(labels, sizes, title="Pie Chart of Races", leg=false)

# add legend
annotate!([(0.05, 0.8, text("Legend:", :left, 12)),
            (0.5, 0.75, text("Blue: White(84.89%)", :left, 10)),
            (0.5, 0.65, text("Gold: Asian(3.63%)", :left, 10)),
            (0.5, 0.55, text("Green: Black(7.74%)", :left, 10)),
            (0.5, 0.45, text("Teal: Hawaiian(1.37%)", :left, 10)),
            (0.5, 0.35, text("Pink: Native(0.97%)", :left, 10)),
            (0.5, 0.25, text("Salmon: Other(1.39%)", :left, 10)),
           ])

# save
savefig(p, "csv_files/piechart_racecount_final.png")

#plots: annotate function manually input percentages


