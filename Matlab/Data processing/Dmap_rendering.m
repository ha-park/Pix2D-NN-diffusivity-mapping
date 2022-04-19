load('JetM2Using');

filedir = uigetdir('','Select directory for batch Dmap rendering');
matlist = dir(fullfile(filedir,'Dmap*.mat'));

N = size(matlist,1);
drange = [0 9];

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

    drange = [0 5];
    caxis(drange)
    c = colorbar;
    colormap(JetM2)
    c.Label.String = ['Fitted Local D (' char(181) 'm^{2}/s)'];
    title(['Bin size = ' num2str(binnum) ' pixel'])
    
    saveas(gcf,[filedir '/' filehead '_[' num2str(drange(1)) ' ' num2str(drange(2)) '].fig'])
    saveas(gcf,[filedir '/' filehead '_[' num2str(drange(1)) ' ' num2str(drange(2)) '].svg'])   
    close(gcf)
end
