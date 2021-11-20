function Cir_Dmap_to_Dax_simulation(OutDir,FileName,Dmap,RSize,dim,FrameLength,roi_width,Particle_density,exposure_t,sim_t,photon_burst,bg,sig)

%------------------------------------------------
% This function generates simulated Dax images for motion-blur NN analysis
%--------------------------------------------------------------------------
% Input:
% OutDir: save path of Dax file
% FileName: Dax file name
% Dmap: Diffusivity map in um2/s unit. Inside diffusivity is the first
% element
% RSize: radius of circular D pattern
% dim: Frame size
% FrameLength: Length of simulation frame
% Particle_density: [Mean sigma] of normal distribution of particle per frame
% roi_width: width of sampling ROI edge in unit of pixel
% sim_step: random-walk step number
% exposure_t: exposure time in unit of ms
%--------------------------------------------------------------------------
% Ha Park
% February 15, 2021
% Version 1.0
%


disp('Initializing data simulation - generating dax file.')
disp(' ')
disp(['Image dimension: ' num2str(dim(1)) '-by-' num2str(dim(2)) ' pixel'])
disp(['Total frames: ' num2str(FrameLength)])
disp(' ')
%roi_half_width
rhw = (roi_width-1)/2;
sim_step = exposure_t/sim_t;

gain_factor = 20;
pl = 0.16; %pixel length in um
daxmovie = zeros(dim(2),dim(1),FrameLength);
[x,y] = meshgrid(1:dim(1),1:dim(2));

for f = 1:FrameLength
   N_frame = Particle_density(1) + round(randn*Particle_density(2));
   frame = double(normrnd(bg(1),bg(2),dim(2),dim(1)));
   if N_frame > 0
       xy_frame = rhw + [rand(N_frame,1,'double')*(dim(1)-rhw*2) rand(N_frame,1,'double')*(dim(2)-rhw*2)];
       cur_pos = xy_frame*pl;
       for t = 1:sim_step+1
           R_pos = double(cur_pos - dim*pl/2);
           R_dis = sqrt(R_pos*R_pos');
           D = diag(Dmap((R_dis > RSize*pl) + 1));
           ang = 2*pi*rand(N_frame,1);
           step = 2*sqrt(D*sim_t/1000).*[cos(ang) -sin(ang)];
           cur_pos = cur_pos + step;
           bcx = find(cur_pos(:,1) < 0 | cur_pos(:,1) > dim(1)*pl);
           bcy = find(cur_pos(:,2) < 0 | cur_pos(:,2) > dim(2)*pl);
           
           cur_pos(bcx,1) = cur_pos(bcx,1) - 2*step(bcx,1);
           cur_pos(bcy,2) = cur_pos(bcy,2) - 2*step(bcy,2);
           
           for n = 1:N_frame
               frame = frame + sim_t*photon_burst*gain_factor/((sig/pl)^2*2*pi)*exp(-(x - cur_pos(n,1)/pl - 0.5).^2/(2*(sig/pl)^2)-(y - cur_pos(n,2)/pl - 0.5).^2/(2*(sig/pl)^2));
           end
       end
   end
   
   frame = uint16(frame);
   daxmovie(:,:,f) = frame;
end

WriteDax(daxmovie,'daxName',FileName,'folder',[OutDir '\']);

disp(' ')
disp(['Simulation complete: Saved ' FileName '.dax to ' OutDir])