function UT = datestr2unix(datestr)

UT = 24*3600*(datenum(datestr)-datenum('jan-01-1970'));

end