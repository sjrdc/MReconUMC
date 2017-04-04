function noise_prewhitening( MR )
% Perform noise_prewhitening

if strcmpi(MR.UMCParameters.SystemCorrections.NoisePreWhitening,'no')
    return
end

% Calculate noise covariance matrix
MR.UMCParameters.SystemCorrections.NoiseCorrelationMtx=noise_covariance_mtx(squeeze(MR.UMCParameters.SystemCorrections.NoiseData));

% Calculate noise decorrelation matrix
MR.UMCParameters.SystemCorrections.NoiseDecorrelationMtx=noise_decorrelation_mtx(MR.UMCParameters.SystemCorrections.NoiseCorrelationMtx);

% Apply noise prewhitening
dims=size(MR.Data);dims(end+1:11)=1;
MR.Data=reshape(permute(MR.Data,[4 1 2 3 5 6 7 8 9 10 11]),[dims(4) prod(dims)/dims(4)]);
MR.Data=single(permute(reshape(MR.UMCParameters.SystemCorrections.NoiseDecorrelationMtx*MR.Data,[dims(4) dims([1:3 5:11])]),[2 3 4 1 5 6 7 8 9 10 11]));

% Remove noise samples
MR.UMCParameters.SystemCorrections.NoiseData=[];

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
   subplot(338);imagesc(abs(MR.UMCParameters.SystemCorrections.NoiseCorrelationMtx));colormap jet;axis off;title('Noise covariance matrix');colorbar
end    

% END
end