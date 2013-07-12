function [X_out,Y_out,d_image] = allsky2enu(all_sky,az,el,alt,im_sz)
% allsky2enu.m
% [X_out,Y_out,d_image] = allsky2enu(all_sky,az,el,rng,im_sz)
% This function will take allsky data and from either a FITS file or memory
% and output the data on to a cartisian grid.  That is determined from the
% parameter im_sz.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% all_sky - This can either be an NxM image or the name of a FITS file that
% holds the data.
% az - This can either be an NxM image or the name of a FITS file that
% holds the az locations.
% el- This can either be an NxM image or the name of a FITS file that
% holds the el locations
% alt - A scalar that holds determines where the image will be projected to
% in meters.
% im_sz = The final size of the image in the lat/long space [N_lat, N_lon].
% if it a scalar N_lat = N_long = im_sz.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% X_out - A 1xN X array that holds the X dimension (east) spacing.
% Y_out - A 1xN Y array that holds the Y dimesion (north) spacing.
% d_image - The final image on lat long space of size[N_lat,N_lon]
%% Check input
% open allsky file or just use matrix
if ischar(all_sky)
    d=fitsread(all_sky);
else
    d = all_sky;
end
% open az file or just use matrix

if ischar(az)
    az_i=fitsread(az);
else
    az_i =az;
end
% open el file or just use matrix

if ischar(el)
    el_i = fitsread(el);
else
    el_i = el;
end
% check to make sure az and el
if ~all(size(el_i)==size(d))||~all(size(az_i)==size(d))
    error('El and Az need to be same size as data');
end
% Check the desired size input
if length(im_sz) ==1
    im_sz = [im_sz,im_sz];
end
%% Fix problems with the az matrix
% Look for large gradients in the az mapping because the in between values
% will put the data in the wrong spot.
grad_thresh = 15;
[Fx,Fy] = gradient(az_i);
bad_data_logic = sqrt(Fx.^2+Fy.^2)>grad_thresh;
az_i(bad_data_logic) = 0;


% flip image and el/az maps to satellite projection. This is left over code
% from google earth mappings
df=fliplr(d);
az_if=fliplr(az_i);
el_if=fliplr(el_i);

%% Translate to new coordinate system
% Take the locations of the data and place them in a new coordinate system.
alt_mat = alt*ones(size(az_i));

% Get the data in east north up
x_data = alt_mat.*sind(az_i).*cotd(el_i);
y_data = alt_mat.*cosd(az_i).*cotd(el_i);
z_data = alt_mat;

xl = x_data(:);
yl = y_data(:);
zl = z_data(:);

% trim nans from the data locations

good_data = ~(isnan(xl)|isnan(yl)|isinf(xl)|isinf(yl));
xl = xl(good_data);
yl = yl(good_data);
zl = zl(good_data);

% Get the latitude and longitude coordinates

ENU = [xl(:), yl(:)]; % Original positions
positions=double(ENU);
%% Interpolate data

% create the vectors that the data will be interpolated over.
xv = linspace(min(positions(:,1)),max(positions(:,1)),im_sz(2));
yv = linspace(min(positions(:,2)),max(positions(:,2)),im_sz(1));
[Xi,Yi] = meshgrid(xv,yv);
posmesh   = [Xi(:), Yi(:)]; % New positions
values = d(:);
values = values(good_data);
d_resamp = griddatan(positions,values,posmesh,'linear');
d_image = reshape(d_resamp, size(Xi));

% The output lat and long vectors
X_out = xv;
Y_out = yv;
