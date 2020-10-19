%% Pull out the MCC images from the DNG files
%
%  Save the linear data
%  Save the meta data including
%    Exposure
%    Gain
%    Location in the image where the MCC was extracted
%    Anything else important
%
% JEF/BW, 20201017

%% Read the spectra from the small MCC chart

% MCC images with Camera A
% These are from the little setup

%  These are some from 20201004 in the Gretag Box.
%
% '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/Smaller Gretag Box/Day'

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/MCC/20200926';
dngFiles = dir(fullfile(dataDir,'*.dng'));

fname = fullfile(dngFiles(1).name);

% These worked too, once.
%{
 fname = fullfile(isetRootPath,'local','cornell_box.dng');
 fname = fullfile(igRootPath,'local','mcc','IMG_20200926_110536_1.dng');
%}

%% Metadata
if ~exist(fname,'file')
    error('No file found %s\n',fname);
else
    chdir(dataDir);
    img          = dcrawRead(fname);
    % dcInfo       = dcrawInfo(fname);
    info         = imfinfo(fname);
    isoSpeed     = info.DigitalCamera.ISOSpeedRatings;
    exposureTime = info.DigitalCamera.ExposureTime;
    blackLevel   = info.SubIFDs{1}.BlackLevel;    
end

%% These are the raw data

ieNewGraphWin; 
imagesc(double(img).^(1/2.2)); axis image; 
colormap(gray)

%% We remove the digital offset
blackLevelDigital = 1024;
img = img - blackLevelDigital;

%% Stuff the measured raw data into a simulated sensor

measSensorSize = size(img);
sensorM = sensorCreate('IMX363');
sensorM = sensorSet(sensorM,'size',size(img));
sensorM = sensorSet(sensorM,'exp time',exposureTime);

% Trying different patterns.  This appears to be the Bayer pattern for the
% Google Pixel 4a.
sensorM = sensorSet(sensorM,'pattern',[2 1; 3 2]);

sensorM = sensorSet(sensorM,'digital values',img);
sensorM = sensorSet(sensorM,'wave',400:10:700);
sensorWindow(sensorM);

[cp,sensorM,rect] = chartCornerpoints(sensorM);
%%  Crop out a central region so it's not so big

newSensor = sensorCrop(sensorM,rect);
sensorWindow(newSensor);

%% Show it in the IP window to confirm the colors are right

ip = ipCreate;
ip = ipSet(ip,'render demosaic only',true);
ip = ipCompute(ip,newSensor);
ipWindow(ip);

% Plot a horizontal line
uData = ipPlot(ip,'horizontal line',[1 455]);

% d = get(gcf,'userdata');