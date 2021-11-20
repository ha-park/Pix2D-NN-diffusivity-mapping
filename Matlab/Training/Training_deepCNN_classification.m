function [net, YVal, YPred, T5accuracy] = Training_deepCNN_classification(ROI_stack,label)

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
% Last modified: Oct 23 2021

n_channel = size (ROI_stack,3);
%% Runs the CNN togenerate a predictive model for diffusivity based on pulse length
% Assumbles the convolution neural network
layers = [
    imageInputLayer(size(ROI_stack,1:3))
    
    convolution2dLayer(3,n_channel*2,'Padding','same')
    batchNormalizationLayer
    reluLayer

    averagePooling2dLayer(2,'Stride',2,'Padding',[1 0 1 0])
    
    convolution2dLayer(3,n_channel*4,'Padding','same')
    batchNormalizationLayer
    reluLayer

    averagePooling2dLayer(2,'Stride',2,'Padding',[0 1 0 1])
    
    convolution2dLayer(3,n_channel*8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(3,n_channel*8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(201)
    softmaxLayer
    classificationLayer];

%% K fold training

% Assigns training and testing label
cv = cvpartition(size(ROI_stack,4),'HoldOut',0.2);

XTrain = ROI_stack(:,:,:,training(cv));
YTrain = label(training(cv));

XVal = ROI_stack(:,:,:,test(cv));
YVal = label(test(cv));

% Network training settings
miniBatchSize  = 128;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',100, ...
    'InitialLearnRate',0.02, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.2, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{XVal,YVal}, ...
    'ValidationFrequency',validationFrequency, ...
    'ExecutionEnvironment','gpu', ...
    'Plots','none', ...
    'Verbose',false);

% Network training
net = trainNetwork(XTrain,YTrain,layers,options);

T5accuracy = 0;
[YPred,scores] = classify(net,XVal);
for i = 1:numel(YPred)
    [~,a] = sort(scores(i,:),'descend');
    T5accuracy = T5accuracy + sum(a(1:5) == double(YVal(i)));
end
T5accuracy = T5accuracy/i;


