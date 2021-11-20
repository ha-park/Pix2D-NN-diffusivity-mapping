ROIPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select ROI array batch folder for NN training');
ROIfiles = dir(fullfile(ROIPath, '*.mat'));

saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');
NNlist = '';
NN_input = [];
Train_D_label = [];

for i = 1:size(ROIfiles,1)
    FindPos=strfind(ROIfiles(i).name,'Thick ');
    n_stack = sscanf(ROIfiles(i).name(FindPos(end)+6:end),'%f',1);
    data =  load([ROIPath '\' ROIfiles(i).name],'NN_input','Train_D_label');
    NNlist = strcat(NNlist,[ROIfiles(i).name '\n']);
    input = data.NN_input;
    label = data.Train_D_label;

    Train_D_label = [Train_D_label; label];
    NN_input = cat(4,NN_input,input);
end
%fid = fopen([saveDir '\NN_list.txt'], 'wt');
%fprintf(fid, NNlist);
%fclose(fid);

save([saveDir '\Aug Ch ' num2str(n_stack)], "NN_input", "Train_D_label")
clearvars -except Train_D_label NN_input