using CSV
using DataFrames
using Random
using GLM
using Statistics
using JSON


function sum_df(df, name)
    # Calculate the sum of each column
    column_sums = [sum(col) for col in eachcol(df)]

    # Get column names
    column_names = names(df)
    println(name)
    # Print the sum of each column with its name
    for (name, sum_value) in zip(column_names, column_sums)
        println("$name = $sum_value")
    end
end


data100 = CSV.File("csv_files/final_for_real2.csv", header = 1) |> DataFrame #data with categorical labels in place
data = CSV.File("csv_files/final_for_real_for_real.csv", header = 1) |> DataFrame #data for analysis
sum_df(data, "orig_data")
data = data[:, ["diabetes", "hypertension", "eclampsia_hist", "white", "black", "asian", "native", "hawaiian", "other", "nonhispanic", "hispanic", "under_18", "18_35", "35_and_over","preeclampsia_hist", "age","pre_eclampsia_rec_occur"]
]
data = select!(data, Not(:age)) #exclude age from data
# Print the shape
println("Shape of the array: ", size(data))
# Extract features and labels
features = data[:, 1:end-1]  # All rows, all columns except the last one
labels = data[:, end]        # All rows, only the last column

# Set the seed for reproducibility
Random.seed!(123)

# Shuffle the indices
indices = shuffle(1:size(data, 1))

# Define the split ratio (70% training, 30% testing)
split_ratio = 0.7

# Determine the split indices
split_index = Int(floor(split_ratio * length(indices)))
train_indices = indices[1:split_index]
test_indices = indices[(split_index + 1):end]
# Split the data into training and testing sets
train_features = features[train_indices, :]
train_labels = labels[train_indices]
test_features = features[test_indices, :]
test_labels = labels[test_indices]
data3 = data[train_indices, :]
data4 = data[test_indices, :]
# data4 = data[data.preeclampsia_hist .== 1, :]

rename!(data3, [:diabetes, :hypertension, :eclampsia_hist, :white, :black, :asian, :native, :hawaiian, :other, :nonhispanic, :hispanic, :under_18, :bet_18_35, :over_35, :preeclampsia_hist, :pre_eclampsia_rec_occur]
)
rename!(data4, [:diabetes, :hypertension, :eclampsia_hist, :white, :black, :asian, :native, :hawaiian, :other, :nonhispanic, :hispanic, :under_18, :bet_18_35, :over_35, :preeclampsia_hist, :pre_eclampsia_rec_occur]
)
model = glm(@formula(pre_eclampsia_rec_occur ~ 1 + diabetes + hypertension + eclampsia_hist + white + black + asian + native + hawaiian + other + nonhispanic + hispanic + under_18 + bet_18_35 + over_35 + preeclampsia_hist), data3, Bernoulli(), LogitLink())

display(model)
test_predicted_values = predict(model, data4)
train_predicted_values = predict(model, data3)
# Convert predicted values to binary (0 or 1) based on probability threshold (0.5 for binary classification
test_predicted_classes = test_predicted_values .> 0.5
train_predicted_classes = train_predicted_values .> 0.5
# Calculate accuracy
test_accuracy = sum(data4.pre_eclampsia_rec_occur .== test_predicted_classes) / length(test_predicted_classes)
train_accuracy = sum(data3.pre_eclampsia_rec_occur .== train_predicted_classes) / length(train_predicted_classes)
coefficients = coef(model)
coef_names = coefnames(model)

# Create a dictionary pairing coefficient names with their values
coefficients_dict = Dict(zip(coef_names, coefficients))
# println(coefficients_dict)
# Print test accuracy
println("Train Accuracy: ", train_accuracy)
println("Test Accuracy: ", test_accuracy)


# Specify the file path
file_path = "csv_files/weights.json"

# Convert dictionary to JSON-formatted string
coefficients_json = JSON.json(coefficients_dict)

# Write the JSON-formatted string to the file
open(file_path, "w") do io
    println(io, coefficients_json)
end
