using CSV
using DataFrames


#final_concat_file 
adult2 = "csv_files/adult3.csv"
peds2= "csv_files/peds3.csv"
fin = "csv_files/final_for_real.csv"



function conc(df1, df2, name)
    DF1 = CSV.File(df1, header =1 ) |> DataFrame
    DF2 = CSV.File(df2, header =1 ) |> DataFrame
    DF1.person_id = string.(DF1.person_id)
    DF2.person_id = string.(DF2.person_id) .* "peds"
    df = vcat(DF2, DF1)
    CSV.write(name,df)
end

conc(adult2, peds2, fin)