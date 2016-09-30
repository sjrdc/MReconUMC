%% MRECONUMC
%% Initialize and generate path
clear all;clc;close all;clear classes
curdir=which('MRECON.m');
cd(curdir(1:end-8))
addpath(genpath(pwd))
%root=[pwd,'/Data/'];
root='/global_scratch/Tom/Scan_Results/20160627_GA_2D3D_phantom/';
scan=12;

%% Linear Recon 2D Golden angle data 

clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.LinearReconstruction.PrototypeMode=25;
%MR.UMCParameters.GeneralComputing.ParallelComputing='no';
%MR.Parameter.Gridder.AlternatingRadial='no';
%MR.UMCParameters.LinearReconstruction.Autocalibrate='yes';
%MR.UMCParameters.NonlinearReconstruction.NonlinearReconstruction='yes';
%MR.UMCParameters.LinearReconstruction.R=6;
MR.UMCParameters.RadialDataCorrection.GradientDelayCorrection='yes';
%MR.UMCParameters.LinearReconstruction.SpatialResolution=2;
%MR.UMCParameters.RadialDataCorrection.PhaseCorrection='zero';
%MR.UMCParameters.LinearReconstruction.NUFFTMethod='mrecon';
%MR.UMCParameters.LinearReconstruction.CombineCoils='no';
MR.PerformUMC;


