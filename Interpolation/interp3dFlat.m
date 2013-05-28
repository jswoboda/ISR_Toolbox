function [Xi,Yi,Zi,varargout] = interp3dFlat(az,el,Range,time_points,NUMPOINTS,DELTALT,varargin)

%% Pull out unique values

[u_time,ia_time,ic_time] = unique(time_points);
keep_ic = ic_time==1;
az1 = az(keep_ic);
el1 = el(keep_ic);
Range1 = Range(keep_ic);

bco = [az,el];
u_bco = unique(bco,'rows');
u_az = u_bco(:,1);
u_el = u_bco(:,2);
u_Range = unique(Range);

%% Convert to Cartesian coordinates (flat Earth model)

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
for iout = 1:nargin-6
    fprintf('Data set %d of %d\n',iout,nargin-6);
    F_in = varargin{iout};
    F_out = zeros( [size(Xi), T] );
    for t = 1:T
        
        fprintf('\tInterpolating time step %d (of %d)... ',t,T);
        keep = ic_time ==t;
        % Grab the current densities.
        values = double(F_in(keep));

        % Grab just the values we're interested in...
%         values = F1(:);
%    
%         values(values < 0) = 0;

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