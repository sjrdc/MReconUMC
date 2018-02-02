function radial_zero_based_phase_correction(MR,n)
% Remove central phase from radial 2D / Stack-of-stars acquisitions

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'zero') 
    return;
end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};
dims(3)=MR.UMCParameters.AdjointReconstruction.IspaceSize{n}(3);

% Count number of elements in MR.Data. If its larger then 10^8 use a less
% memory intensive method
if numel(MR.Data{n})>.8*10^9
    inst=1;
else
    inst=0;
end

% Ful pre-computed matrix multiplication (inst=0)
if inst==0
    
    % Preallocate the matrix
    phase_corr_matrix=zeros(size(MR.Data{n}));
    
    % Loop over all lines and determine the correction phase
    for avg=1:dims(12) % Averages
    for ex2=1:dims(11) % Extra2
    for ex1=1:dims(10) % Extra1
    for mix=1:dims(9)  % Locations
    for loc=1:dims(8)  % Mixes
    for ech=1:dims(7)  % Echoes
        % Estimate nearest neighbour center point of the readouts
        [~,cp]=min(sqrt(MR.Parameter.Gridder.Kpos{n}(1,:,1,1,1,1,ech,1,1,1,1,1,1).^2+MR.Parameter.Gridder.Kpos{n}(2,:,1,1,1,1,ech,1,1,1,1,1,1).^2)); % central point
        
    for ph=1:dims(6)   % Phases
    for dyn=1:dims(5)  % Dynamics
    for coil=1:dims(4) % Coils
        
        cur_phase=angle(MR.Data{n}(cp,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        phase_corr_matrix(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
            single(exp(-1j*repmat(cur_phase,[dims(1) 1 1 1 1 1 1 1 1 1 1 1])));

    end % Coils
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
    end % Averages
    
    % Apply matrix multiplication with single indexing
    MR.Data{n}=MR.Data{n}.*phase_corr_matrix;
    
else % inst==1
        
    % Loop over all lines and determine the correction phase
    for avg=1:dims(12) % Averages
    for ex2=1:dims(11) % Extra2
    for ex1=1:dims(10) % Extra1
    for mix=1:dims(9)  % Locations
    for loc=1:dims(8)  % Mixes
    for ech=1:dims(7)  % Phases
        % Estimate nearest neighbour center point of the readouts
        [~,cp]=min(sqrt(MR.Parameter.Gridder.Kpos{n}(1,:,1,1,1,1,ech,1,1,1,1,1,1).^2+MR.Parameter.Gridder.Kpos{n}(2,:,1,1,1,1,ech,1,1,1,1,1,1).^2)); % central point
    for ph=1:dims(6)   % Echos
    for dyn=1:dims(5)  % Dynamics
    for coil=1:dims(4) % Coils
        
        cur_phase=angle(MR.Data{n}(cp,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        phase_corr_matrix=single(exp(-1j*repmat(cur_phase,[dims(1) 1 1 1 1 1 1 1 1 1 1 1])));
            
        % Correct first instance (i.e. [x,y,z])
        MR.Data{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=MR.Data{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg).*phase_corr_matrix;

        coil
    end % Coils
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
    end % Averages
    
end

% END
end
