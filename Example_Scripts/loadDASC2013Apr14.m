addpath(genpath('..'));

url = 'https://amisr.asf.alaska.edu/PKR/DASC/RAW/2013/20130414/';
outdir='/media/BigData/Dropbox/aurora_data/StudyEvents/2013-04-14/DASC/';
timefirstlast={'14-Apr-2013 08:40:00','14-Apr-2013 09:00:00'};

dlFITS(url,outdir,timefirstlast);
