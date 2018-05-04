function rootPath=icalRootPath()
% Return the path to the root isetcalibrate directory
%
% This function must reside in the directory at the base of the
% ISETCALIBRATE directory structure.  It is used to determine the location
% of various sub-directories.
% 
% Example:
%   fullfile(icalRootPath,'data')

rootPath=which('icalRootPath');

[rootPath,fName,ext]=fileparts(rootPath);

end
