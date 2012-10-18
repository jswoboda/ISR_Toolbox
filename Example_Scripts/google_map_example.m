%% goggle_map_example.m
% This script plots the sample points of the PFISR beams in Google Earth.  
% The script creates a kml file that needs to be uploaded into Google Earth.  
%% Declare Data
% This is the directory that has the data on the server. On my specific set
% up.  You may have to change this!
data_dir = '/Volumes/Research/eng_research_irs/PFISRdata/20080326';
file_name = '20080326.001_lp_2min.h5';
radar_file = fullfile(data_dir,file_name);

if ~exist(radar_file,'file')
    error('This file does not exist please change the path or the file name variables');
end

%% Read in data
beam_lat = h5read(radar_file,'/Geomag/Latitude');
beam_long = h5read(radar_file,'/Geomag/Longitude');
beam_alt = h5read(radar_file,'/Geomag/Altitude');

%% Plot in Google Maps
% This is a dump directory for the KML files
save_file = '/Users/Bodangles/Documents/MATLAB/Gmapsdata/test.kml';

beam_lat_line = beam_lat(~isnan(beam_lat))';
beam_long_line = beam_long(~isnan(beam_lat))';
beam_alt_line = beam_alt(~isnan(beam_lat))';

% This directory points to the icon base that is freely avalible from
% Google.
iconStrBase = 'http://maps.google.com/mapfiles/kml/pal2';
iconStrBase2 = fullfile(googleearthroot,'data','icons');
tmp = ge_point(beam_long_line,beam_lat_line,beam_alt_line,'iconScale',0.25,...
    'iconURL', fullfile(iconStrBase,'icon18.png'),'msgToScreen',...
    false, 'altitudeMode','relativeToGround');
                       
kmlStr01 = ge_folder('many points',tmp);
% this creates the output file.
ge_output(save_file,kmlStr01,'name', 'Johns Test')