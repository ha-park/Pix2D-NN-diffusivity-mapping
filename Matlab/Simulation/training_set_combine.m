<<<<<<< Updated upstream
ROIPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select ROI array batch folder for NN training');
ROIfiles = dir(fullfile(ROIPath, '*.mat'));

saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');
=======
TrainingPath = uigetdir('','Select directory of extracted training input');
ROIfiles = dir(fullfile(TrainingPath, '*.mat'));
saveDir  = uigetdir('','Select path to save augmented training set');
>>>>>>> Stashed changes
NNlist = '';
NN_input = [];
Train_D_label = [];

for i = 1:size(ROIfiles,1)
<<<<<<< Updated upstream
    FindPos=strfind(ROIfiles(i).name,'Thick ');
    n_stack = sscanf(ROIfiles(i).name(FindPos(end)+6:end),'%f',1);
    data =  load([ROIPath '\' ROIfiles(i).name],'NN_input','Train_D_label');
=======
    FindPos=strfind(ROIfiles(i).name,'Ch ');
    n_stack = sscanf(ROIfiles(i).name(FindPos(end)+3:end),'%f',1);
    data =  load([TrainingPath '\' ROIfiles(i).name],'NN_input','Train_D_label');
>>>>>>> Stashed changes
    NNlist = strcat(NNlist,[ROIfiles(i).name '\n']);
    input = data.NN_input;
    label = data.Train_D_label;

    Train_D_label = [Train_D_label; label];
    NN_input = cat(4,NN_input,input);
end

save([saveDir '\Aug Ch ' num2str(n_stack)], "NN_input", "Train_D_label")
clearvars -except Train_D_label NN_input