function varargout = interp3dMadrigalENU(mad_data_input,posmesh,varargin)
% interp3dFlatENU.m
% [Ne_3d,Ti_3d...] = interp3dMadrigalENU(mad_data_input,posmesh,Ne,Ti...)
% This function will interpolate ISR data on to a local cartisian grid or
% Enu with center reference point from madrigal struct or file name.  This
% uses natural neighbor interpolation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% examples
% [Ne_3d,Ti_3d] = interp3dMadrigalENU(mad_filename,,posmesh,'nel,'ti');
% [Ne_3d,Ti_3d] = interp3dMadrigalENU(mad_struct,,posmesh,'nel,'ti');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% mad_filename - This is a string that holds the name of a madrigal hdf5
% file.
% mad_struct - A struct in the madrigal format
% Posmesh - The X, Y, Z grid that the data will be interpolated over.
% Ne, Ti - Nx1 arrays of measurments at specific range az and el points.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% Ne_3d,Ti_3d - 3-d matricies that hold the data.

%% Deal with the structs

if isa(mad_data_input,'struct');
    All_Data =  mad_data_input;
elseif ischar(mad_data_input)
    All_Data = h5read(mad_data_input,'/Data/Table Layout');
end

% check if they are fields inthe struct
TF = isfield(All_Data,varargin);

if ~any(TF)
    error('All field names are wrong');
end

data_names = varargin(TF);
not_here = varargin(~TF);

disp(['Missing inputs: ',sprintf('%s ', not_here{:})])
n_data = sum(TF);

%% Pull out unique values
time_points = All_Data.ut1_unix;
az = All_Data.azm;
el = All_Data.elm;
Range = All_Data.range*1e3;% range is 

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

xr = Range1.*kx;
yr = Range1.*ky;
zr = Range1.*kz;
% translate to ENU
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
DT = DelaunayTri(xr(:),yr(:),zr(:));
interpolation_method = 'natural';
for iout = 1:n_data
    fprintf('Data set %d of %d\n',iout,n_data);
    F_in = All_Data.(data_names{iout});
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
        Ni_TSI = TriScatteredInterp(DT,values,interpolation_method);
        Ni = Ni_TSI(posmesh_red);
        warning(orig_state);

        F_out(keep_overall,t) = Ni; % 
        fprintf('Interpolation done\n ')  
 
    end
    varargout{iout} = F_out;
end