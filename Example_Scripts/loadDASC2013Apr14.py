#!/usr/bin/env python3
from oct2py import Oct2Py

def downloadDASC(dayurl,outdir,timefirstlast):
    oc = Oct2Py(timeout=300)
    oc.addpath(oc.genpath('..'))
    oc.dlFITS(dayurl,outdir,timefirstlast)


if __name__ == '__main__':
    url = 'http://amisr.asf.alaska.edu/PKR/DASC/RAW/2013/20130414/'
    outdir='~/data/'
    timefirstlast=('14-Apr-2013 08:00:00','14-Apr-2013 08:10:00')

    downloadDASC(url,outdir,timefirstlast)
