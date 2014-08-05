function [F_out,Xi,Yi,Zi] = interp3dGen(F_in,az,el,Altitude,NUMPOINTS,DELTALT)
% interp3dGen.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examples
% [F_out,Xi,Yi,Zi] = interp3dGen(F_in,az,el,Altitude);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Description: This is a generalized transfroms from spherical coordinates 
%(range and beam space) to Cartesian coordinates (x,y,z).  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% F_in: This is a 3 dimensional array,[NxMxT] dimension 1 is range, dimension 2 is
% beams, and the third demension is time.
% az: A 1xM array that holds the azimuth angle for each of the beams.
% el: A 1xM array that holds the elevation angle for each of the beams.
% Altitude: A 1xN array that holds the altitude values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% F_out: This is a 4 dimensional array, [AxBxCxT], that holds the data 
% after its been interpolated on to the Cartesian grid.  Dimension 1 is the 
% x dimension size A, dimension 2 is the y dimension of size B, dimension 3 
% is the z dimension of size C and the third dimension should represent 
% time, which is of size T.
% Xi: This is a [AxBxC] dimensional array that changes along the X
% direction.
% Yi: This is a [AxBxC] dimensional array that changes along the y
% direction.
% Zi: This is a [AxBxC] dimensional array that changes along the z
% direction.
%% Get basic info
[N,T] = size(F_in);

%% convert to Cartesian coordinates (flat Earth model)

% Expand el & az by repeating their values (i.e. el1 is the same size as Ne(:,:,t))
% el1 = repmat(el,N,1); 
% az1 = repmat(az,N,1); 

% Grab just the points within the desired altitude
alt_idx = 1:N;
el2 = el;
az2 = az;

% Direction cosines, from spherical to Cartesian coordinates
kx = sin(az2) .* cos(el2);
ky = cos(az2) .* cos(el2);
kz = sin(el2);

% radar points in Cartesian coordinates
zr = Altitude(:);
rr=zr./sin(el2);
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

F_out = zeros( [size(Xi), T] );

%Loop through times of interest to interpolate the electron densities onto
%the new grid

for t = 1:T
    fprintf('Interpolating time step %d (of %d)... ',t,T);
   
    % Grab the current densities.
    F1 = double(F_in(:,t));

    % Grab just the values we're interested in...
    values = F1(:);
   
    values(values < 0) = 0;

    % ... and interpolate onto the new grid.

    Ninterp = scatteredInterpolant(xr(:), yr(:), zr(:),values,'natural','none');
    Ni = Ninterp(Xi(:), Yi(:), Zi(:));
 %     %Making all NaNs 0
    %Ni(isnan(Ni))=0;


    % Reshape Ni to go with Xi, Yi, & Zi.
    Nireshaped = reshape(Ni, size(Xi));
    
    % "Deposit" Ni into Ne.

    F_out(:,:,:,t) = Nireshaped; % 
    fprintf('Time %d of %d done\n',t,T)  
 
end
