function FreeDmap_to_Dax_simulation(OutDir,FileName,Dmap,dim,FrameLength,roi_width,Particle_density,exposure_t,sim_t,photon_burst,bg,sig,pl,gain_factor)

%------------------------------------------------
% This function generates simulated Dax images for motion-blur NN analysis
%--------------------------------------------------------------------------
% Input:
% OutDir: save path of Dax file
% FileName: Dax file name
% Dmap: Diffusivity map in um2/s unit. Will be rescaled into frame dimensions
% dim: Frame size in pixel [x y]
% FrameLength: Length of simulation frame
% Particle_density: [Mean sigma] of normal distribution of particle per frame
% roi_width: width of sampling ROI edge in unit of pixel
% sim_t: simulation time interval
% exposure_t: exposure time in unit of ms
% photon_burst: photon count of molecuel per ms
% bg: Gaussian background noise [mean std]
% sig: sigma PSF assuming gaussian
% pl: pixel length in um
% gain_factor: gain factor of imaging
%--------------------------------------------------------------------------
% Ha Park
% March 18, 2022
% Version 4.0


Dsize = size(Dmap');
disp('Initializing data simulation - generating dax file.')
disp(' ')
disp(['Image dimension: ' num2str(dim(1)) '-by-' num2str(dim(2)) ' pixel'])
disp(['Total frames: ' num2str(FrameLength)])
disp(' ')

rhw = (roi_width-1)/2;
sim_step = exposure_t/sim_t;

xs = dim(1)/Dsize(1)*pl;
ys = dim(2)/Dsize(2)*pl;
daxmovie = zeros(dim(2),dim(1),FrameLength);
[x,y] = meshgrid(1:dim(1),1:dim(2));

for f = 1:FrameLength
   N_frame = Particle_density(1) + round(randn*Particle_density(2));
   frame = double(normrnd(bg(1),bg(2),dim(2),dim(1)));
   
   if N_frame > 0
       % Generating and converting Random starting position into um scale
       xy_frame = rhw + [rand(N_frame,1,'double')*(dim(1)-rhw*2) rand(N_frame,1,'double')*(dim(2)-rhw*2)];
       cur_pos = xy_frame*pl;
       for t = 1:sim_step+1
           % assign D based on each particle's position
           Dx = ceil(cur_pos(:,1)/xs)-1; Dy = ceil(cur_pos(:,2)/ys);
           D = Dmap(Dx*Dsize(2)+Dy)';
           % Generate and apply random displacement
           ang = 2*pi*rand(N_frame,1);
           step = 2*sqrt(D*sim_t/1000).*[cos(ang) -sin(ang)];
           cur_pos = cur_pos + step;
           % bounceback any molecule moving out of frame
           bcx = find(cur_pos(:,1) < 0 | cur_pos(:,1) > dim(1)*pl);
           bcy = find(cur_pos(:,2) < 0 | cur_pos(:,2) > dim(2)*pl);
           
           cur_pos(bcx,1) = cur_pos(bcx,1) - 2*step(bcx,1);
           cur_pos(bcy,2) = cur_pos(bcy,2) - 2*step(bcy,2);
           
           % Project PSF
           for n = 1:N_frame
               frame = frame + sim_t*photon_burst*gain_factor/((sig/pl)^2*2*pi)*exp((-(x - cur_pos(n,1)/pl - 0.5).^2-(y - cur_pos(n,2)/pl - 0.5).^2)/(2*(sig/pl)^2));
           end
       end
   end
   
   if ~mod(f,1000)
    fprintf('%d frames completed\n',f)
   end

   frame = uint16(frame);
   daxmovie(:,:,f) = frame;
end

WriteDax(daxmovie,'daxName',FileName,'folder',[OutDir '\']);

disp(' ')
disp(['Simulation complete: Saved ' FileName '.dax to ' OutDir])