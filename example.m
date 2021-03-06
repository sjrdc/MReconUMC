%% Demonstration script
% Note: for windows replace all "/" with "/" and vice versa.
clear all;close all;clc
datapath1='../Data/SOS_GA/bs_06122016_1607476_2_2_wip4dga1pfnoexperiment1senseV4.raw'; % Golden angle stack-of-stars
datapath2='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/Internal_data/Radial3D_data/U2/20170926_3D_Abdomen/Scan1/ut_26092017_1534464_12_2_wipt3dgameuteclearV4.raw'; % Golden angle stack-of-stars ute
%% Readers & Writers
% Get k-space data from lab/raw
kdata=reader_reconframe_lab_raw(datapath1);

% Get images from par/rec
%images=reader_reconframe_par_rec('/local_scratch/tbruijne/WorkingData/4DLung/Scan2/ha_27112017_1534304_8_1_wip_t_t1_4d_tfeV4.rec');

% Extract PPE parameters (from reconframe object)
[kdata,MR]=reader_reconframe_lab_raw(datapath1);
ppe_pars=reader_reconframe_ppe_pars(MR);

% Write data to dicom
%MR.Perform;
%writeDicomFromMRecon(MR,MR.Data,'../Main_Recon_Library/');

%% NUFFT toolboxes 2D
% Radial k-space trajectory (/./ not /../)
[~,MR]=reader_reconframe_lab_raw(datapath1);
kdim=size(MR.Data);
ppe_pars=reader_reconframe_ppe_pars(MR);

% Trajectory & density
traj=radial_trajectory(kdim(1:2),ppe_pars.goldenangle);
dcf=radial_density(traj);

% FFT in z
MR.Data=ifft(MR.Data,[],3);

% Radial phase correction
MR.Data=radial_phase_correction_zero(MR.Data);

% Initialize Fessler 2D nufft operator
F2D=FG2D(traj,[kdim(1:2) 1]);

% Do the Fessler gridding
tic
for z=1:size(MR.Data,3)
    for c=1:size(MR.Data,4)
        Fessler2D(:,:,z,c)=F2D'*(MR.Data(:,:,z,c).*dcf);
    end    
end
toc
close all;figure,imshow3(abs(Fessler2D(:,:,5:28,1)),[],[4 6])

% Do the Greengard gridding
G2D=GG2D(traj,[kdim(1:2) 1]);

% Do the Greengard gridding
tic
for z=1:size(MR.Data,3)
    for c=1:size(MR.Data,4)
        Greengard2D(:,:,z,c)=G2D'*(MR.Data(:,:,z,c).*dcf);
    end    
end
toc
figure,imshow3(abs(Greengard2D(:,:,5:28,1)),[],[4 6])

% Do the Flat Iron gridding
FF2D=FI2D(traj,[kdim(1:2) 1]);
tic
for z=1:size(MR.Data,3)
    for c=1:size(MR.Data,4)
        FlatIron2D(:,:,z,c)=FF2D'*(MR.Data(:,:,z,c).*dcf);
    end    
end
toc
figure,imshow3(abs(FlatIron2D(:,:,5:28,1)),[],[4 6])

%% NUFFT toolboxes 3D
[~,MR]=reader_reconframe_lab_raw(datapath1);
kdim=size(MR.Data);
ppe_pars=reader_reconframe_ppe_pars(MR);
traj=radial_trajectory(kdim(1:3),ppe_pars.goldenangle);
dcf=radial_density(traj);
kspace_data=MR.Data;
MR.Data=radial_phase_correction_model(MR.Data,traj);

% Initialize Fessler 3D nufft operator
F3D=FG3D(traj,[kdim(1:3) 1]);
tic
for c=1:1%size(MR.Data,4)
    Fessler3D(:,:,:,c)=F3D'*(MR.Data(:,:,:,c).*dcf);
end
toc
close all;figure,imshow3(abs(Fessler3D(:,:,5:28,1)),[],[4 6])

% 3D Greengard gridding
G3D=GG3D(traj,[kdim(1:3) 1]);
tic
for c=1:1%size(MR.Data,4)
    Greengard3D(:,:,:,c)=G3D'*(MR.Data(:,:,:,c).*dcf);
end
toc
figure,imshow3(abs(Greengard3D(:,:,5:28,1)),[],[4 6])

% 3D FlatIron grdding
FF3D=FI3D(traj,[kdim(1:3) 1]);
tic
for c=1:1%size(MR.Data,4)
    FlatIron3D(:,:,:,c)=FF3D'*(MR.Data(:,:,:,c).*dcf);
end
toc
figure,imshow3(abs(FlatIron3D(:,:,5:28,1)),[],[4 6])

%% Coil sensitivity map estimation (espirit and openadapt)
[~,MR]=reader_reconframe_lab_raw(datapath1);
kdim=size(MR.Data);
ppe_pars=reader_reconframe_ppe_pars(MR);
traj=radial_trajectory(kdim(1:2),ppe_pars.goldenangle);
dcf=radial_density(traj);
MR.Data=ifft(MR.Data,[],3);
MR.Data=radial_phase_correction_zero(MR.Data);

% Create low-res images using a k-space mask
lr=5; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:2),lr);
F2D=FG2D(traj,[kdim(1:2) 1]);
for z=1:size(MR.Data,3)
    for c=1:size(MR.Data,4)
        Fessler2D_LR(:,:,z,c)=F2D'*(MR.Data(:,:,z,c).*dcf.*mask);
    end    
end
close all;figure,imshow3(abs(Fessler2D_LR(:,:,5:28,1)),[],[4 6])

% Openadapt 2D
for z=1:size(MR.Data,3)
    CSM_opd_2D(:,:,z,:)=openadapt(Fessler2D_LR(:,:,z,:));
end
figure,imshow3(abs(CSM_opd_2D(:,:,15,:)),[],[2 6])

% Openadapt 3D
CSM_opd_3D=openadapt(Fessler2D_LR);
figure,imshow3(abs(CSM_opd_3D(:,:,15,:)),[],[2 6])

% ESPIRiT 2D (either matlab-based (slow) or bart-based (fast)
for z=15:15%1:size(MR.Data,3)
    csm(:,:,z,:)=espirit(Fessler2D_LR(:,:,z,:),'bart');
end
figure,imshow3(abs(csm(:,:,15,:)),[],[2 6])

%% Iterative density estimation code (only 3D)
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:3),1);
dcf=iterative_dcf_estimation(traj);
kspace_data=radial_phase_correction_zero(kspace_data);

% Initialize Fessler 3D nufft operator
F3D=FG3D(traj,[kdim(1:3) 1]);
for c=1:1%size(MR.Data,4)
    Fessler3D(:,:,:,c)=F3D'*(kspace_data(:,:,:,c).*dcf);
end

%% Estimate respiratory signal from multi-channel k-space data + motion weighted reconstruction
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);

% Estimation respiratory motion signal from multichannel data
respiration=radial_3D_estimate_motion(kspace_data);

% Get soft-weights
recon_matrix_size=round(max(traj(:)));
soft_weights=mrriddle_respiratory_filter(respiration,recon_matrix_size);

% Apply motion-weighted reconstruction
F2D=FG2D(traj,[kdim(1:2) 1]);
for z=1:size(kspace_data,3)
    for c=1:size(kspace_data,4)
        Fessler2D_SW(:,:,z,c)=F2D'*(kspace_data(:,:,z,c).*dcf.*repmat(soft_weights,[kdim(1) 1]));
    end    
end
close all;figure,imshow3(abs(Fessler2D_SW(:,:,5:28,1)),[],[4 6])

%% 4D (x,y,z,resp) reconstruction
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);
respiration=radial_3D_estimate_motion(kspace_data);

% Define number of phases and do phase-binning
n_phases=4;
respiratory_bin_idx=respiratory_binning(respiration,n_phases);

% Use the binning to transform the data matrices
[kspace_data,traj,dcf]=respiratory_data_transform(kspace_data,traj,dcf,respiratory_bin_idx,n_phases);

% Fourier transform on new matrices
kdim=size(kspace_data);
F2D=FG2D(traj,kdim);
Recon_4D=F2D'*(kspace_data.*repmat(dcf,[1 1 kdim(3) kdim(4)]));
slicer(squeeze(Recon_4D(:,:,19,:,:)))

%% Noise prewhitening 
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);

% Prewhitenen noise and do recons for both cases
kspace_data_prew=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data_prew=ifft(kspace_data_prew,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);
kspace_data_prew=radial_phase_correction_zero(kspace_data_prew);
F2D=FG2D(traj,[kdim(1:2) 1]);
for z=1:size(kspace_data,3)
    for c=1:1%size(kspace_data,4)
        normal(:,:,z,c)=F2D'*(kspace_data(:,:,z,c).*dcf);
        prew(:,:,z,c)=F2D'*(kspace_data_prew(:,:,z,c).*dcf);
    end    
end

% Show difference
normal=normal/mean(abs(normal(:)));
prew=prew/mean(abs(prew(:)));
A=zeros(140,140,12);
A(:,:,1:6)=normal(:,:,10:2:20,1);
A(:,:,7:12)=prew(:,:,10:2:20,1);
figure,imshow3(abs(A),[0 30],[2 6])

%% Fitting radial phase correction
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_model(kspace_data,traj);
F2D=FG2D(traj,[kdim(1:2) 1]);
for z=1:size(kspace_data,3)
    for c=1:1%size(kspace_data,4)
        img(:,:,z,c)=F2D'*(kspace_data(:,:,z,c).*dcf);
    end    
end
close all;figure,imshow3(abs(img(:,:,5:28,1)),[],[4 6])

%% 2D Iterative sense least squares (L2+TV) -- matlab implementation
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);
kspace_data=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);

% Estimate coil maps from lowres images
lr=5; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:2),lr);
F2D=FG2D(traj,kdim);
lowres=F2D'*(kspace_data.*repmat(dcf.*mask,[1 1 kdim(3) kdim(4)]));
csm=openadapt(lowres);

% Initialize structure to send to the solver for 2D
par.kdim=c12d([kdim(1:2) 1 kdim(4)]);
par.idim=idim_from_trajectory(traj,par.kdim);
par.Niter=1;
par.N=FG2D(traj,[kdim(1:2) 1 kdim(4)]);
par.W=DCF(sqrt(dcf));
par.TV=TV_sparse(par.idim,[1 1 0 0 0],[10 10 0 0 0]);

% Loop over slices and do itSense
for z=1:size(kspace_data,3)
    par.y=par.W*kspace_data(:,:,z,:,:,:,:,:,:,:,:);
    par.S=SS(csm(:,:,z,:));  
    [itsense(:,:,z),~]=configure_regularized_iterative_sense(par);    
end

%% 3D Iterative sense least squares (L2+TV) -- matlab implementation
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);
kspace_data=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:3),1);
dcf=radial_density(traj);
kspace_data=radial_phase_correction_model(kspace_data,traj); % Cannot do the zero phase correction for 3D gridding

% Estimate coil maps from lowres images
lr=5; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:3),lr);
F3D=FG3D(traj,kdim);
lowres=F3D'*(kspace_data.*repmat(dcf.*mask,[1 1 1 kdim(4)]));
csm=openadapt(lowres);

clear par
% Initialize structure to send to the solver for 3D
par.kdim=c12d(kdim(1:4));
par.idim=idim_from_trajectory(traj,par.kdim);
par.Niter=1;
par.N=F3D;
par.W=DCF(sqrt(dcf));
par.TV=TV_sparse(par.idim,[1 1 1 0 0],[10 10 10 0 0]);

% Loop over slices and do itSense
par.y=par.W*kspace_data;
par.S=SS(csm);  
[itsense,~]=configure_regularized_iterative_sense(par);    

%% L1 iterative TV sense (L1+TV) -- matlab implementation
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);
kspace_data=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);

% Estimate coil maps from lowres images
lr=5; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:2),lr);
F2D=FG2D(traj,kdim);
lowres=F2D'*(kspace_data.*repmat(dcf,[1 1 kdim(3) kdim(4)]));
csm=openadapt(lowres);

%Initialize structure to send to the solver
par.kdim=c12d([kdim(1:2) 1 kdim(4)]);
par.idim=idim_from_trajectory(traj,par.kdim);
par.Niter=1;
par.N=FG2D(traj,[kdim(1:2) 1 kdim(4)]);
par.W=DCF(sqrt(dcf));
par.TV=TV_sparse(par.idim,[1 1 0 0 0],[0 0 0 0 0]);
par.beta=.2; % step-size of CG

for z=1:size(kspace_data,3)
    par.y=par.W*kspace_data(:,:,z,:,:,:,:,:,:,:,:);
    par.S=SS(csm(:,:,z,:));  
    [compressed_sense(:,:,z),~]=configure_compressed_sense(par);   
end

%% Real-time 3D L1 TV compressed sense
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);
kspace_data=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:3),1);
dcf=radial_density(traj);
kspace_data=radial_phase_correction_model(kspace_data,traj); % Cannot do the zero phase correction for 3D gridding

% Estimate coil maps from lowres images
lr=5; % 5 times lower resolution
mask=radial_lowres_mask(kdim(1:3),lr);
F3D=FG3D(traj,kdim);
lowres=F3D'*(kspace_data.*repmat(dcf.*mask,[1 1 1 kdim(4)]));
csm=openadapt(lowres);

% Transform data dimensions to dynamics
R=10;
[kspace_data,traj,dcf]=radial_goldenangle_undersample(R,kspace_data,traj,dcf);
kdim=size(kspace_data);

% MATLAB solver (nlcg)
par.kdim=c12d(kdim);
par.idim=idim_from_trajectory(traj,par.kdim);
par.Niter=5;
par.N=FG3D(traj,kdim(1:5));
par.W=DCF(sqrt(dcf));
par.TV=TV_sparse(par.idim,[0 0 0 0 1],[0 0 0 0 50]);
par.beta=.2; % step-size of CG
par.y=par.W*kspace_data;
par.S=SS(csm);  

% Nufft recon
recon_nufft=par.S*(par.N'*(par.W*(par.W*kspace_data)));
close all;figure,imshow3(abs(recon_nufft(:,:,5:28,1,1)),[],[4 6])

% CS recon
compressed_sense=configure_compressed_sense(par);   
figure,imshow3(abs(compressed_sense(:,:,5:28,1,1)),[],[4 6])

%% View sharing operation, can be in any dimensions
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);
kspace_data=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);

% Transform data dimensions to dynamics
R=10;
[kspace_data,traj,dcf]=radial_goldenangle_undersample(R,kspace_data,traj,dcf);

% View sharing across dynamics
width=2;
kwic=[]; % Filters are supported as function handles
kspace_data=radial_view_sharing(kspace_data,kwic,width,[2 5]);
traj=radial_view_sharing(traj,kwic,width,[3 5]);
dcf=radial_view_sharing(dcf,kwic,width,[2 5]);
kdim=size(kspace_data);

% NUFFT
F2D=FG2D(traj,kdim);
img=F2D'*(kspace_data.*repmat(dcf,[1 1 kdim(3) kdim(4) 1]));
idim=size(img);
S=SS(ones(idim(1:4))); % Sum of squares
img=S*img;
for t=1:idim(5)
    img(:,:,:,:,t)=img(:,:,:,:,t)/max(matrix_to_vec(abs(img(:,:,:,:,t))));
end
close all;slicer(squeeze(img))

%% Load gradient impulse response function and process a UTE acquisition
[kspace_data,MR]=reader_reconframe_lab_raw(datapath2);
kspace_data=kspace_data{1};
ppe_pars=reader_reconframe_ppe_pars(MR);
kdim=size(kspace_data);
pathgirf='/nfs/bsc01/researchData/USER/tbruijne/Projects_Software/GIRFs/girf_u2.mat';

% Get k-space trajectory per gradient (carefull its in cells)!
[girf_k,girf_phase]=GIRF(MR,pathgirf,'verbose');
girf_k={girf_k{1}};
girf_phase={girf_phase{1}};
%girf_k{1}(1:2,:)=girf_k{1}([2 1],:);

% Change to k-space trajectory for the experiment
traj=ute_trajectory_girf(kdim(1:3),1,girf_k);
dcf=iterative_dcf_estimation(traj);

% GIRF phase correction
kspace_data=radial_phase_correction_girf(kspace_data,1,kdim(1:2),girf_phase);

% Normal stuff
kspace_data=ifft(kspace_data,[],3);
F2D=FG2D(traj(:,:,:,16),kdim);
img=F2D'*(kspace_data.*repmat(dcf,[1 1 1 kdim(4) 1]));
img=sum(abs(img),4);
close all;slicer(flip(flip(squeeze(img),3),1),[1 1 2])

%% Design my own coil compression function
[kspace_data,MR]=reader_reconframe_lab_raw(datapath1,1,1);
[noise_data,~]=reader_reconframe_lab_raw(datapath1,5,1);
kspace_data=noise_prewhitening(kspace_data,noise_data);
kdim=size(kspace_data);
traj=radial_trajectory(kdim(1:2),1);
dcf=radial_density(traj);
kspace_data=ifft(kspace_data,[],3);
kspace_data=radial_phase_correction_zero(kspace_data);

% Coil compression (after phase corrections)
nCh=1;
kspace_data=coil_compression(kspace_data,nCh);
kdim=c12d(size(kspace_data));
F2D=FG2D(traj,kdim);
img=F2D'*(kspace_data.*repmat(dcf,[1 1 kdim(3) kdim(4) 1]));
img=sum(abs(img),4);
%close all;figure,imshow3(abs(img(:,:,5:28,1)),[],[4 6])