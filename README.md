## Laborats Preeclampsia Risk Calculator

This project aimed to develop an app enabling pregnant users to input their age, race, ethnicity, by selecting diagnosed medical conditions such as diabetes or hypertension in order to determine their risk of developing preeclampsia. Utilizing drop-down menus with preloaded answer choices, the app ensures ease of selection, requiring no prior knowledge for operation.
The primary goal of the project is to assist pregnant patients in gauging their risk of preeclampsia, prompting them to seek further medical guidance if necessary. It's crucial to note that the app is designed for risk assessment purposes only and does not diagnose preeclampsia. It informs patients if they may have an elevated risk based on provided data.
While the app is still in its infancy stage, it introduces a novel approach to determining maternal risk by providing an at home assessment tool. Beyond age, race, ethnicity, diabetes, and hypertension, additional demographic and medical factors may be considered in the risk assessment in future iterations.



## Code files

### Preprocessing
extract_preg_info.jl 
- This file contains the condition_concept codes for normal pregnancy and preeclampsia. This information is used to extract patients in both peds and adults from condition occurence whose most recent pregnancies match either. Two dataframes(peds and adults) result containing person_id, condition_concept_id and diagnosis_year.


extract_risk_info.jl
-This file contains the condition_concept codes for eclampsia, preeclampsia, diabetes and hypertension. These codes are used to add columns to the dataframes above indicating patient history with these conditions. Afterwards, patients' race, ethnicity and year of birth are extracted from person.csv. Age columns is added by subtracting year of birth from year of diagnosis and filed under the following categories: under 18(young maternal age), 18-35 and 35_and_over(advanced maternal age).


one_hot_encode.jl
-  This file takes categorical columns and one hot-encodes them: these columns are race, ethnicity and age_group. It also turns boolean columns(history of preeclampsia, eclampsia, diabetes and hypertension) into 0s(false) and 1s(true). 

concat_peds_adults.jl
-The peds and adults dataframe from above are vertically concatenated in this file. The suffix "peds" is added to the person_ids of the peds patients to differentiate between the two. 


### Data analysis

data_analysis_glm.jl
- This file contains the GLM package used on the dataset and the concatenated dataframe from preprocessing. The features are described as all columns excluding age and recent_occurence_of_preeclampsia. The label column is the recent_occurence_of_preeclampsia. The dataset is randomly sorted into training and test data on a 70%/30% split. A binary logistic regression is run on the training dataset and tested on the testing dataset. The coefficients are then stored in a json file to be used in the FHIR app. 

data_analysis_xgboost.jl
- This file contains the XGBoost pakage used on the dataset and the concatenated dataframe from preprocessing. The features are described as all columns excluding age and recent_occurence_of_preeclampsia. The label column is the recent_occurence_of_preeclampsia. The dataset is randomly sorted into training and test data on a 70%/30% split. A binary logistic regression is run on the training dataset and tested on the testing dataset. The feature importance is also displayed to show which features have the most effect on the decision tree. 



### Plots
histogram_code1.jl
-This file includes the code for histograms that depict the frequency of patients sampled in our synthetic dataset over various variables. Stacked histograms of race over age, hypertension status over age, preeclampsia history over race, and preeclampsia history over ethnicity were made using this code.

pie_chart2.jl
-This file contains the code for a pie chart that indicates the proportion of races in our sample data, which can be used to compare it found in real data
### Fhir app
preeclampsia_risk_fhir_app.py
- This file contains the framework for the preeclampsia risk calculator FHIR app. It takes the user inputs (i.e. their age, race, ethnicity, and whether they have certain conditions), and gets the coefficient value for each selection based on our model. Then, it sums up the coefficients and uses the sigmoid function to get a score between 0 and 1. If the score is less that 0.5, the result is considered low risk. If it is greater than or equal to 0.5, the result is considered high risk. 
- To use the app, a user must select an option for each dropdown. If any are left blank and the user hits submit, a message will appear prompting them to select something for each category. If they have selected something for each dropdown and hit submit, the user will be taken to a results page that tells them their score as well as if they are high or low risk. 

preeclampsia_risk_fhir_app.html
- The html for the main page. It includes all of the the dropdown selections.

result_page.html
- The html for the result page. It returns the result as calculated in the main FHIR app python file. It also includes a disclaimer as well as a link for more information on preeclampsia. 

## Getting Started

In order to get started,you will need to ensure Julia is loaded by typing “module load julia”.
Additionally, the following packages need to be installed: 
DataFrames, CSV, Plots, StatsPlots,  Terms and Dates, GLM, Term, Statistics, Random, LinearAlgebra

The preprocessing script contains the julia files needed to prepare data for analysis and can be run using command while inside the final_presentation folder
```
sbatch code_files/preprop_data_analysis.sh
```
To run fhir app:
Go into fhir-apps-synthea_ri directory and run the following commands
```
module load python
source venv/bin/activate
python3 src/preeclampsia_risk_fhir_app.py
```
Open browser and go to http://127.0.0.1:5064

Enter in patient data and hit submit!


### Versioning

Python Version 3
Julia Version 1.9.3

### Contributing

Thank you to the Laborats group consisting of Eugenia, Melinda, Lulu, and Julia as well as Professor Chen, Professor Sarkar, and the teaching assistant team.
