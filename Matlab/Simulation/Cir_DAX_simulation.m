saveDir         = uigetdir('H:\Fake Dax for NN analysis','Select fordler to save dax files');
%saveDir = 'H:\Fake Dax for NN analysis\20201106 Training oneDax dimmer dye';
DaxNameHead     = 'NN spatial mapping';  %not include .dax in the string
dim             = [24 24];          %simulation image size (x,y) in pixel
exposure_t      = 0.00899*1000;;               %simulation exposure time in ms unit
roi_width       = 7;               %size of ROI extraction. e.g. 13-by-13 square
particle_density= [1 0];            %particle per frame, [mean s.d.] of normal distribution. For constant number throughout the frame, set s.d. = 0
Frame_length    = 100000;            %simulation movie length
sim_t           = 1/100;           %number of simulation steps per frame/exposure time
photon_burst    = 100;
background      = [1000 150];
sig             = 0.14;             %HWHM of PSF in um

diffusivity = {[2; 4]};
Rlist = 4;
%Radius of circular pattern in pix scale. 1 pix = 0.16um

D_num = size(diffusivity,2);

for r = 1:size(Rlist,2)
   for d = 1:D_num
      disp(' ')
      Cir_Dmap_to_Dax_simulation(saveDir, [DaxNameHead '_D_' num2str(d) 'th_R_' num2str(Rlist(r))], diffusivity{d},Rlist(r), ...
         dim, Frame_length, roi_width, particle_density, exposure_t, sim_t, photon_burst,background,sig);
   end
end

disp(' ')
disp(['Simulation complete: Saved to ' saveDir])

clearvars