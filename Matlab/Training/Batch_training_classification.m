clearvars -except ROIfiles saveDir ROIPath

ROIPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select ROI array batch folder for NN training');
ROIfiles = dir(fullfile(ROIPath, '*.mat'));
%saveDir  = ROIPath;
saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');

for i = 1:size(ROIfiles,1)
    load([ROIPath '\' ROIfiles(i).name]);
      
    [net, YVal, YPred, T5accuracy] = ...
        Training_deepCNN_classification(NN_input,Train_D_label);
    disp(['Top-5 accuracy:' num2str(T5accuracy)])

    save ([saveDir '\NN_' ROIfiles(i).name], 'net', 'YVal', 'YPred', 'T5accuracy')
    disp(['Training CNN no. ' num2str(i) ' complete'])
end