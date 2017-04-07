function Kpos = ComputeTrajectoryRadial(radialangles,waveforms_nom,waveforms_corrected,waveform_time,ADC_time,orientation,usenominal,verbose)
% Compute k-space coordinates [-1;1] for radial acquisitions from the GIRF
% modified gradient waveforms. Only works for 2D or stack-of-stars 3D with
% same trajectory in third dimensions.

% Allocate matrix
num_data=numel(radialangles);
for n=1:num_data;Kpos{n}=zeros(numel(ADC_time{n}),numel(radialangles{n}));end

% Gyromagnetic ratio
gamma=267.513e+06; % [Hz/T]

% Pre-compute the cummulative k-space for the maximum gradient
k_accumulated=gamma*cumsum(waveforms_corrected*waveform_time(2)); 
k_accumulated_nom=gamma*cumsum(repmat(waveforms_nom,[1 2])*waveform_time(2)); 

% Check orientations and delete whats not required
if isempty(regexp(orientation(1:5),'R'))
    k_accumulated(:,1)=[];
end

if isempty(regexp(orientation(1:5),'A')) 
    k_accumulated(:,2)=[];
end

if isempty(regexp(orientation(1:5),'F')) 
    k_accumulated(:,3)=[];
end

% Function handle to compute coordinates for every azimuthal angle
k_real=@(theta,k_time)(cos(theta)*k_time);
k_imag=@(theta,k_time)(sin(theta)*k_time);

% Loop over all readouts and compute 
for n=1:num_data
    for nl=1:numel(radialangles{n})
        Kpos{n}(:,nl)=-1*interp1(waveform_time,k_real(radialangles{n}(nl),k_accumulated(:,1)),ADC_time{n})-1j*interp1(waveform_time,k_imag(radialangles{n}(nl),k_accumulated(:,2)),ADC_time{n});
        Kpos_nom{n}(:,nl)=-1*interp1(waveform_time,k_real(radialangles{n}(nl),k_accumulated_nom(:,1)),ADC_time{n})-1j*interp1(waveform_time,k_imag(radialangles{n}(nl),k_accumulated_nom(:,2)),ADC_time{n});
    end
end

% Scale to match the requirements of the gridders
Kpos=cellfun(@(x) .5*x/max(abs(x(:))),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) .5*x/max(abs(x(:))),Kpos_nom,'UniformOutput',false);

% Visualization
if verbose
    subplot(337);for n=1:num_data;plot(1:numel(ADC_time{n}),abs(Kpos{n}(:,1)),'Linewidth',2);hold on;plot(1:numel(ADC_time{n}),abs(Kpos_nom{n}(:,1)),'Linewidth',2);grid on;box on;title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');
    xlabel('Time [ms]');ylabel('K-space cycles/m');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
end

if strcmpi(usenominal,'yes')
    Kpos=Kpos_nom;
end

% END
end