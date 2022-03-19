saveDir         = uigetdir('','Select folder to save');
dim             = [21 21];          %simulation image size (x,y) in pixel
exposure_t      = 8.904;            %simulation exposure time in ms unit
particle_density= [1 0];            %particle per frame, [mean s.d.] of normal distribution. For constant number throughout the frame, set s.d. = 0
N_per_D         = 400;              %simulation movie length per diffusivity
sim_t           = 1/100*exposure_t;                                 %simulation time interval in ms
photon_burst    = [60 80 100 120 150 180 200 220 250];              %photon per molecule per frame per millisecond
background      = {[400 60] [500 70] [650 90] [800 100] [950 120] [1100 150]}; %[avg sd] of shot noise
diffusivity     = (0:0.05:6)';
pixel_length    = 160;              %pixel length in nm
sig             = 0.1380746;        %PSF size in um
gain_factor     = 20;               %gain factor of imaging setup
D_num = size(diffusivity,1);

for i = 1:length(photon_burst)
    for j = 1:length(background)
        daxmovie = zeros(dim(2),dim(1),Frame_length*D_num);
        DaxNameHead     = sprintf('%dHz_bg%d_photon %d_%dto%d',round(1000/exposure_t),background{j}(1),photon_burst(i),diffusivity(1),diffusivity(end));  %not include .dax in the string
        for d = 1:D_num
            tempdax = Trainingset_gaussian_background(diffusivity(d), ...
                dim, N_per_D, particle_density, exposure_t, sim_t, photon_burst(i), background{j}, pixel_length/1000, sig, gain_factor);
            daxmovie(:,:,(d-1)*N_per_D+1:d*N_per_D) = tempdax;
        end
        WriteDax(daxmovie,'daxName',DaxNameHead,'folder',[saveDir '\']);
    end
end

disp(' ')
disp(['Simulation complete: Saved to ' saveDir])