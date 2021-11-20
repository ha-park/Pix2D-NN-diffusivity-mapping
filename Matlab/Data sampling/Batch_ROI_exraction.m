DaxPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Images','Select Dax batch folder to extract ROI');
Daxfiles = dir(fullfile(DaxPath, '*.dax'));
saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');

ROI_size = 7;
frame_interval = 6000; 

for i = 1:size(Daxfiles,1)
   dax_name = [DaxPath '\' Daxfiles(i).name];
   filehead = Daxfiles(i).name(1:end-4);
   %mlist_name = [DaxPath '\' filehead '_list-r.bin'];
   mlist_name = [DaxPath '\' filehead '_list.bin'];
   
   [roi_array, roi_xy, dim] = Extract_roi(dax_name,mlist_name,ROI_size,frame_interval);
   
   save ([saveDir '\ROI array_' filehead '_ROI size_' num2str(ROI_size) '.mat'],'roi_array','roi_xy','dim')

end

%copyfile([DaxPath '\simulation info.txt'],[saveDir '\simulation info.txt']);


%clearvars -except DaxPath Daxfiles saveDir roi_array_v1 roi_xy_v1