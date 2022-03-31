function [net, YVal, YPred, rmse] = Training_deepCNN(ROI_stack,label)

%---------------------------------------------------------------
% 
%---------------------------------------------------------------
% [Input]
% ROI_stack:    w -by- w -by- stack size -by- set size
% label:        set size -by- 1 vector of diffusivity label
% --------------------------------------------------------------
% [Output]
% ne:     array of trainned CNN
% Yval:   array of validation labels
% Ypred:  array of validation results
% rmse:   validation RMSE
%
% Ha H. Park
% Last modified: Mar 18 2022

n_channel = size (ROI_stack,3);
%% Runs the CNN togenerate a predictive model for diffusivity based on pulse length
% Assumbles the convolution neural network
layers = [
    imageInputLayer(size(ROI_stack,1:3))
    
    convolution2dLayer(3,n_channel*2,'Padding','same')
    batchNormalizationLayer
    reluLayer

    convolution2dLayer(2,n_channel*2,'Stride',2)
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(3,n_channel*4,'Padding','same')
    batchNormalizationLayer
    reluLayer

    convolution2dLayer(2,n_channel*4,'Stride',2)
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(3,n_channel*8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(3,n_channel*8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    dropoutLayer(0.2)
    fullyConnectedLayer(1)
    regressionLayer];

%% K fold training

% Assigns training and testing label
cv = cvpartition(size(ROI_stack,4),'HoldOut',0.2);

XTrain = ROI_stack(:,:,:,training(cv));
YTrain = label(training(cv));

XVal = ROI_stack(:,:,:,test(cv));
YVal = label(test(cv));

% Network training settings
miniBatchSize  = 256;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',60, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',25, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XVal,YVal}, ...
    'ValidationFrequency',validationFrequency, ...
    'ExecutionEnvironment','gpu', ...
    'Plots','none', ...
    'Verbose',false);

% Network training
net = trainNetwork(XTrain,YTrain,layers,options);

% Calculates predicted diffusion from test data
YPred = predict(net,XVal);
nonZ = find(YVal > 0.5);
predictionError = (YVal(nonZ) - YPred(nonZ))./YVal(nonZ);
rmse = sqrt(predictionError'*predictionError/length(nonZ));