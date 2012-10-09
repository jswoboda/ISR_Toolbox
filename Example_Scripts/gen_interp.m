%% General interp example
% This script shows how to read in data and interpolate
%% Decalre parameters

NUMPOINTS = 25; % Number of points to interpolate in X & Y directions
DELTALT = 4; % Width of interpolated altitude slices (in km)

%EndTime   = datenum(2008,03,26,12,30,00);
StartTime = datenum(2008,03,26,11,30,00);
EndTime   = datenum(2008,03,26,12,32,00);

% Specify approximate start- and end-points on range axis
StartRange = 90;  % km
EndRange   = 400; % km

%% Declare Data
% This is the directory that has the data on the server. On my specific set
% up.  You may have to change this!
data_dir = '/Volumes/Research/eng_research_irs/PFISRdata/20080326';
file_name = '20080326.001_lp_2min.h5';
radar_file = fullfile(data_dir,file_name);

if ~exist(radar_file,'file')
    error('This file does not exist please change the path or the file name variables');
end

%% Read in Data

Ne    = hdf5read(radar_file,'FittedParams/Ne');
fits  = hdf5read(radar_file,'FittedParams/Fits');
utime = hdf5read(radar_file,'Time/UnixTime');
Range = hdf5read(radar_file,'FittedParams/Range');
Alt   = hdf5read(radar_file,'FittedParams/Altitude');
bco   = hdf5read(radar_file,'BeamCodes');

Ti = squeeze(fits(2,1,:,:,:));
Vi = squeeze(fits(2,2,:,:,:));
Te = squeeze(fits(2,3,:,:,:));
clear fits

% get az and el vectors
az = bco(2,:) * pi/180;
el = bco(3,:) * pi/180;

% Change the range to km and prune
Alt_vec = Alt(:,1)/1e3;
range_idx = find(Alt_vec>=StartRange&Alt_vec<=EndRange);
Alt_vec = Alt_vec(range_idx)';
Altitude = Alt/1e3;
Altitude = Altitude(range_idx,:);
% Set up the times
mtime = unixtime2matlab(utime);
%% Parce data
T1 = find(mtime(1,:) >= StartTime, 1, 'first');
T2 = find(mtime(2,:) <= EndTime,   1, 'last');
StartTime = mtime(1,T1);
EndTime   = mtime(2,T2);
Ne = Ne(range_idx,:,T1:T1+1);
Ti = Ti(range_idx,:,T1:T1+1);
Te = Te(range_idx,:,T1:T1+1);
Vi = Vi(range_idx,:,T1:T1+1);
%% Use the Generalized interpolators

% Interpolate electron Density
[Ne_out,Xi,Yi,Zi] = interp3dGen(Ne,az,el,Altitude,NUMPOINTS,DELTALT);
% Tempreture of ions
[Ti_out,Xi,Yi,Zi] = interp3dGen(Ti,az,el,Altitude,NUMPOINTS,DELTALT);
% Tempreture of the Electrons
[Te_out,Xi,Yi,Zi] = interp3dGen(Te,az,el,Altitude,NUMPOINTS,DELTALT);
% Velocity of the ions
[Vi_out,Xi,Yi,Zi] = interp3dGen(Vi,az,el,Altitude,NUMPOINTS,DELTALT);
%% Look at Data
% set up the inputs for the view3Dslice
Ne1 = squeeze(Ne_out(:,:,:,1));
Ti1 = squeeze(Ti_out(:,:,:,1));
Te1 = squeeze(Te_out(:,:,:,1));
Vi1 = squeeze(Vi_out(:,:,:,1));

xsca = Xi(1,:,1);
ysca = Yi(:,1,1);
zsca = Zi(1,1,:);
xname = 'W-E (km)';
yname = 'N-S (km)';
zname = 'Altitude (km)';
data_name = {'Ne Slice 1','Ti Slice 1','Te Slice 1','Vi Slice 1'};


Ne_cell = {Ne1,Ti1,Te1,Vi1};

view3Dslice(Ne_cell,xsca,ysca,zsca,xname,yname,zname,data_name);