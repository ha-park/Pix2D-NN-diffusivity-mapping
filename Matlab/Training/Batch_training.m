ROIPath = uigetdir('','Select ROI array batch folder for NN training');
ROIfiles = dir(fullfile(ROIPath, '*.mat'));
saveDir  = uigetdir('','Select path to save result');
for i = 1:size(ROIfiles,1)
    load([ROIPath '\' ROIfiles(i).name]);
      
    [net, YVal, YPred, rmse] = ...
        Training_deepCNN_working_ver(NN_input,Train_D_label);

    % Calculates Linear Regression for ML Prediction against Ground Truth
    A = [ones(length(YVal),1) YVal];
    y = YPred;
    fit = linsolve(A'* A, A'* y);

    sse_1 = sum(((A*fit)-y).^2);
    ssto_1 = sum(((A*fit)-mean(y)).^2); 
    r2_1 = 1 - sse_1/ssto_1;

    fig1 = figure('Menubar','none','toolbar','none','Visible','off');
    hold on
    title('CNN validation');
    xlabel(['Ground Truth Diffusivity (' char(181) 'm^2/s)']);
    ylabel(['Predicted Diffusivity (' char(181) 'm^2/s)']);

    xPlot = 0:6;
    yPlot =  fit(1) + fit(2)*xPlot;

    plot(xPlot, yPlot, 'k','linewidth',1);
    plot(xPlot, xPlot, 'r','linewidth',1);
    axis([0 5 0 5])

    scatter(YVal,YPred,6,'Marker','.','markeredgecolor','k')

    saveas(fig1,[saveDir '\Plot_' ROIfiles(i).name(1:end-4) '.png'])
    close(fig1)
    save ([saveDir '\NN_' ROIfiles(i).name], 'net', 'YVal', 'YPred', 'rmse')
    
    disp(['Training CNN no. ' num2str(i) ' complete'])
end