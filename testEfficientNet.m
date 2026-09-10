clc;
clear;
close all;

%% ============================================================
%  EfficientNet-B0 - Diabetic Retinopathy Training
% ============================================================

fprintf('\n============================================\n');
fprintf(' EfficientNet-B0 DR Training\n');
fprintf('============================================\n\n');

%% Paths

projectRoot = fileparts(fileparts(mfilename("fullpath")));

csvFile = fullfile(projectRoot, "data", "train.csv");
imageFolder = fullfile(projectRoot, "data", "images");
modelFolder = fullfile(projectRoot, "model");

if ~exist(modelFolder, "dir")
    mkdir(modelFolder);
end


%% Load CSV

fprintf("Loading dataset...\n");

data = readtable(csvFile);

disp(data(1:min(5,height(data)),:));

fprintf("Number of images: %d\n", height(data));


%% IMPORTANT:
% Check the names of the CSV columns

fprintf("\nCSV columns:\n");

disp(data.Properties.VariableNames);


%% ------------------------------------------------------------
% CHANGE THESE TWO NAMES IF YOUR CSV USES DIFFERENT NAMES
% ------------------------------------------------------------

imageColumn = "id_code";
labelColumn = "diagnosis";


%% Build image paths

imageNames = string(data.(imageColumn));
labels = categorical(data.(labelColumn));


%% Display classes

fprintf("\nClasses found in dataset:\n");

disp(categories(labels));


%% Create image datastore

imagePaths = fullfile(imageFolder, imageNames);

% Add .png/.jpg extension automatically if needed
for i = 1:length(imagePaths)

    if ~isfile(imagePaths(i))

        possible = [
            imagePaths(i) + ".jpg"
            imagePaths(i) + ".jpeg"
            imagePaths(i) + ".png"
        ];

        found = false;

        for j = 1:length(possible)

            if isfile(possible(j))

                imagePaths(i) = possible(j);
                found = true;
                break;

            end

        end

        if ~found

            fprintf("WARNING: Image not found: %s\n", ...
                imageNames(i));

        end

    end

end


%% Remove missing images

valid = arrayfun(@isfile, imagePaths);

imagePaths = imagePaths(valid);
labels = labels(valid);


fprintf("\nValid images: %d\n", length(imagePaths));


%% Create datastore

imds = imageDatastore( ...
    imagePaths, ...
    "Labels", labels);


%% ============================================================
% Split dataset
% ============================================================

[imdsTrain, imdsValidation] = splitEachLabel( ...
    imds, ...
    0.80, ...
    "randomized");


fprintf("\nTraining images   : %d\n", ...
    numel(imdsTrain.Files));

fprintf("Validation images : %d\n", ...
    numel(imdsValidation.Files));


%% ============================================================
% Load EfficientNet-B0
% ============================================================

fprintf("\nLoading pretrained EfficientNet-B0...\n");

net = efficientnetb0;

fprintf("EfficientNet-B0 loaded successfully.\n");


%% Input size

inputSize = net.Layers(1).InputSize;

fprintf("Input size: ");

disp(inputSize);


%% ============================================================
% Augmentation / resizing
% ============================================================

augTrain = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsTrain, ...
    "ColorPreprocessing", "gray2rgb");


augValidation = augmentedImageDatastore( ...
    inputSize(1:2), ...
    imdsValidation, ...
    "ColorPreprocessing", "gray2rgb");


%% ============================================================
% Find number of classes
% ============================================================

numClasses = numel(categories(labels));

fprintf("\nNumber of DR classes: %d\n", numClasses);


%% ============================================================
% Replace classification head
% ============================================================

lgraph = layerGraph(net);

layers = lgraph.Layers;


fprintf("\nLast layers of EfficientNet-B0:\n");

disp(layers(end-5:end));


%% Find classification layers

learnableLayer = [];
classificationLayer = [];

for i = 1:length(layers)

    if isa(layers(i), "nnet.cnn.layer.FullyConnectedLayer")

        learnableLayer = layers(i);

    end

    if isa(layers(i), "nnet.cnn.layer.ClassificationOutputLayer")

        classificationLayer = layers(i);

    end

end


%% Make sure layers were found

if isempty(learnableLayer)

    error("Could not find the final fully connected layer.");

end

if isempty(classificationLayer)

    error("Could not find the classification output layer.");

end


%% New classification head

newLearnableLayer = fullyConnectedLayer( ...
    numClasses, ...
    "Name", "DR_fc", ...
    "WeightLearnRateFactor", 10, ...
    "BiasLearnRateFactor", 10);


newClassificationLayer = classificationLayer;


%% Replace layers

lgraph = replaceLayer( ...
    lgraph, ...
    learnableLayer.Name, ...
    newLearnableLayer);


lgraph = replaceLayer( ...
    lgraph, ...
    classificationLayer.Name, ...
    newClassificationLayer);


%% ============================================================
% Training options
% ============================================================

options = trainingOptions("adam", ...

    "MiniBatchSize", 16, ...

    "MaxEpochs", 5, ...

    "InitialLearnRate", 1e-4, ...

    "Shuffle", "every-epoch", ...

    "ValidationData", augValidation, ...

    "ValidationFrequency", 50, ...

    "Verbose", true, ...

    "Plots", "training-progress", ...

    "ExecutionEnvironment", "auto");


%% ============================================================
% Train
% ============================================================

fprintf("\n============================================\n");
fprintf("Starting EfficientNet-B0 training...\n");
fprintf("============================================\n\n");


trainedNet = trainNetwork( ...
    augTrain, ...
    lgraph, ...
    options);


%% ============================================================
% Save model
% ============================================================

modelPath = fullfile( ...
    modelFolder, ...
    "efficientnetb0_DR.mat");


save(modelPath, "trainedNet");


fprintf("\n============================================\n");
fprintf("TRAINING COMPLETE\n");
fprintf("============================================\n");

fprintf("\nModel saved to:\n%s\n\n", modelPath);