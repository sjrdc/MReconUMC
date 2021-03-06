function [kspace_data,MR] = reader_reconframe_lab_raw(loc,varargin)
%% RECONFRAME LAB/RAW READER
% Read lab/raw data using reconframe and convert to list format.
% Such that the "corrected" and "sorted" k-space data is returned.
% Varargin defines the type of data, i.e. noise data, imaging data
% 1=imaging data | 2= .. | 3=.. | 4=... | 5=noise data

% Process data type
curdir=get_data_dir(loc);
if isempty(varargin)
    type=1;
else
    type=varargin{1};
end

% Check if k-space exist already, then load from dir
if numel(varargin)>1
    if exist([curdir,'kspace_data',num2str(type),'.mat']) > 0
        load([curdir,'kspace_data',num2str(type),'.mat']);
        disp(['>> Loaded K-space data from ',curdir,'kspace_data',num2str(type),'.mat'])
        MR=[]; % Cant save reconframe object
        return;
    end
end

% Read data
MR=MRecon(loc);
MR=reconframe_read_sort_correct(MR,type);
kspace_data=MR.Data;
save([curdir,'kspace_data',num2str(type),'.mat'],'kspace_data');



end
