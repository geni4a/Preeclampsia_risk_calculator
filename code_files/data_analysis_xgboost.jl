using CSV
using DataFrames
using XGBoost
using Random
using Term
using GraphPlot
using LightGraphs

counts_dict = Dict()
dfweui= DataFrame()

function sum_df(df, name)
    # Calculate the sum of each column
    column_sums = [sum(col) for col in eachcol(df)]

    # Get column names
    column_names = names(df)
    println(name)
    println("Total population = ", nrow(df))
    # Print the sum of each column with its name
    for (name, sum_value) in zip(column_names, column_sums)
        println("$name = $sum_value")
        counts_dict[name] = sum_value
        # show(dfweui)
        # dfweui[!, "$name"] .= sum_value
    end
end



data100 = CSV.File("csv_files/final_for_real2.csv", header = 1) |> DataFrame
data = CSV.File("csv_files/final_for_real_for_real.csv", header = 1) |> DataFrame
sum_df(data, "orig_data")

println(counts_dict)

data = data[:, ["diabetes", "hypertension", "eclampsia_hist", "white", "black", "asian", "native", "hawaiian", "other", "nonhispanic", "hispanic", "under_18", "18_35", "35_and_over","preeclampsia_hist", "age","pre_eclampsia_rec_occur"]
]
rename!(data, [:diabetes, :hypertension, :eclampsia_hist, :white, :black, :asian, :native, :hawaiian, :other, :nonhispanic, :hispanic, :under_18, :bet_18_35, :over_35, :preeclampsia_hist, :age, :pre_eclampsia_rec_occur]
)
data = select!(data, Not(:age))

# Extract features and labels
features = data[:, 1:end-1]  # All rows, all columns except the last one
labels = data[:, end]        # preeclampsia occur col
# Set the seed for reproducibility
Random.seed!(123)
# Shuffle the indices and split
indices = shuffle(1:size(data, 1))
split_ratio = 0.8
split_index = Int(floor(split_ratio * length(indices)))
train_indices = indices[1:split_index]
test_indices = indices[(split_index + 1):end]
# Split the data into training and testing sets
train_features = features[train_indices, :]
train_labels = labels[train_indices]
test_features = features[test_indices, :]
test_labels = labels[test_indices]
train_data = DMatrix(train_features, label=train_labels)
test_data = DMatrix(test_features, label=test_labels)
# Training and Prediction
bst = xgboost(train_data, num_round=30, objective = "binary:logistic", eta=1, seed= 123)
train_preds = predict(bst, train_data)
test_preds = predict(bst, test_data)
# Evaluate the model
train_accuracy = sum((train_preds .>= 0.5) .== train_labels) / length(train_labels)
test_accuracy = sum((test_preds .>= 0.5) .== test_labels) / length(test_labels)
println("Training Accuracy: ", train_accuracy)
println("Testing Accuracy: ", test_accuracy)
println("Feature names: ", bst.feature_names)
display(importancereport(bst))


data3 = data100[train_indices, :]
data4 = data100[test_indices, : ]
data3[!, :train_scores] = train_preds
data4[!, :test_scores] = test_preds

# savefig(tree_plot, "csv_files/tree_plot.png")

CSV.write("csv_files/with_train_score.csv", data3)
CSV.write("csv_files/with_test_score.csv", data4)
# XGBoost.save_model(model, "csv_files/xgboost_model.model")
treei = trees(bst)
show(treei)

