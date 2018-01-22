function SystemCorrections( MR )
%System corrections such as noise prewhitening and phase corrections are
% adressed in this routine.
%
% 20170717 - T.Bruijnen

%% Logic & display 
% If simulation mode is activated this is not required
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    return;
end

% Notification
fprintf('Applying system corrections ......................  \n');tic

%% Systemcorrections
% Perform noise prewhitening
noise_prewhitening(MR);

% UTE phase ramp corrections to shift FOV
ute_fovcorrection(MR);

% Do 1D fft in z-direction for stack-of-stars if 2D nufft is selected and
% zero phase correction is used
if (strcmpi(MR.Parameter.Scan.ScanMode,'3D') && ~strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'reconframe') && strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D'))
    % FFTshift stuffs
    if mod(MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(3),2)>0
        MR.Data=cellfun(@(v) ifft(ifftshift(v,3),MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(3),3),MR.Data,'UniformOutput',false); 
    else
        MR.Data=cellfun(@(v) ifft(v,MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(3),3),MR.Data,'UniformOutput',false); 
    end
    
	MR.Parameter.ReconFlags.isimspace=[0,0,1]; 
    
    % Change so called k-space
end

% Radial phase correction functions
radial_phasecorrection(MR);



%END
end
