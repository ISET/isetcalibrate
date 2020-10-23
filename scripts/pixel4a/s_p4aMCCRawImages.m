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

%% Read the spectra from the small MCC chart

% MCC images with Camera A
% These are from the little setup

%  These are MCC images from 20201004 made within the Gretag Box.
% '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/smallerGretagBoxMCC/Day'
% '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/smallerGretagBoxMCC/CWF'
% '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/smallerGretagBoxMCC/A'

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/opticalBenchMCC/20200926';
dngFiles = dir(fullfile(dataDir,'*.dng'));

for ii=6:numel(dngFiles)
    fname = fullfile(dngFiles(ii).name);
    
    %% Metadata
    if ~exist(fullfile(dataDir,fname),'file')
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
    
    blackLevel = blackLevel(1);
    img = ieClip(img,blackLevel,[]);   % sets the lower to blacklevel, no upper bound
    
    %% These are the raw data.  Let's have a look.
    
    %{
      ieNewGraphWin;
      % Let's make the black level 0
      imagesc((double(img) - blackLevel).^(1/2.2)); axis image;
      colormap(gray)
    %}
    
    %% Stuff the measured raw data into a simulated sensor
    
    measSensorSize = size(img);
    % clear sensorM;
    
    sensorM = sensorCreate('IMX363');
    sensorM = sensorSet(sensorM,'size',size(img));
    sensorM = sensorSet(sensorM,'exp time',exposureTime);
    sensorM = sensorSet(sensorM,'black level',blackLevel);
    sensorM = sensorSet(sensorM,'name',fname);
    
    % Trying different patterns.  This appears to be the Bayer pattern for the
    % Google Pixel 4a.
    sensorM = sensorSet(sensorM,'pattern',[2 1; 3 2]);
    
    sensorM = sensorSet(sensorM,'digital values',img);
    sensorM = sensorSet(sensorM,'wave',400:10:700);
    sensorWindow(sensorM);
    pause(1);
    
    %%  Crop out a central region so it's not so big
    [~,rect]  = ieROISelect(sensorM);
    mccPosition = round(rect.Position);
    
    sensorCropped = sensorCrop(sensorM,mccPosition);
    ieReplaceObject(sensorCropped); pause(1);
    sensorWindow();
    
    %% Show it in the IP window to confirm the colors are right
    
    ip = ipCreate;
    ip = ipSet(ip,'render demosaic only',true);
    ip = ipCompute(ip,sensorCropped);
    ipWindow(ip);
    
    %% Save out the data struct for this MCC image
    [~,n,e] = fileparts(fname);
    ipName = ['ip',n,'.mat'];
    chdir(dataDir);
    save(ipName,'ip','mccPosition','isoSpeed','exposureTime','blackLevel','info','fname');
    
    ieDeleteObject('sensor');
    ieDeleteObject('ip');

end


%% To read it, use
%{
load(ipName,'ip');
%}
