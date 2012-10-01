% A custom 3D plotting routine

function plotMatrixAlpha(axH,Matrix,alphavec,xscale,yscale,zscale)
hold(axH,'on');
[az,el] = view(axH);

% Make the alpha matrix
[AlphaMat] = makeAlphaMatrix(Matrix,alphavec);

% Override on the number of slices we want to plot
% Plot only 20 in each direction
nxslice = 20; nyslice = 20; nzslice = 20;
matsize = size(Matrix);
values = reshape(Matrix,1,numel(Matrix));
minv = min(values);
maxv = max(values);
% Check that we take the smaller size
if nxslice > matsize(1)
    nxslice = matsize(1);
end
if nyslice > matsize(2)
    nyslice = matsize(2);
end
if nzslice > matsize(3)
    nzslice = matsize(3);
end
%slices = [nxslice,nyslice,nzslice];

% Generate the list of points we will be using to grab the data and do the
% plotting.
% xps = x plot scale
% xpm = x plot mesh
% Debugging code - known to work
xps = round(linspace(1,length(xscale),nxslice));
yps = round(linspace(1,length(yscale),nyslice));
zps = round(linspace(1,length(zscale),nzslice));
[xpm,ypm,zpm] = ndgrid(xscale(xps),yscale(yps),zscale(zps));

%figure; hold on;
for x = 1:nxslice
    shandle = surf(axH,squeeze(xpm(x,:,:)),squeeze(ypm(x,:,:)),squeeze(zpm(x,:,:)),squeeze(Matrix(x,yps,zps)));
    alpha(shandle,squeeze(AlphaMat(x,yps,zps)));    caxis([minv,maxv]);
end
% shading flat; view(3);
% axis tight;
% xlabel(xname); ylabel(yname); zlabel(zname);

% figure; hold on;
for y = 1:nyslice
    shandle = surf(axH,squeeze(xpm(:,y,:)),squeeze(ypm(:,y,:)),squeeze(zpm(:,y,:)),squeeze(Matrix(xps,y,zps)));
    alpha(shandle,squeeze(AlphaMat(xps,y,zps)));    caxis([minv,maxv]);
end
% shading flat; view(3);
% axis tight;
% xlabel(xname); ylabel(yname); zlabel(zname);

% figure; hold on;
for z = 1:nzslice
    shandle = surf(axH,squeeze(xpm(:,:,z)),squeeze(ypm(:,:,z)),squeeze(zpm(:,:,z)),squeeze(Matrix(xps,yps,z)));
    alpha(shandle,squeeze(AlphaMat(xps,yps,z)));    caxis([minv,maxv]);
end
% Set properties for the final axes
shading(axH,'flat');
view(axH,[az,el]);
axis(axH,'tight');
%xlabel(xname); ylabel(yname); zlabel(zname);
