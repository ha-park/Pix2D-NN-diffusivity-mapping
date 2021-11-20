saveDir         = uigetdir('H:\Fake Dax for NN analysis','Select folder to save');
%Dmap            = 5;               %can be arbitrary size, and x,y scale can be also independent
dim             = [21 21];          %simulation image size (x,y) in pixel
exposure_t      = 0.00899*1000;   %simulation exposure time in ms unit
%exposure_t      = [0.00899*1000 0.00630*1000 10];   %simulation exposure time in ms unit
%0.0063000000082
particle_density= [1 0];            %particle per frame, [mean s.d.] of normal distribution. For constant number throughout the frame, set s.d. = 0
Frame_length    = 400;               %simulation movie length
sim_t           = 1/100;           %simulation time interval in ms
photon_burst    = [80 90 150];               %photon per molecule per frame per millisecond
background      = {[800 100] [900 110] [1300 170]};
diffusivity     = (0:0.05:6)';
pixel_length    = 160; 
sig             = 0.1436;           % from beads PSF data. R2D2 143nm Tardis 138nm
D_num = size(diffusivity,1);

for i = 1:length(photon_burst)
    for j = 1:length(background)
        daxmovie = zeros(dim(2),dim(1),Frame_length*D_num);
        DaxNameHead     = sprintf('%dHz_bg%d_photon %d_%dto%d',round(1000/exposure_t),background{j}(1),photon_burst(i),diffusivity(1),diffusivity(end));  %not include .dax in the string
        for d = 1:D_num
            tempdax = FreeDmap_to_Dax_trainingset_oneDax_gaussian_background(diffusivity(d), ...
                dim, Frame_length, particle_density, exposure_t, sim_t, photon_burst(i), background{j}, pixel_length/1000, sig);
            daxmovie(:,:,(d-1)*Frame_length+1:d*Frame_length) = tempdax;
        end
        WriteDax(daxmovie,'daxName',DaxNameHead,'folder',[saveDir '\']);

    end
end

disp(' ')
disp(['Simulation complete: Saved to ' saveDir])

fid = fopen([saveDir '\simulation info ' num2str(diffusivity(1)) ' to ' num2str(diffusivity(end)) '.txt'],'w');
fprintf(fid,'%s\r\n','Training condition summary');
fprintf(fid,'Image dimension     = %d - by - %d pixel\r\n',dim(1),dim(2));
fprintf(fid,'Exposure time       = %d ms\r\n',exposure_t);
fprintf(fid,'Pixel size          = %d nm\r\n',pixel_length);
fprintf(fid,'Trajectory interval = %f ms\r\n',sim_t);
fprintf(fid,'Frame length        = %d\r\n',Frame_length);
fprintf(fid,'Photon burst        = %d per ms\r\n',photon_burst);
fprintf(fid,'Noise level         = %d %d\r\n',background{:});
fprintf(fid,'Particle density    = mean: %.2f, std: %.3f\r\n',particle_density(1),particle_density(2));
fprintf(fid,'Diffusivity range   = %.2f to %.2f\r\n',diffusivity(1),diffusivity(end));

fclose(fid);

clearvars -except saveDir