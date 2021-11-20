function [roi_array,roi_xy,frame_list] = Extract_roi_training_oneDax(dax_name,mlist_name,roi_width)

%------------------------------------------------
% This function loads dax image and localization file to extract intensity
% into array
% This function is using ReadDax of matlab-storm published by Zhuanglab
% https://github.com/ZhuangLab/matlab-storm
%--------------------------------------------------------------------------
% Output: 
% roi_array: intenisty array - n-by-1 cell array of (roi_width^2) array
% roi_xy: xy positions in pixel 
% dim: size of image in pixel
%--------------------------------------------------------------------------
% Input:
% dax_name: input dax image to read
% mlist_name: insight3 localization result file (.bin)
% roi_width: size of square-ROI to extract intensity
%--------------------------------------------------------------------------
% Ha Park
% December 17, 2020
% Version 2.0
% Samples ROI into cell array instead of linearization
% Linearization is required only for running fully-connected NN 
% Normalization and applying vicinity filter

%disp('Initializing ROI extraction')
%disp(' ')
%disp(['ROI size: ' num2str(roi_width) '-by-' num2str(roi_width) ' pixel'])
%disp(' ')

%roi_half_width
rhw = (roi_width-1)/2;

[movie, infoFile] = ReadDax(dax_name,'verbose',false);
r = readbinfileNXcYcZc(mlist_name);
dim = infoFile.frame_dimensions;

rx = ceil((r.xc)-0.5); ry = ceil((r.yc)-0.5);
indices = find(rx > rhw & rx <= dim(1) - rhw & ry <= dim(2) - rhw & ry > rhw);
roi_xy = [r.xc(indices) r.yc(indices)];
frame_list = r.frame(indices); %background = r.bg;

n_crop = size(indices,1);
temp_roi_array = zeros(roi_width,roi_width,n_crop);

for i = 1:n_crop
   ind = indices(i);
   x = rx(ind); y = ry(ind); fr = r.frame(ind);
   same_frame_ind = find(r.frame == fr);
   rx_window = rx(same_frame_ind); ry_window = ry(same_frame_ind);
   if sum(abs(rx_window - x) < roi_width) > 1 && sum(abs(ry_window - y) < roi_width) > 1
        indices(i) = 0;
       continue
   end
   %temp_roi_array(:,:,i) = double(movie(y-rhw:y+rhw,x-rhw:x+rhw,fr) - uint16(background(ind)));
   temp_roi_array(:,:,i) = double(movie(y-rhw:y+rhw,x-rhw:x+rhw,fr));
end

ind = find(indices > 0);
roi_array = temp_roi_array(:,:,ind);
roi_xy = roi_xy(ind,:);
frame_list = frame_list(ind);