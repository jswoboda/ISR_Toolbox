%% google_earth_img_example.m
% This script creates an image that can be plotted on Google earth.  This
% script specifically plots the electron density.
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
Ne    = h5read(radar_file,'/FittedParams/Ne');
T1 = 335; % This is the beginning of a solar storm
Ne_1 = (Ne(:,:,T1));

%% Interpolate Data to a lat long plot
NUMPOINTS = 25;
% get rid of the NaNs
beam_lat_line = beam_lat(~isnan(beam_lat))';
beam_long_line = beam_long(~isnan(beam_lat))';
beam_alt_line = beam_alt(~isnan(beam_lat))';
Ne_1_line = Ne_1(~isnan(Ne_1))';

Ne_lims = [min(Ne_1_line),max(Ne_1_line)];
x_v = linspace(min(beam_long_line),max(beam_long_line),NUMPOINTS);
y_v = linspace(min(beam_lat_line),max(beam_lat_line),NUMPOINTS);
z_v = linspace(min(beam_alt_line),max(beam_alt_line),NUMPOINTS);
[Xi,Yi,Zi] = meshgrid(x_v,y_v,z_v);

positions = [beam_long_line(:), beam_lat_line(:), beam_alt_line(:)]; % Original positions
posmesh   = [Xi(:), Yi(:), Zi(:)]; % New positions
values = Ne_1_line(:);
Ne_vec = griddatan(positions,values,posmesh,'linear'); 
        
 %     %Making all NaNs 0
% Ne_vec(isnan(Ne_vec))=0;
Ne_mat = reshape(Ne_vec, size(Xi));
%% Plot in Google Maps

% pick a slice
alt_vec = [10,15,19,24];

for i_alt = alt_vec
    altitude = z_v(i_alt);

    data = squeeze(Ne_mat(:,:,i_alt));
    
    Nan_log = ~isnan(data);
    [row,col] = find(Nan_log);
    % find the limits in x y where you have good data.
    keepy = min(row):max(row);
    keepx = min(col):max(col);

    cLimLow = Ne_lims(1);
    cLimHigh = Ne_lims(2);

    cmap = jet;
    save_path = '/Users/Bodangles/Documents/MATLAB/Gmapsdata';
    save_file = fullfile(save_path,['Image_test',num2str(i_alt),'.kml']);

    iconStrBase = 'http://maps.google.com/mapfiles/kml/pal3';

    alphaMatrix = ones(size(data))*0.75;

    output = ge_imagesc(x_v,y_v,flipud(data),...
                       'imgURL',fullfile(save_path,['test',num2str(i_alt),'.png']),...
                       'cLimLow',cLimLow,...
                      'cLimHigh',cLimHigh,...
                      'altitude',altitude,...
                  'altitudeMode','absolute',...
                      'colorMap',cmap,...
                   'alphaMatrix',alphaMatrix);

    output2 = ge_colorbar(x_v(end),y_v(1),data,...
                              'numClasses',20,...
                                 'cLimLow',cLimLow,...
                                'cLimHigh',cLimHigh,...
                           'cBarFormatStr','%+07.4f',...
                                'colorMap',cmap);
          
                       

    ge_output(save_file,[output,output2],'name', ['Johns image slice ',num2str(i_alt)])
end