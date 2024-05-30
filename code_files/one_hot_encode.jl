using DataFrames
using CSV


# Load CSV file into a DataFrame
df = CSV.read("csv_files/final_for_real.csv", DataFrame)

function main(df_path, col_list)
    df = CSV.read(df_path, DataFrame)


    for col in col_list
        unique_values = unique(df[!, col])
        
        for value in unique_values
            new_col_name = string(value)  
            
            df[!, new_col_name] = df[!, col] .== value
            
            df[!, new_col_name] = Int.(df[!, new_col_name])
        end 
    end
    CSV.write("csv_files/final_for_real2.csv", df)

end
lst = ["race_source_value", "ethnicity_source_value", "age_group"]
lst2 = [ "diabetes", "eclampsia_hist", "preeclampsia_hist", "hypertension", "pre_eclampsia_rec_occur"]
remove_lst = ["race_source_value", "ethnicity_source_value", "age_group", "person_id", "condition_concept_id"]

main("csv_files/final_for_real.csv", lst)

function main2(df_path, col_list)
    df = CSV.read(df_path, DataFrame)
    for value in col_list
        new_col_name = string(value)  
        
        df[!, new_col_name] = Int.(df[!, new_col_name])
    end 
    df = select!(df, Not(remove_lst))
    CSV.write("csv_files/final_for_real_for_real.csv", df)

end
lst = ["race_source_value", "ethnicity_source_value", "age_group"]

main2("csv_files/final_for_real2.csv", lst2)



