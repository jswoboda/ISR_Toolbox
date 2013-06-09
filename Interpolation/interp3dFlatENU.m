function varargout = interp3dFlatENU(az,el,Range,time_points,posmesh,varargin)
% interp3dFlatENU.m
% [Ne_3d,Ti_3d...] = interp3dFlatLatLong(az,el,Range,time_points,posmesh,Ne,Ti...)
% This function will interpolate ISR data on to a local cartisian grid or
% Enu with center reference point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% az - An Nx1 array that contains the az positions of the data.
% el - An Nx1 array that contains the el positions of the data.
% Range - An Nx1 array that contains the range positions of the data.
% time_points  An Nx1 array that contains the timestamps of the data
% relative to the other measurements. (note no interolation is done in the
% time dimension this is purley needed to determine what time instance the
% data should be in.
% Posmesh - The X, Y, Z grid that the data will be interpolated over.
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
positions=double(ENU);

%% Reduce the pos mesh

x_bounds = [min(xr(:)),max(xr(:))];
y_bounds = [min(yr(:)),max(yr(:))];
keep1 = posmesh(:,1)>=x_bounds(1)& posmesh(:,1)<=x_bounds(2);
keep2 = posmesh(:,2)>=y_bounds(1)& posmesh(:,2)<=y_bounds(2);
keep_overall = keep1&keep2;
posmesh_red = posmesh(keep_overall,:);

%% Interpolate spherical ("scatter") data into Lat Lon and alt coordinates

positions=double(positions);
T = length(u_time);
for iout = 1:nargin-5
    fprintf('Data set %d of %d\n',iout,nargin-6);
    F_in = varargin{iout};
    F_out = zeros( [size(posmesh,1), T] );
    for t = 1:T
        
        fprintf('\tInterpolating time step %d (of %d)... ',t,T);
        keep = ic_time ==t;
        % Grab the current densities.
        values = double(F_in(keep));
        % Do interpolation but turn off warnings because it goes on
        % forever.
        orig_state = warning('query','all');
        warning('off','all');
        Ni = griddatan(positions,values,posmesh_red,'linear'); 
        warning(orig_state);
    %     %Making all NaNs 0
        Ni(isnan(Ni))=0;
        
        % "Deposit" Ni into Ne.

        F_out(keep_overall,t) = Ni; % 
        fprintf('linear interpolation done\n ')  
 
    end
    varargout{iout} = F_out;
end