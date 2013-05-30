%% example_plotting
% This script calls an interpolation program and the view3Dgui to look at
% at electron density examples.
%% Declare Data
% This is the directory that has the data on the server. On my specific set
% up.  You may have to change this!
data_dir = '/Users/Bodangles/Documents/ISRData/20121124_day';
file_name = 'pfa121124.002.hdf5';
radar_file = fullfile(data_dir,file_name);

if ~exist(radar_file,'file')
    error('This file does not exist please change the path or the file name variables');
end

%% Pull in and trim data
All_Data = h5read(radar_file,'/Data/Table Layout');

start_time_vec = [2012 11 24 6 00 00];
start_time = datenum(start_time_vec);
start_time_unix =  datestr2unix(start_time_vec);

end_time_vec = [2012 11 24 6 15 00];
end_time = datenum(end_time_vec);
end_time_unix =  datestr2unix(end_time_vec);

keep_data = (All_Data.ut1_unix>=start_time_unix) & (All_Data.ut2_unix<end_time_unix)&...
    ~isnan(All_Data.range);
Trimed_Data = struct_trim(All_Data,keep_data);
%% Run Interpolation
NUMPOINTS = 50; % Number of points to interpolate in X & Y directions
  
DELTALT = 20; % Width of interpolated altitude slices (in km)
N_e_log = Trimed_Data.nel;

N_e = 10.^(N_e_log);
%Making all NaNs 0
N_e(isnan(N_e))=1;
N_e = double(N_e);

% TI
T_i = double(Trimed_Data.ti);
T_i(isnan(T_i)) = 1;
% Te
T_e = double(Trimed_Data.te);
T_e(isnan(T_e)) = 1;
%vo
v_o = double(Trimed_Data.vo);
v_o(isnan(v_o)) = 0;
[Xi,Yi,Zi,Ne,Ti,Te,Vo] = interp3dFlat(double(Trimed_Data.azm),double(Trimed_Data.elm),...
    double(Trimed_Data.range), double(Trimed_Data.ut1_unix),NUMPOINTS,DELTALT,...
    N_e,T_i,T_e,v_o);
%% Look at Data
% set up the inputs for the view3Dslice
Ne1 = Ne(:,:,:,1);
Ne2 = Ne(:,:,:,end);
Ti1 = Ti(:,:,:,1);
Te1 = Te(:,:,:,1);
Vo1 = Vo(:,:,:,1);
xsca = Xi(1,:,1);
ysca = Yi(:,1,1);
zsca = Zi(1,1,:);
xname = 'W-E (km)';
yname = 'N-S (km)';
zname = 'Altitude (km)';
% data_name = {'Ne Slice 1','Ne Slice 2'};
data_name = {'Ne Slice 1','Ti Slice 1','Te Slice 1','Vo Slice 1'};


Ne_cell = {Ne1,Ti1,Te1,Vo1};

%view3Dslice(Ne_cell,xsca,ysca,zsca,xname,yname,zname,data_name);
%sliceomatic(Ne1,xsca,ysca,zsca)