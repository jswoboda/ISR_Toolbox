addpath(genpath('..'));

outdir=tempdir;
timefirstlast={'12-Jan-2015 08:00:00','12-Jan-2015 09:00:00'};

badfiles = dlFITS(outdir,timefirstlast);
