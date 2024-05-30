import requests
import os
import numpy as np
import json
from flask import Flask, request, render_template, redirect, url_for
from dotenv import load_dotenv


app = Flask(__name__)

FHIR_SERVER_BASE_URL="http://pwebmedcit.services.brown.edu:8082/fhir"

load_dotenv()

username = os.getenv("FHIR_USERNAME")
password = os.getenv("FHIR_PASSWORD")

def request_patient(patient_id, credentials):

    req = requests.get(FHIR_SERVER_BASE_URL + "/Patient/" + str(patient_id), auth = credentials)

    print(f"Requests status: {req.status_code}")

    response = req.json()
    print(response.keys())

    return response

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

weights_file_path = "/oscar/data/methods2024/2_projects/m24t06-Laborats/final_presentation/csv_files/weights.json"

with open(weights_file_path, 'r') as file:
    weight_dict = json.load(file)

print(weight_dict)

def assess_risk(age, race, ethnicity, diabetes, hypertension, eclampsia_history, personal_history):
    if age == 'Under 18':
        age_weight = weight_dict["under_18"]
    elif age == '18-35':
        age_weight = weight_dict["bet_18_35"]
    elif age == 'Over 35':
        age_weight = weight_dict["over_35"]
    if race == 'White':
        race_weight = weight_dict["white"]
    elif race == 'Black':
        race_weight = weight_dict["black"]
    elif race == 'Asian':
        race_weight = weight_dict["asian"]
    elif race == 'Native':
        race_weight = weight_dict["native"]
    elif race == 'Hawaiian':
        race_weight = weight_dict["hawaiian"]
    elif race == 'Other':
        race_weight = weight_dict["other"]

    if ethnicity == 'Hispanic':
        ethnicity_weight = weight_dict["hispanic"]
    elif ethnicity == 'Nonhispanic':
        ethnicity_weight = weight_dict["nonhispanic"]

    if diabetes == 'Yes':
        diabetes_weight = 0.135206
    elif diabetes == 'No':
        diabetes_weight = 0

    if hypertension == 'Yes':
        hypertension_weight = weight_dict["hypertension"]
    elif hypertension == 'No':
        hypertension_weight = 0

    if eclampsia_history == 'Yes':
        eclampsia_weight = weight_dict["eclampsia_hist"]
    elif eclampsia_history == 'No':
        eclampsia_weight = 0

    if personal_history == 'Yes':
        preeclampsia_weight = weight_dict["preeclampsia_hist"]
    elif personal_history == 'No':
        preeclampsia_weight = 0

    intercept = weight_dict["(Intercept)"]

    weight = np.sum(np.array([intercept, age_weight, race_weight, ethnicity_weight, diabetes_weight, hypertension_weight, eclampsia_weight, preeclampsia_weight]))
    # print(weight)
    sig_score = sigmoid(weight)

    if sig_score < 0.5:
        result = 'low risk'
    else:
        result = 'high risk'

    return sig_score, result




@app.route('/', methods=['GET', 'POST'])
def index():

    result = None
    credentials = (username, password)

    if request.method == 'POST':

        # if request.method == 'POST':
        # Check if all dropdowns are selected
        if all(request.form.get(key) != '-' for key in ['age', 'race', 'ethnicity', 'diabetes', 'hypertension', 'eclampsia history', 'personal_history']):
            age = request.form['age']
            race = request.form['race']
            ethnicity = request.form['ethnicity']
            diabetes = request.form['diabetes']
            hypertension = request.form['hypertension']
            eclampsia_history = request.form['eclampsia history']
            personal_history = request.form['personal history']

        # Perform risk assessment
            score, risk_result = assess_risk(age, race, ethnicity, diabetes, hypertension, eclampsia_history, personal_history)
            
            result = f'Your overall score is {score}. You are at {risk_result} for preeclampsia'

            return redirect(url_for('result_page', result=result))
        
        else:
            # If any dropdown is not selected, render index page with an error message
            result = 'Please select an option for each dropdown.'

    return render_template('preeclampsia_risk_fhir_app.html', result=result)

@app.route('/result', methods=['GET'])
def result_page():
    # Get the result passed from the index page
    result = request.args.get('result', 'Waiting for results')

    # Render the result page template with the calculated result
    return render_template('result_page.html', result=result)


if __name__ == '__main__':
    port_str = os.environ['FHIR_PORT']
    port_int = int(port_str)
    app.run(debug=True, port=port_int)
