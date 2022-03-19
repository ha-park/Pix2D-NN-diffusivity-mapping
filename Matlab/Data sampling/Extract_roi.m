function [roi_array,roi_xy,dim] = Extract_roi(dax_name,mlist_name,roi_width,frame_interval)

%------------------------------------------------
% This function loads dax image and localization file to extract intensity
% into array
% This function is using ReadDax of matlab-storm published by Zhuanglab
% https://github.com/ZhuangLab/matlab-storm
%--------------------------------------------------------------------------
% Output:
% roi_array: intenisty array - roi_width x roi_width x n array
% roi_xy: xy positions in pixel
% dim: size of image in pixel
%--------------------------------------------------------------------------
% Input:
% dax_name: input dax image to read
% mlist_name: insight3 localization result file (.bin)
% roi_width: size of square-ROI to extract intensity
% frame_interval: size of frame step
%--------------------------------------------------------------------------
% Ha Park
% March 18, 2023
% Version 3.0
% Sampling background-subtracted and normalized ROI
% save localization based on drift-corrected xy

%roi_half_width
rhw = (roi_width-1)/2;

[movie, infoFile] = ReadDax(dax_name,'verbose',false,'startFrame',1,'endFrame',1);
r = readbinfileNXcYcZc(mlist_name);
dim = infoFile.frame_dimensions;
frame_length = double(r.TotalFrames);

rx = ceil((r.x)-0.5); ry = ceil((r.y)-0.5); 
indices = find(rx > rhw & rx <= dim(1) - rhw & ry <= dim(2) - rhw & ry > rhw);
roi_xy = [r.xc(indices) r.yc(indices)];
frame_list = r.frame(indices);

n_crop = size(indices,1);
temp_roi_array = zeros(roi_width,roi_width,n_crop);

for f = 1:frame_interval:frame_length
    if f + frame_interval < frame_length
        frame_f = f + frame_interval-1;
    else
        frame_f = frame_length;
    end

    movie = ReadDax(dax_name,'verbose',false,'startFrame',f,'endFrame',frame_f);
    frame_ind = find(frame_list <= frame_f & frame_list >= f);

    for n = 1:size(frame_ind,1)
        ind = indices(frame_ind(n));
        x = rx(ind); y = ry(ind); fr = r.frame(ind);
        same_frame_ind = find(r.frame == fr);
        rx_window = rx(same_frame_ind); ry_window = ry(same_frame_ind);
        if (abs(rx_window - x) < roi_width)'*(abs(ry_window - y) < roi_width) > 1
            indices(frame_ind(n)) = 0;
            continue
        end
        a =  double(movie(y-rhw:y+rhw,x-rhw:x+rhw,fr-f+1));
        temp_roi_array(:,:,frame_ind(n)) = (a-mean(a,'all'))/std(a,[],'all');
    end
    disp(['Done extracting ' num2str(frame_f) ' frames'])
end

ind = find(indices > 0);
roi_array = temp_roi_array(:,:,ind);
roi_xy = roi_xy(ind,:);

disp(' ')
disp(['Extraction complete: Total ' num2str(size(ind,1)) ' ROI extracted'])