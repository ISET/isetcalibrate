%% Compare the spectral radiance data obtained in different sessions
%
% What we learn is that on the two different days the illumination of the
% chart was not quite the same.  One day was brighter than the other, and
% also there was a smooth spatial distribution from darker to lighter from
% the left to the right of the MCC.
%
% 1 - Mini under tungsten on 26-Sep
% 2 - Mini under tungsten on 25-Sep
% 3 - Mini in the Gretag Illuminant A on 04-Oct
% 4 - ISETCam standard MCC reflectance data
% 5 - Arri mini reflectance measurements
%
% JEF/BW, 20201017

%% Read the spectra from the small MCC chart

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Spectral calibrations/26-Sep-2020';
spdFiles = dir(fullfile(dataDir,'*.mat'));

% How many wavelength samples?
% [~, w] = ieReadSpectra(fullfile(spdFiles(1).folder,spdFiles(1).name));
w = 420:5:670;

mccSPD1 = zeros(4,6,numel(w));

for ii=1:numel(spdFiles)
    d = ieReadSpectra(fullfile(dataDir,spdFiles(ii).name),w);
    row = str2double(spdFiles(ii).name(1));
    col = str2double(spdFiles(ii).name(2));
    if row >= 1  && row <= 4 && col >= 1 && col <= 6
        mccSPD1(row,col,:) = d(:);
        fprintf('%d %d -------\n',row,col);
    end
end

%% Show the MCC radiance data to check that they look reasonable
plotRadiance(w,RGB2XWFormat(mccSPD1));

%% White calibration target
%
% These were measured in different parts of the sensor

%{
fname = 'whiteCalibrationCenter.mat';
[lightSPD, w] = ieReadSpectra(fullfile(dataDir,fname));
plotRadiance(w,lightSPD);
%}

%% Read the spectra from the small MCC chart

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Spectral calibrations/25-Sep-2020';
spdFiles = dir(fullfile(dataDir,'*.mat'));

mccSPD2 = zeros(4,6,numel(w));

for ii=1:numel(spdFiles)
    d = ieReadSpectra(fullfile(dataDir,spdFiles(ii).name),w);
    row = str2double(spdFiles(ii).name(1));
    col = str2double(spdFiles(ii).name(2));
    if row >= 1  && row <= 4 && col >= 1 && col <= 6
        mccSPD2(row,col,:) = d(:);
        fprintf('%d %d -------\n',row,col);
    end
end

%% Show the MCC radiance data to check that they look reasonable
ieNewGraphWin;
plotRadiance(w,RGB2XWFormat(mccSPD2));

%% We see there is a scale factor between the two days.

scatter(mccSPD1(:),mccSPD2(:))
grid on;
identityLine;

%%  But the scale factor varies across space.

sFactors = zeros(4,6);
for rr=1:4
    for cc = 1:6
        ref1 = squeeze(mccSPD1(rr,cc,:));
        ref2 = squeeze(mccSPD2(rr,cc,:));
        % The scale factor will solve
        %   spd2 = spd1*sFactor
        sFactors(rr,cc) = ref1\ref2;
    end
end

% This shows the ratio between the two spectral radiance measurements on
% the two days.  They vary across the chart means that the way the
% illuminant covered the chart differed between the two days.
ieNewGraphWin;
imagesc(sFactors); colorbar;

%% How well do they agree if we correct by sFactors?

mccSPD1to2 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        ref1 = squeeze(mccSPD1(rr,cc,:));
        ref2 = squeeze(mccSPD2(rr,cc,:));
        mccSPD1to2(rr,cc,:) = mccSPD1(rr,cc,:)*sFactors(rr,cc);
    end
end

%%  Correcting by a scale factor that varies across space does quite well

ieNewGraphWin;
scatter(mccSPD1to2(:),mccSPD2(:));
identityLine;

% The two data set agree quite closely.
norm(mccSPD1to2(:) - mccSPD2(:))

%% Read the spectra from the small MCC chart in the Gretag box.
%

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Spectral calibrations/04-Oct-2020/mcc-Day';
spdFiles = dir(fullfile(dataDir,'*.mat'));

mccSPD3 = zeros(4,6,numel(w));

for ii=1:numel(spdFiles)
    d = ieReadSpectra(fullfile(dataDir,spdFiles(ii).name),w);
    row = str2double(spdFiles(ii).name(1));
    col = str2double(spdFiles(ii).name(2));
    if row >= 1  && row <= 4 && col >= 1 && col <= 6
        mccSPD3(row,col,:) = d(:);
        fprintf('%d %d -------\n',row,col);
    end
end

%% Show the MCC radiance data to check that they look reasonable
ieNewGraphWin;
plotRadiance(w,RGB2XWFormat(mccSPD3));

%% Analysis
%
% The A illuminant is a bit annoying, and there is no way to immediately
% compare the radiance data with the tungsten light irradiance data.  What
% we can do is divide out by the light to estimate the surface
% reflectances.  Then we can ask whether there is a spatial gradient in
% these data on the surface reflectance estimates.
%
% Since we don't have a real measurement of the light, we can treat the
% white surface (4,1) as if it were a true white surface and estimate the
% reflectances that way to get the spatial shading difference.
%

reflectances1 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances1(rr,cc,:) = mccSPD1(rr,cc,:) ./ mccSPD1(4,1,:);
    end
end
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances1)');

%%
reflectances2 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances2(rr,cc,:) = mccSPD2(rr,cc,:) ./ mccSPD2(4,1,:);
    end
end
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances2)');

%%
reflectances3 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances3(rr,cc,:) = mccSPD3(rr,cc,:) ./ mccSPD3(4,1,:);
    end
end
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances3)');

%%
ieNewGraphWin;
scatter(reflectances2(:),reflectances3(:));

%%  But the scale factor varies across space.

rFactors = zeros(4,6);
for rr=1:4
    for cc = 1:6
        ref2 = squeeze(reflectances2(rr,cc,:));
        ref3 = squeeze(reflectances3(rr,cc,:));
        % The scale factor will solve
        %   spd2 = spd1*sFactor
        rFactors(rr,cc) = ref2\ref3;
    end
end

% This shows the ratio between the two spectral radiance measurements on
% the two days.  They vary across the chart means that the way the
% illuminant covered the chart differed between the two days.
ieNewGraphWin;
imagesc(rFactors); colorbar;

%%
%% How well do they agree if we correct by sFactors?

reflectances2to3 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances2to3(rr,cc,:) = reflectances2(rr,cc,:)*rFactors(rr,cc);
    end
end

%%
ieNewGraphWin;
scatter(reflectances2to3(:),reflectances3(:));
identityLine; grid on

norm(reflectances2to3(:) - reflectances3(:))

%%
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances3)','k--');
hold on;
plot(w, RGB2XWFormat(reflectances2to3)','r-');


%%  This is the standard we are using ISETCam
%
% Let's compare
reflectancesStandard = ieReadSpectra('macbethChart.mat',w);
reflectances4 =  XW2RGBFormat(reflectancesStandard',4,6);


rFactors = zeros(4,6);
for rr=1:4
    for cc = 1:6
        ref4 = squeeze(reflectances4(rr,cc,:));
        ref3 = squeeze(reflectances3(rr,cc,:));
        % The scale factor will solve
        %   spd2 = spd1*sFactor
        rFactors(rr,cc) = ref4\ref3;
    end
end

% This shows the ratio between the two spectral radiance measurements on
% the two days.  They vary across the chart means that the way the
% illuminant covered the chart differed between the two days.
ieNewGraphWin;
imagesc(rFactors); colorbar;

%% How well do they agree if we correct by sFactors?

reflectances4to3 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances4to3(rr,cc,:) = reflectances4(rr,cc,:)*rFactors(rr,cc);
    end
end

%%
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances3)','k--');
hold on;
plot(w, RGB2XWFormat(reflectances4to3)','r-');

%%  This is the ARRI measured reflectance data compared to 3
%
% Let's compare
mcc5 = ieReadSpectra('/Users/wandell/Documents/MATLAB/LABS/WL/arriscope/data/macbethColorChecker/MiniatureMacbethChart.mat',w);
reflectances5 =  XW2RGBFormat(mcc5',4,6);

rFactors = zeros(4,6);
for rr=1:4
    for cc = 1:6
        ref5 = squeeze(reflectances5(rr,cc,:));
        ref3 = squeeze(reflectances3(rr,cc,:));
        % The scale factor will solve
        %   spd2 = spd1*sFactor
        rFactors(rr,cc) = ref5\ref3;
    end
end

% This shows the ratio between the two spectral radiance measurements on
% the two days.  They vary across the chart means that the way the
% illuminant covered the chart differed between the two days.
ieNewGraphWin;
imagesc(rFactors); colorbar;

%% How well do they agree if we correct by sFactors?

reflectances5to3 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances5to3(rr,cc,:) = reflectances5(rr,cc,:)*rFactors(rr,cc);
    end
end

%%
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances3)','k--');
hold on;
plot(w, RGB2XWFormat(reflectances5to3)','r-');

%%  This is the ARRI measured reflectance compared to (1)
%
% Let's compare
mcc5 = ieReadSpectra('/Users/wandell/Documents/MATLAB/LABS/WL/arriscope/data/macbethColorChecker/MiniatureMacbethChart.mat',w);
reflectances5 =  XW2RGBFormat(mcc5',4,6);

rFactors = zeros(4,6);
for rr=1:4
    for cc = 1:6
        ref5 = squeeze(reflectances5(rr,cc,:));
        ref1 = squeeze(reflectances1(rr,cc,:));
        % The scale factor will solve
        %   spd2 = spd1*sFactor
        rFactors(rr,cc) = ref5\ref1;
    end
end

% This shows the ratio between the two spectral radiance measurements on
% the two days.  They vary across the chart means that the way the
% illuminant covered the chart differed between the two days.
ieNewGraphWin;
imagesc(rFactors); colorbar;

%% How well do they agree if we correct by sFactors?

reflectances5to1 = zeros(4,6,numel(w));
for rr=1:4
    for cc = 1:6
        reflectances5to1(rr,cc,:) = reflectances5(rr,cc,:)*rFactors(rr,cc);
    end
end

%%
ieNewGraphWin;
plot(w, RGB2XWFormat(reflectances1)','k--');
hold on;
plot(w, RGB2XWFormat(reflectances5to1)','r-');


%% END


