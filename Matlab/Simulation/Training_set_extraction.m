[traindax,traindir] = uigetfile('*.dax','Select the training image set');

saveDir  = uigetdir('','Select path to save result');
binname = [traindax(1:end-4) '_list.bin'];

D_label = (0:0.05:6)';  %input same sequence from training
frame_length = 400;     %number of molecules per diffusivity

ROI_size = 7;
n_stack = 40;
m_repeat = 100;

ran = RandStream('mlfg6331_64', 'seed', randi(2*m_repeat));
[roi_array, roi_xy, frame_list] = Extract_roi_training([traindir traindax],[traindir binname],ROI_size);

for i = 1:size(D_label,1)
    d_ind = find((i-1)*frame_length < frame_list & i*frame_length >= frame_list);
    if length(d_ind) < n_stack
        D_label(i) = -1;
        continue 
    end
end

Train_D_label = D_label(D_label >=0);
NN_input = zeros(ROI_size,ROI_size,n_stack,size(Train_D_label,1)*m_repeat);

for l = 1:size(Train_D_label,1)
   f_ind = find(D_label == Train_D_label(l));
   d_ind = find((f_ind-1)*frame_length < frame_list & f_ind*frame_length >= frame_list);
    for j = 1:m_repeat
        rand_seq = datasample(ran, d_ind, n_stack, 'replace', false);
        for k = 1:n_stack
            NN_input(:,:,k,(l-1)*m_repeat+j) = roi_array(:,:,rand_seq(k));
        end
    end    
end
Train_D_label = repelem(Train_D_label,m_repeat);

save ([saveDir '\' traindax(1:end-4) '_ROI ' num2str(ROI_size) ', Ch ' num2str(n_stack) ', Repeat ' num2str(m_repeat)], ...
   'Train_D_label','NN_input')