%% example_with_madrigal
% This script is assuming that the user has the madgrigal MATLAB API on
% thier path.  This script will download the data into the current
% directory that the user is in and then read the file and interpolate the
% data over a given volume.
%% Set  a time period
start_time_vec = [2008 03 26 11 00 00];
start_time = datenum(start_time_vec);
start_time_date = datenum(start_time_vec(1:3));

next_day_vec= [2008 03 27];
next_day = datenum(next_day_vec);

end_time_vec = [2008 03 26 11 30 00];
end_time = datenum(end_time_vec);


%% Get Instrument and experiment info

madurl = 'https://isr.sri.com/madrigal';
cgiurl = getMadrigalCgiUrl(madurl);

'List all instruments, and their latitudes and longitudes:';
instArray = getInstrumentsWeb(cgiurl);
for i = 1:length(instArray)
    [s,errmsg] = sprintf('Instrument: %s, at lat %f and long %f', ...
            instArray(i).name, ...
            instArray(i).latitude, ...
            instArray(i).longitude);
     s;
end

expArray = getExperimentsWeb(cgiurl, 61, start_time_date, next_day, 0);
expFileArray = getExperimentFilesWeb(cgiurl, expArray(2).id);

%% Download h5 file
orig_filename = expFileArray(3).name;
[pathstr, name, ext] = fileparts(orig_filename);
curdir = pwd;
radar_file = fullfile(curdir,[name,ext,'.h5']);
myresult = madDownloadFile(cgiurl,expFileArray(3).name,radar_file,...
     'John Swoboda','swoboj@bu.edu','BU','hdf5');
 
%% Run interpolation 
% Determine grid size
my_grid = [32,32,128];
% Do interpolation
[Xi,Yi,Zi,Ne_vec,Ti_vec] = interpMadrigal(radar_file,my_grid,'ENU',...
    [0,0,0],'names',{'ne','ti'},'timelimits',{start_time,end_time});
n_times = numel(Ne_vec)/prod(my_grid);
%% Look at Data
% set up the inputs for the view3Dslice
Ne_cell = cell(1,n_times);
Ne_name = cell(1,n_times);
Ti_cell = cell(1,n_times);
Ti_name = cell(1,n_times);
for k = 1:n_times
    Ne_cell{k} = reshape(Ne_vec(:,k),my_grid);
    Ne_name{k}= ['Ne Slice ' num2str(k)];

    Ti_cell{k} = reshape(Ti_vec(:,k),my_grid);
end

xsca = Xi(1,:,1);
ysca = Yi(:,1,1);
zsca = Zi(1,1,:);
xname = 'W-E (km)';
yname = 'N-S (km)';
zname = 'Altitude (km)';



view3Dslice(Ne_cell,xsca,ysca,zsca,xname,yname,zname,Ne_name);
%sliceomatic(Ne1,xsca,ysca,zsca)