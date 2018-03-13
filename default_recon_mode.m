
%% Setup path and select root of data
clear all;clc;clear classes;close all;restoredefaultpath
addpath(genpath('/nfs/bsc01/researchData/USER/tbruijne/Projects_Software/Reconframe/MRecon-3.0.553/'))
addpath(genpath('/local_scratch/tbruijne/BART/MReconUMCBART'))
cd('/local_scratch/tbruijne/BART/MReconUMCBART');
addpath(fullfile('/local_scratch/tbruijne/BART/bart-0.4.02/','matlab'));
setenv('TOOLBOX_PATH','/local_scratch/tbruijne/BART/bart-0.4.02/');
root='/local_scratch/tbruijne/WorkingData/DCE/';
%root='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/Internal_data/Radial3D_data/U2/20170928_4D_abdomen/';
%root='/nfs/bsc01/researchData/USER/tbruijne/MR_Data/Internal_data/Chewing_data/Vol1_Stefan/';
scan=1;

%%
clear MR
MR=MReconUMC(root,scan);
MR.Parameter.Parameter2Read.ky=MR.Parameter.Parameter2Read.ky(1:1040);
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.IterativeReconstruction.TVLambda=[0 0 0 0 0.01 0 ];
MR.UMCParameters.IterativeReconstruction.WaveletLambda=0.005;
MR.UMCParameters.IterativeReconstruction.SplitDimension=3;
MR.UMCParameters.IterativeReconstruction.MaxIterations=200;
%MR.Parameter.Recon.ArrayCompression='yes';
%MR.Parameter.Recon.ACNrVirtualChannels=20;
MR.UMCParameters.AdjointReconstruction.R=80;
MR.PerformUMC;


%%
