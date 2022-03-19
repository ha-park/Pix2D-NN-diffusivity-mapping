if ~exist('net','var')
    [netName,netPathName] = uigetfile('','Select matlab data file containing trained network');
    data = load([netPathName netName]);
    net = data.net;
    clearvars data
end

ROIPath = uigetdir('','Select ROI batch folder to extract map');
ROIfiles = dir(fullfile(ROIPath, 'ROI array*.mat'));
saveDir  = uigetdir('','Select path to save result');

<<<<<<< Updated upstream
bin_scale = 1.2;
n_threshold = 30;
n_stack = 30;
m_repeat = 80;
=======
ROI_size = 7;
bin_scale = 0.75;
n_ch = net.Layers(1).InputSize(3);
m_repeat = 100;
>>>>>>> Stashed changes

ran = RandStream('mlfg6331_64', 'seed', randi(2*m_repeat));

for i = 1:size(ROIfiles,1)
    
    roidata = load([ROIPath '\' ROIfiles(i).name]);
    roi_array = roidata.roi_array;
    roi_xy = roidata.roi_xy;
    dim = roidata.dim;
    
    clearvars roidata
    D_map = zeros(floor(dim(2)/bin_scale),floor(dim(1)/bin_scale));
    sd_map = D_map;
    I_map = D_map;
    
    filehead = ROIfiles(i).name(11:end-4);
<<<<<<< Updated upstream
    
    FindPos=strfind(filehead,'ROI size_');
    ROI_size = sscanf(filehead(FindPos(end)+9:end),'%f',1);
    
    [ind_cell,ind_array] = pixel_binner_v2(roi_xy,dim,bin_scale,n_threshold);
=======
    [ind_cell,ind_array] = pixel_binner(roi_xy,dim,bin_scale);
>>>>>>> Stashed changes

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
    disp([num2str(i) ' th data Mapping complete'])
    
<<<<<<< Updated upstream
    save ([saveDir '\Dmap_' filehead '_Bin size_' num2str(bin_scale) '_N Threshold_' num2str(n_threshold) '_' num2str(m_repeat) 'repeats.mat'], 'D_map','sd_map','I_map','net')
    clearvars -except i net ROIPath ROIfiles bin_scale n_threshold n_stack m_repeat ran saveDir
end

% NN analysis results in "size(ind_array,1) (* m_repeat) " dimension
% mapping back to original image using ind_array
% for k = 1:size(ind_array,1)
% result((k-1)*m_repeat:k*m_repeat) goes to "ind_array(k)-th" cell
=======
    save ([saveDir '/Dmap_' filehead '_Bin size_' num2str(bin_scale) '_' num2str(m_repeat) 'repeats.mat'], 'D_map','sd_map','I_map','net')
    clearvars -except i net ROIPath ROIfiles bin_scale n_ch m_repeat ran saveDir ROI_size
end
>>>>>>> Stashed changes
