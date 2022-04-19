DaxPath = uigetdir('','Select Dax batch folder to extract ROI');
Daxfiles = dir(fullfile(DaxPath, '*.dax'));
saveDir  = uigetdir('','Select path to save result');
ROI_size = 7;
frame_interval = 3000; 

for i = 1:size(Daxfiles,1)
   dax_name = [DaxPath '\' Daxfiles(i).name];
   filehead = Daxfiles(i).name(1:end-4);
   mlist_name = [DaxPath '\' filehead '_list.bin'];
   
   [roi_array, roi_xy, dim] = Extract_roi_raw(dax_name,mlist_name,ROI_size,frame_interval);
   save ([saveDir '\ROI array_' filehead ' raw_ROI size_' num2str(ROI_size) '.mat'],'roi_array','roi_xy','dim')

end