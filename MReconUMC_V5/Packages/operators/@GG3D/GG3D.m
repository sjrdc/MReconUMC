function  gg = GG3D(k,Id,Kd,varargin)
% Greengard Gaussian gridding for 12D data structures in 3D
% Input:
% 	k:   double 11D struct containg k-space coordinates [-.5 .5] with dimensions [nkx nky nkz nc ndyn nechos nphases nmixes nlocs nex1 nex2 navgs]
%   Id:  double 11D struct with Image space dimensions
%   Kd:  double 11D struct with K-space dimensions
%   varagin: Number of CPU's to use for parallel computing
% 
% Output: gg : structure to pass as the nufft operator
%
% Tom Bruijnen - University Medical Center Utrecht - 201704 

% Parallelization
if nargin<3
    gg.parfor=0;
else
    gg.parfor=varargin{1};
end

% Number of data chunks
gg.num_data=numel(k); 			

% FFT sign 1=adjoint operation and -1=forward
gg.adjoint=1; 			

% Scale k-space between [-2pi 2pi]
gg.k=cellfun(@(x) x*2*pi,k,'UniformOutput',false);

% Precision for the gridding
gg.precision=1e-01; % range: 1e-1 - 1e-15

% Number of k-space points per gridding operation
for n=1:gg.num_data;gg.nj{n}=numel(k{n}(1,:,:,:,1));end

% Image space dimensions
gg.Id=Id;

% K-space dimensions
gg.Kd=Kd;

% Mix the readouts and samples in advance
for n=1:gg.num_data;gg.k{n}=reshape(gg.k{n},[3 gg.Kd{n}(1)*gg.Kd{n}(2)*gg.Kd{n}(3) 1 gg.Kd{n}(5:12)]);end

% Define seperate class
gg=class(gg,'GG3D');

%END
end