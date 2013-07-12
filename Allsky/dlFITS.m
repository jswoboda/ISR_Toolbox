function dlFITS(myurl,final_dir,times,varargin)
% dlFITS
% by John Swoboda
% This function will find the data within a certain time period and down it
% to specific directory.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
% myurl - The url that all the files are located.
% final_dir - The directory that the data will be downloaded to.
% times - A cell array of date strings that will hold the time limits
% wl - The desired wavelength of the optical data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example
% myurl = 'http://amisr.asf.alaska.edu/PKR/DASC/RAW/2012/20121124/';
% final_dir =  '/Volumes/Research/eng_research_irs/PINOT/Data_Fusion/FusedData/';
% times = {'11/24/2012 6:00:00','11/24/2012 6:15:00'};
% wl = 558;
% dlFITS(myurl,final_dir,times,wl)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


allfiles = htmlfindfile(myurl,'*\.FITS');

if nargin >3
    
    red_file_list = fitslistparce(allfiles,times,varargin{1});
else
    red_file_list = fitslistparce(allfiles,times);
end
for k = 1:length(red_file_list)
    temp_filename = [myurl,red_file_list{k}];
    temp_fileput = fullfile(final_dir,red_file_list{k});
    urlwrite(temp_filename,temp_fileput);
end