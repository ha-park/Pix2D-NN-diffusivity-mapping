saveDir         = uigetdir('','Select fordler to save dax files');
dim             = [24 24];          %simulation image size (x,y) in pixel
exposure_t      = 8.99;             %simulation exposure time in ms unit
roi_width       = 7;                %size of ROI extraction. e.g. 13-by-13 square
particle_density= [1 0];            %particle per frame, [mean s.d.] of normal distribution. For constant number throughout the frame, set s.d. = 0
<<<<<<< Updated upstream
Frame_length    = 100000;            %simulation movie length
sim_t           = 1/100;           %number of simulation steps per frame/exposure time
photon_burst    = 100;
background      = [1000 150];
sig             = 0.14;             %HWHM of PSF in um
DaxNameHead     = sprintf('%dHz_%dx%d_NN spatial mapping',round(1000/exposure_t),dim(1),dim(2));  %not include .dax in the string

diffusivity = {[2 4]};
%particle_density= {[1 0], [1 0.5], [1.2 0.3], [1.5 0.3], [2 0.5], ...
%   [2 0], [2.3 0.5], [2.5 0.5], [2.7 0.5], [3 0.7]};
%diffusivity = {[3; 5], [3; 7], [3; 10], [3 5;3 3], [3 10;3 3], [10; 3]}; 
%diffusivity = {[3; 5], [3; 7], [3; 10],[3; 15], [5; 10], [3 5;3 3], [3 15;3 3]}; 
%diffusivity = {1, 2, 3, 5, 7, 10, 15, 20}; 

D_num = size(diffusivity,2);

for d = 1:D_num
   disp(' ')
   FreeDmap_to_Dax_simulation(saveDir, [DaxNameHead '_D_' num2str(d) 'th'], diffusivity{d}, ...
        dim, Frame_length, roi_width, particle_density, exposure_t, sim_t, photon_burst,background,sig);
end
=======
Frame_length    = 100000;           %simulation frame length
sim_t           = 1/100*exposure_t; %time interval of trajectory simulation
photon_burst    = 120;              %Photon count per ms
background      = [650 90];         %[avg sd] level of shot noise
sig             = 0.1436;           %PSF size in um
pixel_length    = 0.16;              %pixel length in um
gain_factor     = 20;               %gain factor of imaging
DaxNameHead     = sprintf('%dHz_%dx%d_',round(1000/exposure_t),dim(1),dim(2));  %not include .dax in the string

diffusivity = {[2 4;2 2]};          %Free dimensional array of diffusivity in image frame
>>>>>>> Stashed changes

disp(' ')
FreeDmap_to_Dax_simulation(saveDir, DaxNameHead, diffusivity, ...
    dim, Frame_length, roi_width, particle_density, exposure_t, sim_t, photon_burst,background,sig,pixel_length,gain_factor);

disp(' ')
disp(['Simulation complete: Saved to ' saveDir])