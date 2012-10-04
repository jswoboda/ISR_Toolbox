function [Ne,Xi,Yi,Zi,bco,utime,T1,T2] = interpAMISRnocal(varargin)
%
%interpRISRnocal  Linear interpolation of non-calibrated AMISR data onto a cartesian grid
%
%   SYNTAX:
%           interpAMISRnocal
%           interpAMISRnocal(StartTime,EndTime,file_name)
%
%   INPUT:
%     StartTime   - Is in the format of serial date number, such as 
%                   StartTime = datenum(2012,01,24,11,03,00); for 24
%                   January 2012, at 11:03:00
%     EndTime     - Is in the format of serial date number, such as 
%                   EndTime = datenum(2012,01,24,11,05,00); for 24
%                   January 2012, at 11:05:00
%     file_name   - is the h5-file with uncalibrated data, such as
%                   file_name =
%                   'E:/20120122.001_lp_2min-Ne.h5';
%
%   OUTPUT:
% [Ne,Xi,Yi,Zi,utime,T1,T2,bco]
%
%   DESCRIPTION:
%Function that interpolates uncalibrated AMISR data onto 3D Cartesian grid. 
%
%An example on how this can be run:
%   StartTime = datenum(2012,01,24,11,03,00);
%   EndTime = datenum(2012,01,24,11,05,00);
%   file_name =
%   'C:/Users/hannad/Documents/RISR/20120122/20120122.001_lp_2min-Ne.h5';  
%   [Ne,Xi,Yi,Zi,utime,T1,T2,bco] =
%       interpAMISRnocal(StartTime,EndTime,file_name);
%
%
%%
%check input, set default values if arguments are unspecified

%If all arguments are given
if nargin==3
    StartTime = varargin{1};
    EndTime = varargin{2};
    file_name = varargin{3};
end

if nargin < 1
    start = input('Please specify StartTime, on the format: year month day hour minute second \n (e.g. 2012 01 24 12 30 00)\n','s');
    start = str2num(start);
    StartTime = datenum(start(1),start(2),start(3),start(4),start(5),start(6));
    endtime = input('Please specify EndTime, on the format: year month day hour minute second \n (e.g. 2012 01 24 12 32 00)\n','s');
    endtime = str2num(endtime);
    EndTime = datenum(endtime(1),endtime(2),endtime(3),endtime(4),endtime(5),endtime(6));   
    file_name = input('Please specify the data file: \n (e.g. 20120122.001_lp_2min-Ne.h5)\n','s');

end

%If only the times are given
if nargin==2
    StartTime=varargin{1};
    EndTime=varargin{2};
    display('no specified datafile, will use default')
  file_name = input('Please specify the data file: \n (e.g. 20120122.001_lp_2min-Ne.h5)\n','s');

end

%If only the data file is specified
if nargin>1
if ischar(varargin{1})
    start = input('Please specify StartTime, on the format: year month day hour minute second \n (e.g. 2012 01 24 12 30 00)\n','s');
    start = str2num(start);
    StartTime = datenum(start(1),start(2),start(3),start(4),start(5),start(6));
    endtime = input('Please specify EndTime, on the format: year month day hour minute second \n (e.g. 2012 01 24 12 32 00)\n','s');
    endtime = str2num(endtime);
    EndTime = datenum(endtime(1),endtime(2),endtime(3),endtime(4),endtime(5),endtime(6));   
  file_name = varargin{1};
end
end
%
%
%% Initialize options.
warning off all
NUMPOINTS = 50; % Number of points to interpolate in X & Y directions
  
DELTAZ = 20; % Width of interpolated altitude slices (in km)

% Specify approximate start- and end-points on altitude axis

StartAlt = 120;  % km
EndAlt   = 600; % km

DateStr = datestr(StartTime,'yyyymmdd');


%% Load radar file.
%%Reading the data from the h5 file

Range = hdf5read(file_name,'/NeFromPower/Range');
Altitude= hdf5read(file_name,'/NeFromPower/Altitude')/1000.;
N_e = hdf5read(file_name,'/NeFromPower/Ne_NoTr');
utime = hdf5read(file_name,'/Time/UnixTime');
bco   = hdf5read(file_name,'BeamCodes');

  %Making all NaNs 0
  N_e(isnan(N_e))=1;

l=size(utime);
mtime = zeros(l(1),l(2));

%%
%Converting the time from unix time to matlab time
for i1 = 1:l(1),
for i2 = 1:l(2),
mtime(i1,i2) = datenum([1970 1 1 0 0 double(utime(i1,i2))]); 
end
end

%% Azimuth and elevation in degrees
az = bco(2,:) * pi/180;  
el = bco(3,:) * pi/180; 


%% Align Start and End times to corresponding mtime boundaries.
T1 = find(mtime(1,:) >= StartTime, 1, 'first');
T2 = find(mtime(2,:) >= EndTime,   1, 'first');
StartTime = mtime(1,T1);
EndTime   = mtime(2,T2);

%% convert to Cartesian coordinates (flat Earth model)

% Expand el & az by repeating their values (i.e. el1 is the same size as Ne(:,:,t))
el1 = repmat(el,length(Altitude),1); 
az1 = repmat(az,length(Altitude),1); 

% Grab just the points within the desired altitude
alt_idx = find( Altitude>StartAlt & Altitude<EndAlt );
el2 = el1(alt_idx);
az2 = az1(alt_idx);

% Direction cosines, from spherical to Cartesian coordinates
kx = sin(az2) .* cos(el2);
ky = cos(az2) .* cos(el2);
kz = sin(el2);

% radar points in Cartesian coordinates
zr = Altitude(alt_idx);
rr=zr./sin(el2);
xr = rr.*kx;
yr = rr.*ky;


%% Interpolate spherical ("scatter") data in Cartesian coordinates

% Create a new 3D grid for the interpolated data
[Xi,Yi,Zi] = meshgrid(linspace(min(xr),max(xr),NUMPOINTS),...
                      linspace(min(yr),max(yr),NUMPOINTS),...
                      min(zr):DELTAZ:max(zr));
Xi=double(Xi);
Yi=double(Yi);
Zi=double(Zi);

positions = [xr(:), yr(:), zr(:)]; % Original positions
positions=double(positions);
posmesh   = [Xi(:), Yi(:), Zi(:)]; % New positions

Ne = zeros( [size(Xi), (T2-T1+1)] );

%Loop through times of interest to interpolate the electron densities onto
%the new grid
  
for t = T1:T2,
    fprintf('Interpolating time step %d (of %d)... ',t,T2);
   
    % Grab the current densities.
    N1 = double(N_e(:,:,t));

    % Grab just the values we're interested in...
    values = N1(alt_idx);
   
    values(find(values < 0)) = 0;

    % ... and interpolate onto the new grid.

        Ni = griddatan(positions,values,posmesh,'linear'); 
        
 %     %Making all NaNs 0
    Ni(isnan(Ni))=0;


    % Reshape Ni to go with Xi, Yi, & Zi.
    Nireshaped = reshape(Ni, size(Xi));
    
    % "Deposit" Ni into Ne.

    Ne(:,:,:,t-T1+1) = Nireshaped; % 
    fprintf('linear interpolation done\n ')  

    
end; 
