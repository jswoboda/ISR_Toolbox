function video = slicevideo( x,y,z,v,slicecell,varargin )
% slicevideo.m
% by John Swoboda
% This will make a video from a 4-D array, or a cell array of 3-D arrays.
% The video will be slices determined by the contents of slicecell.
% Additional inputs will allow for specific axis and titles.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
% video - Is a matlab video struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% x,y,z - Are 1-d arrays that hold x,y, and z dimensions.
% v - Is a 4-D array or a cell array of 3-D arrays that hold the data to be 
%     plotted.  The 3-D sub arrays must have a [Ny,Nx,NZ] size.
% slicecell - A cell array of vectors that have the surfaces that the slice
%           will be on.
% Optional Inputs
% title_cell - 'TitleStrings' - A cell array of strings that hold the title
%               for each of the frams of the movie.
% axlabels - 'AxisLabels' - A cell array of strings that hold the axis
%           labels for all three axis.
% clims - 'CLims' - A 2x1 array of min and max for the color scale. [min,max]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example:
% video = slicevideo( S_in.x,S_in.y,S_in.z,v,{[0],[0],[]},'TitleStrings',titlecell,...
%    'AxisLabels',axlabels,'CLims', clims);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Deal with inputs

if isa(v,'double')
    [Ny,Nx,Nz,Nt] = size(v);
elseif isa(v,'cell')
    Nt = length(v);
end

% make the default inputs for the limits and title.
title_cell = cell(1,Nt);
clims = [nan,nan];
for k = 1:Nt
    title_cell{k} = ['Frame ',num2str(k)];
    
    if isa(v,'double')
        curar = v(:,:,:,k);
        
    elseif isa(v,'cell')
        curar = v{:};
    end
    curmax = max(curar(:));
    curmin = min(curar(:));
    clims = [min(curmin,clims(1)),max(curmax,clims(2))];
end
% number of manditory inputs
Nmand = 5;
Nopt =  nargin-Nmand;

if mod(Nopt,2)
    error('Need even number of optional inputs')
end
% input labels
labels = varargin(1:2:end);
in_vals = varargin(2:2:end);

% possible inputs
poss_labels={'TitleStrings','AxisLabels','CLims'};
% set up default values
vals = {title_cell,{'x','y','z'},clims};
varnames = {'title_cell','axlabels','clims'};

% Get the input variables
checkinputs(labels,in_vals,poss_labels,vals,varnames);
%% Make Video
hfig = figure();
set(hfig,'Color',[1,1,1]);
for k = 1:Nt
    
    if isa(v,'double')
        curdata = squeeze(v(:,:,:,k));
    elseif isa(v,'cell')
        curdata = v{k};
    end
    % set up a slice array
    htemp = slice(x,y,z,curdata,slicecell{1},slicecell{2},slicecell{3});
    set(htemp,'EdgeColor','none', 'FaceColor','interp');
    xlabel(axlabels{1},'FontSize',16);
    ylabel(axlabels{2},'FontSize',16);
    zlabel(axlabels{3},'FontSize',16);
    title(title_cell{k})
    caxis(clims)
    cbh = colorbar;
    
    video(k) = getframe(hfig);
end

