if ~exist('net','var')
   [netName,netPathName] = uigetfile('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results\NN*.mat','Select matlab data file containing trained network');
   data = load([netPathName netName]);
   net = data.net;
   clearvars data
end

[stackName,stackPathName] = uigetfile('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results\*.mat','Select matlab data file containing extracted ROI');
saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');
roidata = load([stackPathName stackName]);
roi_array = roidata.roi_array;
roi_xy = roidata.roi_xy;
dim = roidata.dim;

clearvars roidata

filehead = stackName(11:end-4);

FindPos=strfind(stackName,'ROI size_');
ROI_size = sscanf(stackName(FindPos(end)+9:end),'%f',1);

bin_scale = 1;
n_threshold = 30;
n_stack = 30;
m_repeat = 80;
D_map = zeros(floor(dim(2)/bin_scale),floor(dim(1)/bin_scale));
sd_map = D_map;
I_map = D_map;

[ind_cell,ind_array] = pixel_binner_v2(roi_xy,dim,bin_scale,n_threshold);

ran = RandStream('mlfg6331_64', 'seed', randi(2*m_repeat));

for i = 1:size(ind_array,1)
    ind_pool = ind_cell{ind_array(i)};
    I_map(ind_array(i)) = size(ind_pool,1);
    NN_input = zeros(ROI_size,ROI_size,n_stack,m_repeat);
    for j = 1:m_repeat
        rand_seq = datasample(ran, ind_pool, n_stack, 'replace', false);
        for k = 1:n_stack
            NN_input(:,:,k,j) = roi_array(:,:,rand_seq(k));
        end
    end
    D_predicted = predict(net, NN_input);
    D_map(ind_array(i)) = mean(D_predicted);
    sd_map(ind_array(i)) = std(D_predicted);
end          

save ([saveDir '\Dmap_' filehead '_Bin size_' num2str(bin_scale) '_N Threshold_' num2str(n_threshold) '_' num2str(m_repeat) 'repeats.mat'],'D_map','sd_map','I_map')

clearvars -except net D_map sd_map I_map
% NN analysis results in "size(ind_array,1) (* m_repeat) " dimension
% mapping back to original image using ind_array
% for k = 1:size(ind_array,1)
% result((k-1)*m_repeat:k*m_repeat) goes to "ind_array(k)-th" cell