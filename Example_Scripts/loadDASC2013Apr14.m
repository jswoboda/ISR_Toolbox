#!/usr/bin/env octave

addpath(genpath('..'));

url = 'http://amisr.asf.alaska.edu/PKR/DASC/RAW/2013/20130414/';
outdir='~/data/';
timefirstlast={'14-Apr-2013 08:00:00','14-Apr-2013 08:10:00'};

dlFITS(url,outdir,timefirstlast);
