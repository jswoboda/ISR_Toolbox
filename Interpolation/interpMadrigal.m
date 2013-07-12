function varargout = interpMadrigal(mad_input,meshin,coord,origin,varargin)
% interp3dFlatENU.m
% [Ne_3d,Ti_3d...] = interpMadrigal(mad_data_input,posmesh,Ne,Ti...)
% This function will interpolate ISR data on to ENU, wgs or ecef.  It
% is using a natural neighbor interpolation.  If interolated to wgs,
% coordinates are [lat, long, altitude] in [deg,deg,m].  ECEF and ENU will
% be in meters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% examples
% for ENU
% [Ne_3d,Ti_3d] = interpMadrigal(mad_filename,meshin,'ENU',[0,0,0],'nel,'ti');
% [Xi,Yi,Zi,Ne_3d,Ti_3d] = interpMadrigal(mad_filename,meshsamples,'ENU',[0,0,0],'nel,'ti');
% for ECEF at poker flat
% [Ne_3d,Ti_3d] = interpMadrigal(mad_filename,meshin,'ecef',[ 65.1366667,-147.4472222 ,689],'nel,'ti');
% [Xi,Yi,Zi,Ne_3d,Ti_3d] = interpMadrigal(mad_filename,meshsamples,'ECEF',[ 65.1366667,-147.4472222 ,689];],'nel,'ti');
% for wgs at poker flat
% [Ne_3d,Ti_3d] = interpMadrigal(mad_filename,meshin,'WGS',[ 65.1366667,-147.4472222 ,689],'nel,'ti');
% [Xi,Yi,Zi,Ne_3d,Ti_3d] = interpMadrigal(mad_filename,meshsamples,'lla',[ 65.1366667,-147.4472222 ,689];],'nel,'ti');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% mad_filename - This is a string that holds the name of a madrigal hdf5
% file.
% mad_struct - A struct in the madrigal format
% meshin - The X, Y, Z grid that the data will be interpolated over.  
% meshsamples - A 1x3 array that will give the number of samples per
% dimension and which will be interpolate
% coord - A string that will determine what type of coordinate system it
% will be interpolated to.  This choice is NOT case sensitive.  For ECEF
% enter 'ecef', for ENU enter 'enu', for WGS enter 'wgs' or 'lla'.
% origin - 'This is needed for wgs and ecef and will be in ecef  
% Ne, Ti - Nx1 arrays of measurments at specific range az and el points.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% Ne_3d,Ti_3d - 3-d matricies that hold the data.
% Xi,Yi,Zi  - The mesh grid that the data was interpolated over.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Deal with the structs

if isa(mad_input,'struct');
    All_Data =  mad_input;
elseif ischar(mad_input)
    All_Data = h5read(mad_input,'/Data/Table Layout');
end
% Get rid of range nans

All_Data = struct_trim(All_Data,~isnan(All_Data.range));

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
ENU = double([xr(:), yr(:), zr(:)]); % Original positions
%% Final coordinate transforms
% Transform the locations of the original data to the selected coordinate
% transforms
if strcmpi(coord,'enu')
    positions = ENU;
elseif strcmpi(coord,'ecef')
    
    ECEF_COORDS = enu2ecef(ENU,origin);
    positions = ECEF_COORDS;
elseif strcmpi(coord,'wgs')|| strcmpi(coord,'lla')
    ECEF_COORDS = enu2ecef(ENU,origin);
    positions = ecef2wgs(ECEF_COORDS)';
else
    error('You did not select the input a usable coordinates');
end

%% Determine the mesh
% This will create the coordinates that the data will be interpolated over

x_bounds = [min(positions(:,1)),max(positions(:,1))];
y_bounds = [min(positions(:,2)),max(positions(:,2))];
z_bounds = [min(positions(:,3)),max(positions(:,3))];

if size(meshin,1)== 1
    x_vec = linspace(x_bounds(1),x_bounds(2),meshin(1));
    y_vec = linspace(y_bounds(1),y_bounds(2),meshin(2));
    z_vec = linspace(z_bounds(1),z_bounds(2),meshin(3));
    [Xi,Yi,Zi] = meshgrid(x_vec,y_vec,z_vec);
    posmesh = [Xi(:),Yi(:),Zi(:)];
    xtra_out = 3;
    keep_overall = true(size(posmesh));
    posmesh_red = posmesh;
    varargout = cell(1,xtra_out+n_data);
    varargout(1:3) = {Xi,Yi,Zi};
else
    posmesh = meshin;
    xtra_out = 0;
    keep1 = posmesh(:,1)>=x_bounds(1)& posmesh(:,1)<=x_bounds(2);
    keep2 = posmesh(:,2)>=y_bounds(1)& posmesh(:,2)<=y_bounds(2);
    keep_overall = keep1&keep2;
    posmesh_red = posmesh(keep_overall,:);
    varargout = cell(1,xtra_out+n_data);

end

%% Interpolate spherical into new coordinates

T = length(u_time);
DT = DelaunayTri(positions(:,1),positions(:,2),positions(:,3));
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
    varargout{iout+xtra_out} = F_out;
end