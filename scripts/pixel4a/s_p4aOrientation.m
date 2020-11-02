%% How to determine the Bayer pattern for changing orientations
%{
----------
Name: CCW90.dng, Orientation 1
Width 4032 Height 3024
---------
Name: CW90.dng, Orientation 3
Width 4032 Height 3024
---------
Name: Inverted.dng, Orientation 8
Width 3024 Height 4032
---------
Name: Upright.dng, Orientation 6
Width 3024 Height 4032
---------
%}

% Four orientations are in this directory
dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201026/Orientation';
chdir(dataDir)

% Read them and dumpt the headers to see if the orientation is coded there
dngFiles = dir('*.dng');
nFiles = numel(dngFiles);

fprintf('\n\n----------\n');
for ii=1:nFiles
    fname = dngFiles(ii).name;
    info = imfinfo(fname);
    img = dcrawRead(fname);
    fprintf('Name: %s, Orientation %d\n',fname, info.Orientation);
    fprintf('Width %d Height %d\n',size(img,2),size(img,1));
    fprintf('---------\n');
end

% Orientation and CFA pattern
% 6 and appears to be 2,1; 
%% END