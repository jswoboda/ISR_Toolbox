===========
ISR_Toolbox
===========

This is a set of MATLAB / Octave 4.0 tools to analyze ISR data from Madrigal and other sources.

Install
=======
in Terminal::

  git clone --depth 1 https://github.com/jswoboda/ISR_Toolbox

in Matlab (each time you restart Matlab, reenter this or `add to your system startup.m to make permanent <http://www.mathworks.com/help/matlab/ref/startup.html?searchHighlight=startup.m>`_)
Note ``~/ISR_Toolbox`` is the path where you put ISR_Toolbox::

  addpath(genpath('~/ISR_Toolbox'))



Directories
===========

Allsky
------
tools to read Poker Flat Research Range DASC FITS data.

``dlFITS`` is the only file under ``Allsky`` you would normally use directly.

 Example for 2013 APR 14 from Matlab (note the date range is enclosed in braces, not brackets)::

  dlFITS('http://amisr.asf.alaska.edu/PKR/DASC/RAW/2013/20130414/',...
         '~/data/',{'14-Apr-2013 08:00:00','14-Apr-2013 08:10:00'})
