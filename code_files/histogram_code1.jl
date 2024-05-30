#----------------------------------------------------------------------------------------
using CSV, DataFrames, StatsPlots

df = DataFrame(CSV.File("/oscar/data/methods2024/2_projects/m24t06-Laborats/final_presentation/csv_files/final_for_real2.csv", header=1, delim=","))

age_list = sort(unique(df.age))

#print(age_list)

function helper(age_list)
        true_list = []
        false_list = []
        for i in age_list
                true_count = nrow(filter(row -> row.age == i && row.hypertension == true, df))
                push!(true_list, true_count)

                false_count = nrow(filter(row -> row.age == i && row.hypertension == false, df))
                push!(false_list, false_count)
        end

        return [true_list false_list]

end

hypertension_info = helper(age_list)

ticklabel = Vector(age_list)
p = groupedbar(hypertension_info,
                bar_position = :stack,
                bar_width=0.7,
                xticks=(1:length(ticklabel), ticklabel),  # Corrected xticks
                label=["Hypertension" "No hypertension"],
                xlabel = "Age (years)",
                ylabel = "Number of patients")  # Removed extra closing parenthesis
savefig(p, "5_hypertension_statsplots.png")
------------------------------------------------
function helper2(age_list)
        white_list = []
        black_list = []
        asian_list = []
        native_list = []
        hawaiian_list = []
        other_list = []
        for i in age_list
                white_count = nrow(filter(row -> row.age == i && row.race_source_value == "white", df))
                push!(white_list, white_count)

                black_count = nrow(filter(row -> row.age == i && row.race_source_value == "black", df))
                push!(black_list, black_count)

                asian_count = nrow(filter(row -> row.age == i && row.race_source_value == "asian", df))
                push!(asian_list, asian_count)

                native_count = nrow(filter(row -> row.age == i && row.race_source_value == "native", df))
                push!(native_list, native_count)

                hawaiian_count = nrow(filter(row -> row.age == i && row.race_source_value == "hawaiian", df))
                push!(hawaiian_list, hawaiian_count)

                other_count = nrow(filter(row -> row.age == i && row.race_source_value == "other", df))
                push!(other_list, other_count)
        end

        return [white_list black_list asian_list native_list hawaiian_list other_list]

end

race_info = helper2(age_list)

ticklabel = Vector(age_list)
p = groupedbar(race_info,
                bar_position = :stack,
                bar_width=0.7,
                xticks=(1:length(ticklabel), ticklabel),  # Corrected xticks
                label=["White" "Black" "Asian" "Native" "Hawaiian" "Other"],
                xlabel = "Age (years)",
                ylabel = "Number of patients")  # Removed extra closing parenthesis
savefig(p, "1_race_statsplots.png")

----------------------------------------------------
eth_list = sort(unique(df.ethnicity_source_value))

function helper3(eth_list)
                 preec_list = []
                 no_preec_list = []
                 for i in eth_list
                         preec_count = nrow(filter(row -> row.ethnicity_source_value == i && row.pre_eclampsia_rec_occur == 1, df))
                         push!(preec_list, preec_count)
        
                         no_preec_count = nrow(filter(row -> row.ethnicity_source_value == i && row.pre_eclampsia_rec_occur == 0, df))
                         push!(no_preec_list, no_preec_count)
                        
                 end
        
                 return [preec_list no_preec_list]
        
         end
        
         preec_info = helper3(eth_list)
        
         ticklabel = Vector(eth_list)
         p = groupedbar(preec_info,
                         bar_position = :stack,
                         bar_width=0.7,
                         xticks=(1:length(ticklabel), ticklabel),  # Corrected xticks
                         label=["Most recent pregnancy with preeclampsia" "Most recent pregnancy without preeclampsia"],
                         xlabel = "Ethnicity",
                         ylabel = "Number of patients")  # Removed extra closing parenthesis
         savefig(p, "1_preec_rec_eth_statsplots.png")

#-----------------------------------
 race_list = sort(unique(df.race_source_value))
 function helper4(race_list)
         preec_list = []
         no_preec_list = []
         for i in race_list
                 preec_count = nrow(filter(row -> row.race_source_value == i && row.pre_eclampsia_rec_occur == 1, df))
                 push!(preec_list, preec_count)

                 no_preec_count = nrow(filter(row -> row.race_source_value == i && row.pre_eclampsia_rec_occur == 0, df))
                 push!(no_preec_list, no_preec_count)

         end

         return [preec_list no_preec_list]
 end

 race_info = helper4(race_list)

 ticklabel = Vector(race_list)
 p = groupedbar(race_info,
                 bar_position = :stack,
                 bar_width=0.7,
                 xticks=(1:length(ticklabel), ticklabel),  # Corrected xticks
                 label=["Most recent pregnancy with preeclampsia" "Most recent pregnancy without preeclampsia"],
                 xlabel = "Race",
                 ylabel = "Number of patients")  # Removed extra closing parenthesis
 savefig(p, "1_preec_rec_race_statsplots.png")
       