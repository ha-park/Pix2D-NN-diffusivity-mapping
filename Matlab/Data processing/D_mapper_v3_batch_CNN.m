CNNPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select CNN batch folder');
CNNfiles = dir(fullfile(CNNPath, 'NN*.mat'));

[ROIarrayname,ROIPathName] = uigetfile('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results\ROI array*.mat','Select matlab data file containing extracted ROI');
saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');
roidata = load([ROIPathName ROIarrayname]);
roi_array = roidata.roi_array;
roi_xy = roidata.roi_xy;
dim = roidata.dim;
clearvars roidata

filehead = ROIarrayname(11:end-4);
FindPos=strfind(ROIarrayname,'ROI size_');
ROI_size = sscanf(ROIarrayname(FindPos(end)+9:end),'%f',1);

bin_scale = 1.2;
m_repeat = 80;

ran = RandStream('mlfg6331_64', 'seed', randi(2*m_repeat));
NNlist = '';

for i = 1:size(CNNfiles,1)
    load([CNNPath '\' CNNfiles(i).name],'net');
    NNlist = strcat(NNlist,[CNNfiles(i).name '\n']);
    
    FindPos=strfind(CNNfiles(i).name,'channel ');
    n_stack = sscanf(CNNfiles(i).name(FindPos(end)+8:end),'%f',1);
    n_threshold = n_stack;
    
    D_map = zeros(floor(dim(2)/bin_scale),floor(dim(1)/bin_scale));
    sd_map = D_map;
    I_map = D_map;
    
    [ind_cell,ind_array] = pixel_binner_v2(roi_xy,dim,bin_scale,n_threshold);

    for l = 1:size(ind_array,1)
        ind_pool = ind_cell{ind_array(l)};
        I_map(ind_array(l)) = size(ind_pool,1);
        NN_input = zeros(ROI_size,ROI_size,n_stack,m_repeat);
        for j = 1:m_repeat
            rand_seq = datasample(ran, ind_pool, n_stack, 'replace', false);
            for k = 1:n_stack
                NN_input(:,:,k,j) = roi_array(:,:,rand_seq(k));
            end
        end
        D_predicted = predict(net, NN_input);
        D_map(ind_array(l)) = mean(D_predicted);
        sd_map(ind_array(l)) = std(D_predicted);
    end
    disp(['Mapping data ' num2str(i) ' complete'])
    
    save ([saveDir '\Dmap_' num2str(i) 'th CNN_Bin size_' num2str(bin_scale) '_N Threshold_' num2str(n_threshold) '_' num2str(m_repeat) 'repeats.mat'], 'D_map','sd_map','I_map','net')
    clearvars -except NNlist ROI_size i CNNPath CNNfiles bin_scale m_repeat ran saveDir roi_array roi_xy dim
end
fid = fopen([saveDir '\NN_list.txt'], 'wt');
fprintf(fid, NNlist);
fclose(fid);

% NN analysis results in "size(ind_array,1) (* m_repeat) " dimension
% mapping back to original image using ind_array
% for k = 1:size(ind_array,1)
% result((k-1)*m_repeat:k*m_repeat) goes to "ind_array(k)-th" cell