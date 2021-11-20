function daxmovie = FreeDmap_to_Dax_trainingset_oneDax_gaussian_background(Dmap,dim,FrameLength,Particle_density,exposure_t,sim_t,photon_burst,bg,pl,sig)

%------------------------------------------------
% This function generates Dax images for motion-blur NN analysis training
%--------------------------------------------------------------------------
% Input:
% Dmap: Diffusivity in um2/s unit. 
% dim: Frame size
% FrameLength: Length of simulation frame
% Particle_density: [Mean sigma] of normal distribution of particle per frame
% sim_t: random-walk step interval in ms
% exposure_t: exposure time in unit of ms
% pl : pixel length in um
% bg: [mean sd] of Gaussian distribution
% Photon_burst: photon count per ms
% sig: PSF sigma assuming gaussian
%--------------------------------------------------------------------------
% Ha Park
% October 17, 2021
% Version 3.0
%

sim_step = exposure_t/sim_t;

%NA = 1.40; % Numerical Aperture
%wl = 0.570; % Emission wavelength, in um
%sig = 0.61 * wl / NA /2.355;% psf std, in um 

gain_factor = 20;
daxmovie = zeros(dim(2),dim(1),FrameLength);
[x,y] = meshgrid(1:dim(1),1:dim(2));

for f = 1:FrameLength
   N_frame = Particle_density(1) + round(randn*Particle_density(2));
   frame = double(normrnd(bg(1),bg(2),dim(2),dim(1)));
   cur_pos = ([dim(1) dim(2)]/2 + rand(1,2)-1)*pl;
   for t = 1:sim_step+1
       ang = 2*pi*rand(N_frame,1);
       step = 2*sqrt(Dmap*sim_t/1000).*[cos(ang) -sin(ang)];
       cur_pos = cur_pos + step;
       bcx = find(cur_pos(:,1) < 0 | cur_pos(:,1) > dim(1)*pl);
       bcy = find(cur_pos(:,2) < 0 | cur_pos(:,2) > dim(2)*pl);
       
       cur_pos(bcx,1) = cur_pos(bcx,1) - 2*step(bcx,1);
       cur_pos(bcy,2) = cur_pos(bcy,2) - 2*step(bcy,2);
       
       for n = 1:N_frame
           frame = frame + sim_t*photon_burst*gain_factor/((sig/pl)^2*2*pi)*exp(-(x - cur_pos(n,1)/pl - 0.5).^2/(2*(sig/pl)^2)-(y - cur_pos(n,2)/pl - 0.5).^2/(2*(sig/pl)^2));
       end
   end
   frame = uint16(frame);
  daxmovie(:,:,f) = frame;

end
