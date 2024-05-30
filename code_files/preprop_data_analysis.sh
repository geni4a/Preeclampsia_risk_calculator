#!/bin/bash
#SBATCH -N 1
#SBATCH --mem=50G
#SBATCH -t 3:00:00
#SBATCH --mail-type=FAIL,END          # Type of email notification: BEGIN,END,FAIL,A$
#SBATCH --mail-user=eugenia_ampofo@brown.edu  #Email where notifications will be sent
#SBATCH -o SLURM/mess%A.out

# cut -d',' -f2,3,4,9 /oscar/data/methods2024/0_data/synthea_ri_adult/csv_omop/measurement.csv | head -1 > csv_files/bmi.csv
# cut -d',' -f2,3,4,9 /oscar/data/methods2024/0_data/synthea_ri_adult/csv_omop/measurement.csv | grep ",3038553," >> csv_files/bmi.csv
# cut -d"," -f1,3,4 csv_files/bmi.csv |sort -uk1,1n > csv_files/bmi_first.csv 


# Load necessary modules
module load julia


#Run julia scripts
julia code_files/extract_preg_info.jl
julia code_files/extract_risk_info.jl
julia code_files/one_hot_encode.jl
julia code_files/concat_peds_adults.jl

#Run data analysis
julia data_analysis_xgboost.jl
julia data_analysis_glm.jl

#run plots
julia code_files/histogram_code1.jl
julia code_files/pie_chart2.jl