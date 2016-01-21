function badfiles = dlFITS(final_dir,times,varargin)
% dlFITS
% by John Swoboda
% This function will find the DASC data within a certain time period and down it
% to specific directory.
%% Inputs
% final_dir - The directory that the data will be downloaded to.
% times - A cell array of date strings that will hold the time limits
% wl - The desired wavelength of the optical data.
%% Example
% final_dir =  '/Volumes/Research/eng_research_irs/PINOT/Data_Fusion/FusedData/';
% times = {'11/24/2012 6:00:00','11/24/2012 6:15:00'};
% wl = 558;
% dlFITS(final_dir,times,wl)
%%
urlstem = 'https://amisr.asf.alaska.edu/PKR/DASC/RAW/';

p = inputParser;
addOptional(p,'wl',[])
p.parse(varargin{:})
U = p.Results;

if ~exist(final_dir,'dir')
    error(['Your output directory ',final_dir,' does not exist'])
end

%%
s = datevec(times{1});
urlstem = [urlstem,int2str(s(1)),'/',int2str(s(1)),num2str(s(2),'%02d'),num2str(s(3),'%02d'),'/'];
allfiles = htmlfindfile(urlstem,'*\.FITS');
red_file_list = fitslistparce(allfiles,times,U.wl);

nfile = length(red_file_list);
disp(['outputting ',int2str(nfile),' files to ',final_dir])
if nfile > 1000
    warning(['Attempting to download ',int2str(nfile),' files, this may take a long time and use a lot of Hard drive space.'])
end

badfiles = {};

for k = 1:nfile
    temp_url = [urlstem,red_file_list{k}];
    temp_fileput = fullfile(final_dir,red_file_list{k});

    updatestr = [red_file_list{k},' ', int2str(k),' / ',int2str(nfile)];

    trynum=1;
    
    if exist(temp_fileput,'file')
        badfile = verfits(temp_url,temp_fileput,trynum);
        if badfile
            badfiles{end+1} = temp_fileput; %#ok<AGROW>
        end
        continue
    else
        disp(['downloading ',updatestr])
    end


    try
        grabfile(temp_url,temp_fileput,trynum)
    catch
        disp(['problem downloading ',temp_url])
    end
    pause(0.5+0.5*rand(1)) %random delay of 0.5-1.0 second to avoid getting banned
end %for

if ~isempty(badfiles)
    warning(['could not download ',int2str(length(badfiles)),' files.'])
    disp(badfiles)
end

end %function

function badfile = grabfile(temp_url,temp_fileput,trynum)      
    try
        websave(temp_fileput,temp_url,'Timeout',30);
    catch
        urlwrite(temp_url,temp_fileput);
    end
    
    badfile = verfits(temp_url,temp_fileput,trynum);
end %function

function badfile = verfits(temp_url,temp_fileput,trynum)
    
    % partially verify download by seeing if 512x512 pixel image was truncated
    %finf = fitsinfo(temp_fileput);
    %finf.PrimaryData.Keywords
    try
        fitsread(temp_fileput,'PixelRegion',{512,512}); 
        badfile = false;
    catch err
        trynum = trynum+1;
        disp(err.message)
        warning(['download ',temp_fileput,' failed, retrying'])
        if trynum<=3
            pause(0.5) %don't wildly recycle
            badfile = grabfile(temp_url,temp_fileput,trynum);
        else
            warning(['tried 3 times to download ',temp_url,' , giving up!'])
            badfile=true;
        end
    end
    
end %function