function [Xi,Yi,Zi,varargout] = interp3dFlat(az,el,Range,time_points,...
    NUMPOINTS,DELTALT,varargin)
% interp3dFlat.m
% [Xi,Yi,Zi,Ne_3d,Ti_3d...] = interp3dFlat(az,el,Range,time_points,...
%    NUMPOINTS,Ne,Ti...)
% This function will interpolate the ISR data to a local ENU coordinate 
% system assuming all of the data is in Nx1 arrays.  It it will interpolate
% all of the different parameters at once.  To get more parameters
% interpolated just keep adding Nx1 arrays of data as arguments along with 
% ouptut arugments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% az - An Nx1 array that contains the az positions of the data.
% el - An Nx1 array that contains the el positions of the data.
% Range - An Nx1 array that contains the range positions of the data.
% time_points  An Nx1 array that contains the timestamps of the data
% relative to the other measurements. (note no interolation is done in the
% time dimension this is purley needed to determine what time instance the
% data should be in.
% NUMPOINTS - The number of points in the east and north directions.
% DELTALT - The altidue spacing it is assumed it will be in meters
% Ne, Ti - Nx1 arrays of measurments at specific range az and el points.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% Xi,Yi,Zi, - The meshgrid outputs that the data is interpolated over.
% Ne_3d,Ti_3d - 3-d matricies that hold the data.
%% Pull out unique Determine the unique time points

[u_time,~,ic_time] = unique(time_points);
keep_ic = ic_time==1;
az1 = az(keep_ic);
el1 = el(keep_ic);
Range1 = Range(keep_ic);

%% Convert to ENU coordinates

el2 = el1*pi/180;
az2 = az1*pi/180;

% Direction cosines, from spherical to Cartesian coordinates
kx = sin(az2) .* cos(el2);
ky = cos(az2) .* cos(el2);
kz = sin(el2);

% radar points in Cartesian coordinates
zr = Range1;
rr=zr./kz;
xr = rr.*kx;
yr = rr.*ky;

%% Interpolate spherical ("scatter") data in Cartesian coordinates

% Create a new 3D grid for the interpolated data
[Xi,Yi,Zi] = meshgrid(linspace(min(xr),max(xr),NUMPOINTS),...
                      linspace(min(yr),max(yr),NUMPOINTS),...
                      min(zr):DELTALT:max(zr));
Xi=double(Xi);
Yi=double(Yi);
Zi=double(Zi);

positions = [xr(:), yr(:), zr(:)]; % Original positions
positions=double(positions);
posmesh   = [Xi(:), Yi(:), Zi(:)]; % New positions
T = length(u_time);
n_data = nargin-6;
for iout = 1:n_data
    fprintf('Data set %d of %d\n',iout,n_data);
    F_in = varargin{iout};
    F_out = zeros( [size(Xi), T] );
    for t = 1:T
        
        fprintf('\tInterpolating time step %d (of %d)... ',t,T);
        keep = ic_time ==t;
        % Grab the current densities.
        values = double(F_in(keep));


        % ... and interpolate onto the new grid.

        Ni = griddatan(positions,values,posmesh,'linear'); 
        
    %     %Making all NaNs 0
        Ni(isnan(Ni))=0;


        % Reshape Ni to go with Xi, Yi, & Zi.
        Nireshaped = reshape(Ni, size(Xi));
    
        % "Deposit" Ni into Ne.

        F_out(:,:,:,t) = Nireshaped; % 
        fprintf('linear interpolation done\n ')  
 
    end
    varargout{iout} = F_out;
end