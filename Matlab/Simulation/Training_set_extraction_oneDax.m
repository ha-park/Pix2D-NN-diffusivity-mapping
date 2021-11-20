clearvars

[traindax,traindir] = uigetfile('*.dax','Select the training image set');
saveDir  = uigetdir();

binname = [traindax(1:end-4) '_list.bin'];

D_label = (1:0.01:20)'; %input same sequence from training
frame_length = 20;      %number of frames per single diffusivity

train_d_label = D_label;
ROI_size = 13;
n_stack = 10;
m_repeat = 5;

NN_input = zeros(ROI_size,ROI_size,n_stack,size(D_label,1)*m_repeat);
ran = RandStream('mlfg6331_64', 'seed', randi(2*m_repeat));

[roi_array, roi_xy, frame_list] = Extract_roi_training_oneDax([traindir '\' traindax],[traindir '\' binname],ROI_size);

for i = 1:size(D_label,1)
    d_ind = find((i-1)*frame_length < frame_list & i*frame_length >= frame_list);
    for j = 1:m_repeat
        rand_seq = datasample(ran, d_ind, n_stack, 'replace', false);
        for k = 1:n_stack
            NN_input(:,:,k,(i-1)*m_repeat+j) = roi_array{rand_seq(k)};
        end
    end    
end

train_d_label = repelem(train_d_label,m_repeat);

save ([saveDir '\training from localization'],'train_d_label','NN_input')