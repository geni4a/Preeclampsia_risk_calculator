using CSV
using DataFrames
using Dates

# condition codes of interest/
diabetes = 201826
hypertension = 320128
eclampsia = 137613
preeclampsia = 439393

# conds_codes_of_interest = [hypertension]
conds_codes_of_interest = [diabetes, hypertension, eclampsia, preeclampsia]
conds_c_dict = Dict(diabetes => "diabetes", hypertension => "hypertension", eclampsia => "eclampsia_hist", preeclampsia => "preeclampsia_hist")



# input  person files
person_file_name_peds = "/oscar/data/methods2024/0_data/synthea_ri_peds/csv_omop/person.csv"
person_file_name_adult = "/oscar/data/methods2024/0_data/synthea_ri_adult/csv_omop/person.csv"

#condition files
condition_file_name_peds = "/oscar/data/methods2024/0_data/synthea_ri_peds/csv_omop/condition_occurrence.csv"
condition_file_name_adult = "/oscar/data/methods2024/0_data/synthea_ri_adult/csv_omop/condition_occurrence.csv"


#final_concat_file 
adult = "csv_files/adult.csv"
peds = "csv_files/peds.csv"
adult1 = "csv_files/adult2.csv"
peds1= "csv_files/peds2.csv"
adult2 = "csv_files/adult3.csv"
peds2= "csv_files/peds3.csv"


function determine_value(x) #grouping ages
    if x < 18
        return "under_18"
    elseif x < 35
        return "18_35"
    else
        return "35_and_over"
    end
end



function find_patient_conditions(cond_path, cond_file)
    # load df for the condition (either preeclampsia or eclampsia)
    cond_df = CSV.File(cond_file, header = 1) |> DataFrame
    # load df for entire conditoin occurence csv
    cond_occurence_df = CSV.File(cond_path, header = 1) |> DataFrame
    println(nrow(cond_occurence_df))
    println("loaded df")
    # get list of person_ids with preeclampsia/eclampsia
    ids_list = collect(cond_df.person_id)
    filtered_df = filter(row -> row.person_id in ids_list, cond_occurence_df)
    println("ya")
    filt2 = combine(groupby(filtered_df, :person_id), :condition_concept_id => x -> join(x, ","))
    return filt2
end

conds_adults = find_patient_conditions(condition_file_name_adult, adult)
conds_peds = find_patient_conditions(condition_file_name_peds, peds)
println("2/10")
function multiple_occurrences(arr, num)
    count_num = count(x -> x == num, arr)
    return count_num > 1
end

function add_condition_column(df1, df2, condition, cond_name)
    # Extract relevant columns from df2 for faster lookup
    df2_subset = select(df2, [:person_id, :condition_concept_id_function])
    
    # Initialize an empty dictionary to store condition values by person_id
    condition_dict = Dict{Any, Bool}()
    
    # Preprocess df2 to create a dictionary of person_id to condition check
    for row in eachrow(df2_subset)
        id_value = row.person_id
        conditions = parse.(Int, split(row.condition_concept_id_function, ","))
        for cond in conditions
            if cond != 439393
                condition_dict[(id_value, cond)] = true
            elseif multiple_occurrences(conditions, cond)
                condition_dict[(id_value, cond)] = true
            end
        end
    end
    # Initialize an empty array to store the boolean values for condition
    condition_values = Bool[]

    # Iterate over each row in df1
    for row in eachrow(df1)
        id_value = row.person_id
        condition_c = get(condition_dict, (id_value, condition), false)
        push!(condition_values, condition_c)
    end
    
    # Add the condition column to df1
    df1[!, Symbol(cond_name)] = condition_values
    return df1
end
# function add_condition_column(df1, df2, condition, cond_name)
#     # Initialize an empty array to store the boolean values for condition
#     condition_values = Bool[]
#     # Iterate over each row in df1
#     for row in eachrow(df1)
#         # println(index)
#         id_value = row["person_id"]        
#         condition_c = any(
#             row["person_id"] == id_value && condition in parse.(Int, split(row["condition_concept_id_function"], ","))
#              for row in eachrow(df2))
#         # Append the boolean value to the array
#         push!(condition_values, condition_c)
#     end
#     # Add the condition column to df1
#     col_sym = Symbol(cond_name)
#     df1[!, col_sym] = condition_values
#     return df1
#     show(df1)
# end

function condition_extract(cond_df, df2, lst_concept_code, final)
    DF = CSV.File(cond_df, header = 1) |> DataFrame #conditions for all patients with preec + normal
    show(DF)
    println(names(df2))
    for i in lst_concept_code
        println(i)
        println(conds_c_dict[i])
        DF= add_condition_column(DF, df2, i, conds_c_dict[i])
        show(DF)
    end
    DF = sort(DF,[:person_id])
    show(DF)

    CSV.write(final, DF) 
end


function person_extract(per_df, df, df2)
    per_df = CSV.File(per_df, header =1 ) |> DataFrame
    can_df = CSV.File(df, header = 1) |> DataFrame
    id_lst = collect(can_df.person_id)
    per_df2 = filter(row -> row.person_id in id_lst, per_df) #filters for conditions of interest
    bmi_df = CSV.File("csv_files/bmi_first.csv", header = 1) |> DataFrame
    bmi_df.diag_year = Dates.year.(bmi_df.measurement_date)
    rename!(bmi_df, :value_as_number => :bmi)
    per_df2 = select(per_df2, [:person_id, :year_of_birth, :race_source_value, :ethnicity_source_value])
    DF1 = innerjoin(can_df, per_df2, on=:person_id)
    println(nrow(DF1))
    # DF1 = innerjoin(DF1, bmi_df, on = [:person_id,:diag_year])
    println(nrow(DF1))
    DF1.age = DF1.diag_year .- DF1.year_of_birth
    DF1.age_group = map(determine_value, DF1.age)
    # DF1.obesity = DF1.bmi .>= 30
    DF1.pre_eclampsia_rec_occur = DF1.condition_concept_id .== preeclampsia
    # DF1 = select!(DF1, Not([:diag_year, :year_of_birth, :measurement_date]))
    DF1 = select!(DF1, Not([:diag_year, :year_of_birth]))
    CSV.write(df2, DF1)
end





condition_extract(adult, conds_adults,conds_codes_of_interest,adult1)
condition_extract(peds, conds_peds, conds_codes_of_interest, peds1)

person_extract(person_file_name_adult,adult1, adult2)
person_extract(person_file_name_peds,peds1,peds2)
