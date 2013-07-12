function varargout = interp3dFlatLatLong(az,el,Range,time_points,lla,posmesh,varargin)
% interp3dFlatLatLong.m
% [Ne_3d,Ti_3d...] = interp3dFlatLatLong(az,el,Range,time_points,lla,posmesh,Ne,Ti...)
% This function will interpolate ISR data a latitude and longitude
% grid specified by the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% az - An Nx1 array that contains the az positions of the data.
% el - An Nx1 array that contains the el positions of the data.
% Range - An Nx1 array that contains the range positions of the data.
% time_points  An Nx1 array that contains the timestamps of the data
% relative to the other measurements. (note no interolation is done in the
% time dimension this is purley needed to determine what time instance the
% data should be in.
% lla - a 3x1 array holding the lat long and altitude of the radar system.
% Posmesh - The lat long and altitude points the dat will be interpolated
% over.
% Ne, Ti - Nx1 arrays of measurments at specific range az and el points.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% Ne_3d,Ti_3d - 3-d matricies that hold the data.
%% Pull out unique values

[u_time,~,ic_time] = unique(time_points);
keep_ic = ic_time==1;
az1 = mod(az(keep_ic),360);
el1 = el(keep_ic);
Range1 = Range(keep_ic);

%% Convert spherical data coordinates to ENU coordinates

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

% translate to WGS
ENU = [xr(:), yr(:), zr(:)]; % Original positions
ENU=double(ENU);
ECEF_COORDS = enu2ecef(ENU,lla);
positions_latfirst = ecef2wgs(ECEF_COORDS)';
positions = [positions_latfirst(:,2),positions_latfirst(:,1),positions_latfirst(:,3)];
%% Interpolate spherical ("scatter") data into Lat Lon and alt coordinates


positions=double(positions);
T = length(u_time);
n_data = nargin-6;
for iout = 1:n_data
    fprintf('Data set %d of %d\n',iout,n_data);
    F_in = varargin{iout};
    F_out = zeros( [size(posmesh,1), T] );
    for t = 1:T
        
        fprintf('\tInterpolating time step %d (of %d)... ',t,T);
        keep = ic_time ==t;
        % Grab the current densities.
        values = double(F_in(keep));

        Ni = griddatan(positions,values,posmesh,'linear'); 
        
    %     %Making all NaNs 0
        Ni(isnan(Ni))=0;
        
        % "Deposit" Ni into Ne.

        F_out(:,t) = Ni; % 
        fprintf('linear interpolation done\n ')  
 
    end
    varargout{iout} = F_out;
end