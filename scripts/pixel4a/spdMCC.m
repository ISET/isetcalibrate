%% Assemble the calibration data from the Google Drive 
%
%  These were measurements of the MCC on the day we calibrated the Google
%  Pixel 4a phones.
%

%% Read the spectra from the small MCC chart

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Spectral calibrations/26-Sep-2020';
spdFiles = dir(fullfile(dataDir,'*.mat'));

% How many wavelength samples?
[d, w] = ieReadSpectra(fullfile(spdFiles(1).folder,spdFiles(1).name));

mccSPD = zeros(4,6,numel(w));

for ii=1:numel(spdFiles)
    d = ieReadSpectra(fullfile(dataDir,spdFiles(ii).name));
    row = str2double(spdFiles(ii).name(1));
    col = str2double(spdFiles(ii).name(2));
    if row >= 1  && row <= 4 && col >= 1 && col <= 6
        mccSPD(row,col,:) = d(:);
        fprintf('%d %d -------\n',row,col);
    end
end

%% Show the MCC radiance data to check that they look reasonable
plotRadiance(w,RGB2XWFormat(mccSPD));

%% White calibration target
%
% These were measured in different parts of the sensor

fname = 'whiteCalibrationCenter.mat';
[lightSPD, w] = ieReadSpectra(fullfile(dataDir,fname));
plotRadiance(w,lightSPD);

%% Estimate the reflectance functions

[radiance, row,col] = RGB2XWFormat(mccSPD);
plotRadiance(w,radiance);

inverseLight = (1 ./ lightSPD(:));

reflectance = (radiance * diag(inverseLight));
plotReflectance(w,reflectance);

%% Compare these with the stored reflectances
mccSurfaces = macbethChartCreate(1,[],w);
mccReflectance = RGB2XWFormat(mccSurfaces.data);
plotReflectance(w,mccReflectance);

mcc1 = ieReadSpectra('macbethChart.mat',w);
mcc2 = ieReadSpectra('macbethChart-20180324.mat',w);
mcc3 = ieReadSpectra('/Users/wandell/Documents/MATLAB/LABS/WL/arriscope/data/macbethColorChecker/MiniatureMacbethChart.mat',w);

ieNewGraphWin;
scatter(mcc1(:),mcc2(:)); identityLine
scatter(mcc1(:),mcc3(:)); identityLine

%% This shows they are similar, but not the same

tmp = reflectance';
scatter(tmp(:),mcc3(:));
identityLine;

%%  Open a DNG raw image of the MCC

mccDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/MCC/20200926';
dir(fullfile(mccDir,'*.dng'))

fname = fullfile(mccDir,'IMG_20200926_110428.dng');
if exist(fname,'file')
    % The spaces in the name are a problem for dcraw executable.
    copyfile(fname,'tmp.dng')
    img = dcrawRead('tmp.dng');
    delete('tmp.dng');
end

ieNewGraphWin; imagesc(img ./ (1/2.2)); axis image; colormap(gray)

%%
measSensorSize = size(img);
sensorM = sensorCreate('IMX363');

% sensorM = sensorIMX363('isospeed', isoSpeed, ...
%     'exposuretime', exposureTime, ...
%     'rowcol',measSensorSize);

% Trying different patterns.  This appears to be the Bayer pattern for the
% Google Pixel 4a.
sensorM = sensorSet(sensorM,'pattern',[2 1; 3 2]);

sensorM = sensorSet(sensorM,'digital values',img);
sensorM = sensorSet(sensorM,'wave',400:10:700);
% sensorWindow(sensorM);

%%  Crop out a central region so it's not so big

rect = [800 1300 1200 1200];
newSensor = sensorCrop(sensorM,rect);
sensorWindow(newSensor);

%% Show it in the IP window to confirm the colors are right

ip = ipCreate;
ip = ipSet(ip,'sensor conversion method','none');
ip = ipSet(ip,'illuminant correction method','none');
ip = ipSet(ip,'internal color space','sensor');
ip = ipCompute(ip,newSensor);
ipW = ipWindow(ip);

%% Get the 24 RGB MCC values

% When there are the thick black edges, choose the outer segment about one
% thick black edge away from the color patch corner.
cp = chartCornerpoints(ip);
[rects, mLocs, pSize] = chartRectangles(cp,4,6, 0.4);
rectHandles = chartRectsDraw(ip,rects);
fullData = false;
mRGB = chartRectsData(ip,mLocs,pSize(1)*0.8,fullData);

%% END


