%%  sensorSpectralQE
%
% Curating data from the pixel4a to estimate the spectral QE
%
% 1. Pull out the MCC images from the DNG files
% 2. Bring the radiance measurements of the 24 patches
% 3. Add in the illumination measure if we have one
%
%  The data sets we have are images under the A, Day, and CWF illuminations
%  within the Gretag box.
%
%  This script creates a struct of the linear DNG data and other metadata
%  Struct will include
%
%     * The Original dng file name
%     * The DNG info read from the header
%     * The rect we used to crop the region (rect)
%     * Spectral radiances of some (N) patches (up to 24)
%     * Estimated illuminant spectral radiance
%     * Raw data from the DNG file
%     * Demosaicked DNG data
%
%  Students will uses these data to calculate the spectral QE of the RGB
%  pixel 4a channels.
%
%  In separate scripts we  provide data sets for people to estimate other
%  optics and sensor parameters
%
%    * How similar are the RGB values when the data come from different
%      parts of the sensor (rect)
%    * For each channel figure RGB scaling as the same target is positioned
%      in different positions on the sensor (relative illumination camera)
%    * Does the relative illumination of the camera full account for any
%      RGB differences when measured at different locations?  In
%      particular, suppose you measure near the center:  Can you predict
%      the RGB values at different field heights from just the RI
%      measurements.
%    * Uniformity of the light in the Gretag box at time of capture
%      These are from the DNG files that contain images of the Gretag box.
%    * Different noise terms (read, dark noise, PRNU, DSNU) - to be
%      collected.  See the s_sensorNoiseEstimation script
%    * Best f/# for the lens - to be collected.  Images of a sharp edge and
%      then figure through simulation what an equivalent f/# of a
%      diffraction limited lens would be
%
%    ** GRAPHICS
%    * Use the estimated sensor to show an image of the Cornell box
%
%    ** Perception and image quality
%    * Compare the predicted image of the Cornell box with actual images of
%    the box
%
% JEF/BW, 20201017

%%
%% Figure out the exp and speed of the images from October 24, 2020
%%

% Sort by ISO Gain
dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201024/ISO gain/A';
chdir(dataDir)
dngFiles = dir('*.dng');
nFiles = numel(dngFiles);
for ii=1:nFiles
    isoValues(ii).name = dngFiles(ii).name; %#ok<*SAGROW>
    isoValues(ii).info = imfinfo(isoValues(ii).name);
    isoValues(ii).isospeed = isoValues(ii).info.ISOSpeedRatings;
    isoValues(ii).exposure = isoValues(ii).info.ExposureTime;
end
%% Set up matrix parameters for exp vs. speed

exposure = zeros(1,numel(dngFiles));
isospeed = zeros(1,numel(dngFiles));

for ii=1:numel(dngFiles)
    isospeed(ii) = isoValues(ii).isospeed;
    exposure(ii) = isoValues(ii).exposure;
end
% histogram(log10(exposure),20); xlabel('Log10 exp time (sec)');
% histogram(log10(isospeed),20); xlabel('Log10 speed')

uIsospeeds = unique(isospeed);
uExposure  = unique(exposure);
nSpeed    = length(uIsospeeds);
nExposure  = length(uExposure);
data = zeros(nExposure,nSpeed);

%% Arrange from slowest to fastest speeds
% Not sure this is valuable.
%{
[speeds, idx] = sort(isospeeds);
isoValues = isoValues(idx);
%}

%% Find all the files with a particular exposure

expSpeed = zeros(nExposure,nSpeed);
for ii=1:nExposure
    % Find all the data with this exposure
    lst = (exposure == uExposure(ii));
    % What are the speeds for these?
    speedList = isospeed(lst);
    for jj=1:length(speedList)
        idx = find(speedList(jj) == uIsospeeds);
        expSpeed(ii,idx) = expSpeed(ii,idx) + 1;
    end
end

%%
ieNewGraphWin;
imagesc(expSpeed);
xlabel('Speed'); ylabel('Exposure');

%%
%% Images from October 4, 2020 and October 24, 2020
%%

% MCC images with Camera A
% These are from the little setup

% September 26th data
% '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/opticalBenchMCC/20200926'

%  October 4, 2020 MCC images from 20201004 made within the Gretag Box.
%  '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/smallerGretagBoxMCC/Day'
%  '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/smallerGretagBoxMCC/CWF'
%  '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/smallerGretagBoxMCC/A'

% October 24 data also in the Gretag box
%  '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201024/ISO gain/A';
% 
dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201024/ISO gain/A';
chdir(dataDir);

dngFiles = dir(fullfile(dataDir,'*.dng'));
% [locs,rect] = ieROISelect(sensor);
% save('mccRect','rect');
load('mccRect','rect');

%% Loop over all the DNG files and make the ip files

for ii=1:numel(dngFiles)
    % We are in the data directory
    fname = fullfile(dngFiles(ii).name);
    
    [sensorM, info] = sensorDNGRead(fname);
    
    % For some of the data sets we have to do this manually
    % [~,rect]  = ieROISelect(sensorM);
    
    %  Crop out a central region so it's not so big
    mccPosition = round(rect.Position);
    
    sensorCropped = sensorCrop(sensorM,mccPosition);
    ieReplaceObject(sensorCropped); pause(1);
    sensorWindow();
    
    % Show it in the IP window to confirm the colors are right
    
    ip = ipCreate;
    ip = ipSet(ip,'render demosaic only',true);
    ip = ipCompute(ip,sensorCropped);
    ipWindow(ip);
    
    % Save out the data struct for this MCC image
    [~,n,e] = fileparts(fname);
    ipName = ['ip',n,'.mat'];
    chdir(dataDir);
    save(ipName,'ip','mccPosition','isoSpeed','exposureTime','blackLevel','info','fname');
    
    ieDeleteObject('sensor');
    ieDeleteObject('ip');

end

%%  Visualize the ip*.mat
ipFiles = dir('ip*.mat');
for ii=1:numel(ipFiles)
    disp(ii);
    load(ipFiles(ii).name,'ip');
    ipWindow(ip);
    pause(1);
end



%% To read the MCC data, use
%{
load(ipName,'ip'); ipWindow(ip);
load(ipName,'mccPosition');
% This is the position of the mcc in the image.  Size is about 3K x 4K.
center = [mccPosition(1) + mccPosition(3)/2, ...
    mccPosition(2) + mccPosition(4)/2];

% This code extracts the rgb and checks the rectangles
cp = chartCornerpoints(ip);
blackedge = true;
sFactor = 0.4;
[rects,mLocs,pSize] = chartRectangles(cp,4,6,sFactor,blackedge);
chartRectsDraw(ip,rects);
mRGB = chartRectsData(ip,mLocs,pSize(1)/2,false);
%}
