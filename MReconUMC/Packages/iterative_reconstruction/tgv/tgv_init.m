function tgv_init(MR,n,p)
% Generate a structure to feed in the tgv function

% Logic
if ~(MR.UMCParameters.IterativeReconstruction.PotentialFunction==3)
    return;end

% Dimension to iterate over (partition dimension)
it_dim=MR.UMCParameters.IterativeReconstruction.SplitDimension; % Readabillity

% TGV operates with different data dimensions [x,y,coil], so adjust
MR.UMCParameters.Operators.Id=MR.Parameter.Gridder.OutputMatrixSize{n};
MR.UMCParameters.Operators.Id([it_dim 4])=1;
MR.UMCParameters.Operators.Id=MR.UMCParameters.Operators.Id([1 2 4 3 5:12]);
MR.UMCParameters.Operators.Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};
MR.UMCParameters.Operators.Kd([it_dim 4])=1;
MR.UMCParameters.Operators.Kd=MR.UMCParameters.Operators.Kd([1 2 4 3 5:12]);

% Create density operator
MR.UMCParameters.Operators.W=DCF({dynamic_indexing(MR.Parameter.Gridder.Weights{n},it_dim,p)});

% Create nufft operator which can be 2D/3D 
% Greengard
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard')
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D')
    MR.UMCParameters.Operators.N=GG2D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing);
else
    MR.UMCParameters.Operators.N=GG3D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing);
end;end

% Fessler
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'fessler')
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D')
    MR.UMCParameters.Operators.N=FG2D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
    	{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing); 
else
    MR.UMCParameters.Operators.N=FG3D({dynamic_indexing(MR.Parameter.Gridder.Kpos{n},it_dim+1,p)},...
		{MR.UMCParameters.Operators.Id},{MR.UMCParameters.Operators.Kd},0,MR.UMCParameters.GeneralComputing.ParallelComputing); 
end;end

% Allocate raw k-space data
MR.UMCParameters.Operators.y=squeeze(double(dynamic_indexing(MR.Data{n},it_dim,p)));

% Track cost function
MR.UMCParameters.Operators.Residual=[];

% Verbose option
MR.UMCParameters.Operators.Verbose=MR.UMCParameters.ReconFlags.Verbose;