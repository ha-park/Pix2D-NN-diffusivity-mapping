clearvars

k = 5;
ROIPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select ROI array batch folder for NN training');
ROIfiles = dir(fullfile(ROIPath, '*ROI*Thick*Repeat*.mat'));
%saveDir  = ROIPath;
saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');

for i = 1:size(ROIfiles,1)
    load([ROIPath '\' ROIfiles(i).name]);
      
    [net_cell, YVal, YPred, rmse] = ...
        Training_from_stacks_deepCNN_kfold_working_ver(NN_input,Train_D_label,k);
    
    for j = 1:k
        % Calculates Linear Regression for ML Prediction against Ground Truth
        A = [ones(length(YVal{i}),1) YVal{i}];
        y = YPred{i};
        fit = linsolve(A'* A, A'* y);
        
        sse_1 = sum(((A*fit)-y).^2);
        ssto_1 = sum(((A*fit)-mean(y)).^2);
        r2_1 = 1 - sse_1/ssto_1;
        
        fig1 = figure('Menubar','none','toolbar','none','Visible','off');
        hold on
        title(['CNN validation of net-' num2str(j)]);
        xlabel(['Ground Truth Diffusivity (' char(181) 'm^2/s)']);
        ylabel(['Predicted Diffusivity (' char(181) 'm^2/s)']);
        
        scatter(YVal{j},YPred{j},10,'Marker','.','markeredgecolor','k')
        
        xPlot = 0:0.1:6;                   %
        yPlot =  fit(1) + fit(2)*xPlot;
        
        plot(xPlot, yPlot, 'k','linewidth',1);
        plot(xPlot, xPlot, 'r','linewidth',1);
        axis([0 6 0 6])
        
        saveas(fig1,[saveDir '\' ROIfiles(i).name(1:end-4) ' Plot_' num2str(j) '.fig'])
        saveas(fig1,[saveDir '\' ROIfiles(i).name(1:end-4) ' Plot_' num2str(j) '.png'])
        close(fig1)
    end
    save ([saveDir '\NN_' ROIfiles(i).name], 'net_cell', 'YVal', 'YPred', 'rmse')
    
    disp(['Training CNN ' num2str(i) ' complete'])
end