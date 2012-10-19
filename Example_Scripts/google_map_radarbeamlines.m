function google_map_radarbeamlines(radar_file,outputfile)
%% goggle_map_radarbeamlines.m
% This script plots the beams of the AMISR beams in Google Earth.  
% The script creates a kml file that needs to be uploaded into Google Earth.  
% SYNTAX:
%
%google_map_radarbeamlines[radar_file,outputfile]
%
%   INPUT:
%       radar_file is the file of the radar data, e.g. 
%           'U:/ISRdata/20091211.001.done/20091211.001_lp_1min-cal.h5'
%
%       outputfile is the path and name of the saved kml file, e.g.
%           '/Users/hannad/Documents/MATLAB/Gmapsdata/AMISRbeamlines.kml'
%           If this is not set, 'AMISRbeamlines.kml' is used as default
%
%   OUTPUT:
%       The function returns the kml file that is to be read by Google
%       Earth, to show the radar beams.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin == 0
    error('Specify radar_file, e.g. google_map_radarbeamlines(''20080326.001_lp_2min.h5'')')
end

if nargin == 1
    outputfile='AMISRbeamlines.kml';
end


if ~exist(radar_file,'file')
    error('This file does not exist please change the path or the file name variables');
end

%% Read in data
beam_lat = hdf5read(radar_file,'/Geomag/Latitude');
beam_long = hdf5read(radar_file,'/Geomag/Longitude');
beam_alt = hdf5read(radar_file,'/Geomag/Altitude');

%% Plot in Google Maps
% This is a dump directory for the KML files
save_file=outputfile;

%Adding a break between each beam, for the plotting
beam_lat(size(beam_lat,1),:)=NaN;

%Plotting
tmp = ge_plot3(beam_long,beam_lat,beam_alt,'lineColor','FFFF0000','msgToScreen',...
    false, 'altitudeMode','relativeToGround');
                       
kmlStr01 = ge_folder('radar beams',tmp);

% this creates the output file.
ge_output(save_file,kmlStr01,'name','AMISR beamlines')

