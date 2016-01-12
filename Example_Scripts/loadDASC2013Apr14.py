#!/usr/bin/env python3
from oct2py import Oct2Py
from os.path import expanduser

def downloadDASC(dayurl,outdir,timefirstlast):
    oc = Oct2Py(timeout=300)
    oc.addpath(oc.genpath('..'))
    oc.dlFITS(dayurl,expanduser(outdir),timefirstlast)


if __name__ == '__main__':
    url = 'https://amisr.asf.alaska.edu/PKR/DASC/RAW/2013/20130414/'
    outdir='/media/BigData/Dropbox/aurora_data/StudyEvents/2013-04-14/DASC/'
    timefirstlast=('14-Apr-2013 08:40:00','14-Apr-2013 09:00:00')

    downloadDASC(url,outdir,timefirstlast)
