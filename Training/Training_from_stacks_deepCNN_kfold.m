function [net_cell, YVal, YPred, rmse] = Training_from_stacks_deepCNN_kfold(ROI_stack,label,k)

%---------------------------------------------------------------
% 
%---------------------------------------------------------------
% [Input]
% ROI_stack:    w -by- w -by- stack size -by- set size
% label:        set size -by- 1 vector of diffusivity label
% inputlayer:   input dimension: w -by- w -by- stack size
% k:            k value for k-fold cross-validation
% --------------------------------------------------------------
% [Output]
% net_cell:     k x 1 cell array of trainned CNN
% Yval:         k x 1 cell array of validation labels
% Ypred:        k x 1 cell array of validation results
% rmse:         k x 1 array of validation RMSE
%
% Ha H. Park
% Last modified: Oct 21 2021

n_channel = size(ROI_stack,3);

%% Runs the CNN togenerate a predictive model for diffusivity based on pulse length
% Assumbles the convolution neural network
layers = [
    imageInputLayer(size(ROI_stack,1:3))
    
    convolution2dLayer(3,n_channel*2,'Padding','same')
    batchNormalizationLayer
    swishLayer
    
    convolution2dLayer(3,n_channel*4,'Padding','same')
    batchNormalizationLayer
    swishLayer
    
    convolution2dLayer(3,n_channel*8,'Padding','same')
    batchNormalizationLayer
    swishLayer
    
    convolution2dLayer(3,n_channel*8,'Padding','same')
    batchNormalizationLayer
    swishLayer
    
    dropoutLayer(0.2)
    fullyConnectedLayer(1)
    regressionLayer];

%% K fold training

% Assigns training and testing label
cv = cvpartition(size(ROI_stack,4),'kfold',k);

net_cell = cell(k,1);
YVal = cell(k,1);
YPred = cell(k,1);
rmse = zeros(k,1);

for i = 1:k
    XTrain = ROI_stack(:,:,:,training(cv,i));
    YTrain = label(training(cv,i));
    
    XVal = ROI_stack(:,:,:,test(cv,i));
    YVal{i} = label(test(cv,i));
    
    % Network training settings
    miniBatchSize  = 128;
    validationFrequency = floor(numel(YTrain)/miniBatchSize);
    options = trainingOptions('sgdm', ...
        'MiniBatchSize',miniBatchSize, ...
        'MaxEpochs',50, ...
        'InitialLearnRate',1e-3, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropFactor',0.1, ...
        'LearnRateDropPeriod',25, ...
        'Shuffle','every-epoch', ...
        'ValidationData',{XVal,YVal{i}}, ...
        'ValidationFrequency',validationFrequency, ...
        'ExecutionEnvironment','gpu', ...
        'Plots','none', ...
        'Verbose',false);
    
    % Network training
    net = trainNetwork(XTrain,YTrain,layers,options);
    net_cell{i} = net;
    
    % Calculates predicted diffusion from test data
    YPred{i} = predict(net,XVal);
    
    nonZ = find(YVal{i} > 0.5);
    predictionError = (YVal{i}(nonZ) - YPred{i}(nonZ))./YVal{i}(nonZ);
    rmse(i) = sqrt(predictionError'*predictionError/length(nonZ));

end


