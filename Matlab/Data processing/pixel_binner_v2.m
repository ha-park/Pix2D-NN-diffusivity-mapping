function [ind_cell,ind_array] = pixel_binner_v2(roi_xy, dim, bin_scale, n_threshold)

%------------------------------------------------
% This function generates binned localization map
%
%--------------------------------------------------------------------------
% Output:
% ind_cell: indices into binned cell
% ind_array: indices of bins having enough signal counts
%--------------------------------------------------------------------------
% Input:
% roi_xy: localization positions
% dim: size of image in pixels
% bin_scale: scaling factor of bins in unit of pixels
% n_threshold: threshold of molecule counts per bin
%--------------------------------------------------------------------------
% Ha Park
% OCtober 18, 2021
% version 2.0
%

bin_x = floor(dim(1)/bin_scale);
bin_y = floor(dim(2)/bin_scale);
disp(['Initializing Image binning into ' num2str(bin_x) ' x ' num2str(bin_y)])
disp(' ')

ind_cell = cell(bin_y,bin_x);
n_array = zeros(bin_y,bin_x);

% this is because insight3 coordinates have (0.5, 0.5) at the image origin
ind = ceil((roi_xy-0.5)/bin_scale);
ind_x = ind(:,1);
ind_y = ind(:,2);

% find all the molecules that goes into each bin
for i = 1:size(roi_xy,1)
    try
        ind_cell{ind_y(i),ind_x(i)} = [ind_cell{ind_y(i),ind_x(i)}; i];  
    end
end

% keep bins that only have molecule counts over threshold
for i = 1:bin_y*bin_x
   if size(ind_cell{i},1) >= n_threshold
       n_array(i) = 1;
   end
end

ind_array = find(n_array >0);

disp('Binning complete')


