function figdir2movie(fig_dir,outname,varargin)
% figdri2movie
% figdir2movie(fig_dir,outname,s)
% This will take a directory with a set of figures and make them into a
% movie.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% fig_dir - A string that is the location of the directory
% outname - The name of the video
% s - A struct that is set up with the same variable names as the
% videoWriter class
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig_info = dir(fullfile(fig_dir,'*.fig'));
writerObj = VideoWriter(outname);
% populate the writerObj object
if nargin >2
    s = varargin{1};
    names = fieldnames(s);
    for k = 1:length(names)
        set(writerObj,names{k},getfield(s,names{k}));
    end
end
% start saving things
open(writerObj);
for k = 1:length(fig_info)
    
    h = open(fullfile(fig_dir,fig_info(k).name)); 
    frame = getframe(h);
    writeVideo(writerObj,frame);
    close(h)
end
close(writerObj);
