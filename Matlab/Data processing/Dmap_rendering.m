load('JetM2Using');

filedir = uigetdir('','Select directory for batch Dmap rendering');
matlist = dir(fullfile(filedir,'Dmap*.mat'));

N = size(matlist,1);

for i = 1:N
    load([filedir '/' matlist(i).name]);
    filehead = matlist(i).name(1:end-4);
    FindDPos2=strfind(matlist(i).name,'Bin size_');
    
    binnum = 0.75;
    figure('position',[500 500 700 600],'Menubar','none','toolbar','none','visible','off');
    imshow(D_map,'InitialMagnification','fit')
    hold on

    JetM2(1,:) = [0 0 0];
    mask = zeros(size(D_map,1),size(D_map,2));
    j = imshow(mask);
    set(j,'AlphaData', max(1-I_map/(mean(I_map,'all')+std(I_map,0,'all')),0))

    crange = [0 6];
    caxis(crange)
    c = colorbar;
    colormap(JetM3)
    c.Label.String = ['Fitted Local D (' char(181) 'm^{2}/s)'];
    title(['Bin size = ' num2str(binnum) ' pixel'])
    
    %saveas(gcf,[filedir '/' filehead '_[' num2str(crange(1)) ' ' num2str(crange(2)) '].fig'])
    saveas(gcf,[filedir '/' filehead '_[' num2str(crange(1)) ' ' num2str(crange(2)) '].svg'])   
    close(gcf)
end
