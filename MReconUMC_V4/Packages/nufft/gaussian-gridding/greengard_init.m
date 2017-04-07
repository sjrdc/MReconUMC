function MR = greengard_init( MR )
%% Initialize the greengard nufft operator

% Get dimensions for data handling
num_data=numel(MR.Data);
for n=1:num_data;MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(1:2)=MR.Parameter.Gridder.OutputMatrixSize{n}(1:2);end

% If DCF is empty, fill with ones
if isempty(MR.Parameter.Gridder.Weights)
    MR.Parameter.Gridder.Weights=ones(size(MR.Parameter.Gridder.Kpos));
end

% Make DCF operator
W=DCF(cellfun(@sqrt,MR.Parameter.Gridder.Weights,'UniformOutput',false));
MR.UMCParameters.AdjointReconstruction.DensityOperator=W;

% Call gridder differently when parall computing is enabled
if strcmpi(MR.UMCParameters.GeneralComputing.ParallelComputing,'no')
    G=GG(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,0);
else
    G=GG(MR.Parameter.Gridder.Kpos,MR.UMCParameters.AdjointReconstruction.IspaceSize,MR.UMCParameters.AdjointReconstruction.KspaceSize,MR.UMCParameters.GeneralComputing.NumberOfCPUs);
end

% Assign operator
MR.UMCParameters.AdjointReconstruction.NUFFTOperator=G;

% END
end