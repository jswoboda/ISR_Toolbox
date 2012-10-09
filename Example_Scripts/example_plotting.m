%% example_plotting
% This script calls an interpolation program and the view3Dgui to look at
% at electron density examples.
%% Declare Data
% This is the directory that has the data on the server. On my specific set
% up.  You may have to change this!
data_dir = '/Volumes/Research/eng_research_irs/PFISRdata/20080326';
file_name = '20080326.001_lp_2min.h5';
radar_file = fullfile(data_dir,file_name);

if ~exist(radar_file,'file')
    error('This file does not exist please change the path or the file name variables');
end
%% Run Interpolation
start_time_vec = [2008 03 26 11 00 00];
start_time = datenum(start_time_vec);

end_time_vec = [2008 03 26 11 30 00];
end_time = datenum(end_time_vec);

[Ne,Xi,Yi,Zi,utime,T1,T2,bco] = interpAMISRnocal(start_time,end_time,radar_file);
%% Look at Data
% set up the inputs for the view3Dslice
Ne1 = Ne(:,:,:,1);
Ne2 = Ne(:,:,:,end);
xsca = Xi(1,:,1);
ysca = Yi(:,1,1);
zsca = Zi(1,1,:);
xname = 'W-E (km)';
yname = 'N-S (km)';
zname = 'Altitude (km)';
data_name = {'Ne Slice 1','Ne Slice 2'};


Ne_cell = {Ne1,Ne2};

%view3Dslice(Ne_cell,xsca,ysca,zsca,xname,yname,zname,data_name);
%sliceomatic(Ne1,xsca,ysca,zsca)