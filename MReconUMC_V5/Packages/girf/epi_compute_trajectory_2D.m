function epi_compute_trajectory_2D(MR)

% Dont execute if 3D gridding is selected
if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D')
    return;
end

% Allocate matrix
num_data=numel(MR.Data);
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize;

% Allocate matrix
for n=1:num_data
    Kpos{n}=zeros(Kd{n}(1),Kd{n}(2));
    Kpos_nom{n}=zeros(Kd{n}(1),Kd{n}(2));
end

% Gyromagnetic ratio
gamma=267.513e+06; % [Hz/T]

% Pre-compute the cummulative k-space for the maximum gradient
k_accumulated=gamma*cumsum(MR.UMCParameters.SystemCorrections.GIRF_output_waveforms*MR.UMCParameters.SystemCorrections.GIRF_time(2)); 
k_accumulated_nom=gamma*cumsum(repmat(MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,[1 2])*MR.UMCParameters.SystemCorrections.GIRF_time(2)); 

% Check orientations and delete whats not required 
if isempty(regexp(MR.Parameter.Scan.REC(1:5),'R'))
    k_accumulated(:,1)=[];
end

if isempty(regexp(MR.Parameter.Scan.REC(1:5),'A'))
    k_accumulated(:,2)=[];
end

if isempty(regexp(MR.Parameter.Scan.REC(1:5),'F'))
    k_accumulated(:,3)=[];
end

% Loop over all readouts and compute trajectory
for n=1:num_data
    Kpos{n}=...
    [interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_accumulated(:,2),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
    interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_accumulated(:,1),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
    zeros(numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),1)];

    Kpos_nom{n}=...
    [interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_accumulated_nom(:,2),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
    interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_accumulated_nom(:,1),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
    zeros(numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),1)];
end

% Scale to match the requirements of the gridders
Kpos=cellfun(@(x) permute(.5*x/max(abs(x(:))),[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) permute(.5*x/max(abs(x(:))),[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos_nom,'UniformOutput',false);

% Reshape to kx/ky
Kpos=cellfun(@(x) reshape(x,[3 Kd{1}(1) Kd{1}(2)]),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) reshape(x,[3 Kd{1}(1) Kd{1}(2)]),Kpos_nom,'UniformOutput',false);

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
    subplot(337);for n=1:num_data;plot(Kpos{n}(2,:),Kpos{n}(1,:),'r','Linewidth',2);hold on;
    plot(Kpos_nom{n}(2,:),Kpos_nom{n}(1,:),'Linewidth',2);grid on;box on;
    title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');xlabel('Time [ms]');ylabel('K-space cycles/m');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
    axis([-.75 0.75 -0.75 .75]);end
end

% Use nominal trajectory if required
if strcmpi(MR.UMCParameters.SystemCorrections.GIRF_nominaltraj,'yes')
    Kpos=Kpos_nom;
end

% Assign trajectory & Apply spatial resolution factor
MR.Parameter.Gridder.Kpos=cellfun(@(x) x*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio,...
    Kpos,'UniformOutput',false);

% END
end