saveDir         = uigetdir('H:\Fake Dax for NN analysis','Select fordler to save dax files');
%saveDir = 'H:\Fake Dax for NN analysis\20201106 Training oneDax dimmer dye';
dim             = [24 24];          %simulation image size (x,y) in pixel
exposure_t      = 0.00899*1000;               %simulation exposure time in ms unit
roi_width       = 7;               %size of ROI extraction. e.g. 13-by-13 square
particle_density= [1 0];            %particle per frame, [mean s.d.] of normal distribution. For constant number throughout the frame, set s.d. = 0
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

disp(' ')
disp(['Simulation complete: Saved to ' saveDir])

fid = fopen([saveDir '\simulation info.txt'],'wt');
fprintf(fid,'%s\r\n','Simulation condition summary');
fprintf(fid,'Image dimension     = %d - by - %d pixel\r\n',dim(1),dim(2));
fprintf(fid,'Exposure time       = %d ms\r\n',exposure_t);
fprintf(fid,'ROI size suggestion = %d pixel\r\n',roi_width);
fprintf(fid,'Trajectory interval = %f ms\r\n',sim_t);
fprintf(fid,'Frame length        = %d\r\n',Frame_length);
fprintf(fid,'Photon burst        = %d per ms\r\n',photon_burst);
fprintf(fid,'Noise level         = %d\r\n',background);
fprintf(fid,'Particle density    = mean: %.2f, std: %.3f\r\n',particle_density(1),particle_density(2));
fprintf(fid,'Diffusivity (map)     [um2/s]');
for i = 1:size(diffusivity,2)
    fprintf(fid,['\r\n    ' mat2str(diffusivity{i})]);
end
fclose(fid);

clearvars