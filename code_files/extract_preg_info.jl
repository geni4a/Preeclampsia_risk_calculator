using CSV
using DataFrames
using Dates

#pregnancy code conditions
normal_pregnancy = 4217975
preeclampsia = 439393
major_codes_of_interests = [normal_pregnancy, preeclampsia]
maj_conds_dict = Dict( normal_pregnancy => "normal_pregnancy" , preeclampsia => "pre_eclampsia")
#condition files
condition_file_name_peds = "/oscar/data/methods2024/0_data/synthea_ri_peds/csv_omop/condition_occurrence.csv"
condition_file_name_adult = "/oscar/data/methods2024/0_data/synthea_ri_adult/csv_omop/condition_occurrence.csv"
#save_file 
adult = "csv_files/adult.csv"
peds = "csv_files/peds.csv"
function condition_extract_major(cond_df,lst_concept_code, per_type)
    DF = CSV.File(cond_df, header = 1) |> DataFrame
    DF.diag_year = Dates.year.(DF.condition_start_date)# create a diag_year_of_column
    DF = select(DF, [:person_id, :condition_concept_id,  :diag_year]) 
    DF = filter(row -> row.condition_concept_id in lst_concept_code, DF) #filters for conditions of intest
    DF1 = sort(DF, [:diag_year,:person_id,:condition_concept_id], rev=true) #sort in order of diag year 
    DF2 = unique(DF1, :person_id)
    DF2 = sort(DF2,[:diag_year,:person_id,:condition_concept_id], rev=true)
    CSV.write(per_type,DF2)
end
condition_extract_major(condition_file_name_adult, major_codes_of_interests, adult)
condition_extract_major(condition_file_name_peds, major_codes_of_interests, peds)
