clearvars

ROIPath = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select ROI array batch folder for NN training');
ROIfiles = dir(fullfile(ROIPath, '*.mat'));
%saveDir  = ROIPath;
saveDir  = uigetdir('G:\My Drive\Xu Lab\3. NN D map (10.1.2020 ~ )\Data and results','Select path to save result');

Initlearnrate = [0.005 0.003 0.001];
miniBatchSize = [128 256];
dropoutrate   = 0.2;


for i = 1:size(ROIfiles,1)
    load([ROIPath '\' ROIfiles(i).name]);
    disp(['Training CNN no. ' num2str(i) ' Start'])
    for l = 1:length(miniBatchSize)
        for j = 1:length(Initlearnrate)
            tic
            savename = [ROIfiles(i).name(1:end-4) ' Batchsize_' num2str(miniBatchSize(l)) ' LearnRate_' num2str(Initlearnrate(j))];
            [net, YVal, YPred, rmse] = ...
                Training_deepCNN_parameter_sweep(NN_input,Train_D_label,miniBatchSize(l),Initlearnrate(j),dropoutrate);

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
            axis([0 6 0 6])

            scatter(YVal,YPred,6,'Marker','.','markeredgecolor','k')

            saveas(fig1,[saveDir '\Plot_' savename '.png'])
            close(fig1)

            save ([saveDir '\NN_' savename '.mat'], 'net', 'YVal', 'YPred', 'rmse')
            disp(['Batchsize: ' num2str(miniBatchSize(l)) ', LearnRate: ' num2str(Initlearnrate(j)) ' complete'])
            toc
            disp(' ')
        end
    end
    disp(['Training CNN no. ' num2str(i) ' complete'])
end