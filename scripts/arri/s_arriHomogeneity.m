%% s_arriHomogeneity.m

% Purpose: Make sure that the ARRIScope raw image data are linear with
% light intensity for each of 6 different lights:
%       Red, Green, Blue, UV,White and Infrared

% Background:
%   We captured ARRIScope camera (RGB) images of a white calibration target
%   under 6 different lights
%   and we also measured the spectral radiance of the white calibration
%   target under the 6 different lights
%   The SPD files contain the measured light spectra
%   The ARRI files contain the raw images (left and right) from the ARRI
%   camera 
%   We uploaded the data to a Flywheel database in order to archive and
%   document the original data

% IN THIS SCRIPT we
%   1. Download the data from the Flywheel database
%   2. unzip the data into a local directory
%   3. 
% Download and estimate homogeneity (linearity with respect to intensity)
% Documentation and results of this analysis are in 
% https://docs.google.com/document/d/1O_KHnzWTAt7flg8k9T0OvyRQ-bFjVbCBAMM4wdbU1O0/edit#heading=h.ows9qdbadce7

% BW/JEF  SCIENSTANFORD, 2019

%% Set root path for Matlab
% 
%      set(groot,'defaultAxesColorOrder',co)

%% Open up to the data on Flywheel
st = scitran('stanfordlabs');
st.verify;

% Find the project and the first calibration session
project = st.lookup('arriscope/ARRIScope Calibration'); 
thisSession  = project.sessions.findOne('label="20190208"');

% Working directory
chdir(fullfile(icalRootPath,'local'));

%% Get data from an acquisition for one of the channels
% Select the light with spectra and camera images that we want to analyze


channel = 'Red';   % 'Red','Green','Blue','UV','White', 'Infrared'
str     = sprintf('label=%s',channel);
Acquisition = thisSession.acquisitions.findOne(str);


%%  Download the spectra.  Not very big.

spdZipFile = sprintf('%s_LightSpectra_mat.zip',channel);
spdFile = Acquisition.getFile(spdZipFile);
spdZip = sprintf('%s_spd.zip',channel);
spdFile.download(spdZip);
spdDir = sprintf('%s_spd',channel);
unzip(spdZip,spdDir);
disp('Downloaded and unzipped spd data');

%{
% Programming note
% If you want to see the files inside a ZIP file, you can do this
zipInfo    = Acquisition.getFileZipInfo(zipFile);
thisZip{1} = zipInfo; stPrint(thisZip,'members','path')

entryName = zipInfo.members{1}.path;
outPath = fullfile('/tmp', entryName);
acquisition.downloadFileZipMember('my-archive.zip', entryName, outPath);
%}

%% Download the arri images.  These are pretty big

arriZipFile = sprintf('%s_CameraImage_ari.zip',channel);
arriFile = Acquisition.getFile(arriZipFile);
arriZip = sprintf('%s_arri.zip',channel);
arriFile.download(arriZip)
arriDir = sprintf('%s_arri',channel);
unzip(arriZip,arriDir);
disp('Downloaded and unzipped ari data');

%% Read the spectra, figure out the code and intensity levels

chdir(fullfile(icalRootPath,'local',spdDir));

spdFiles = dir('*_LightSpectra*.mat');
nFiles = numel(spdFiles);
load(spdFiles(1).name,'result');
wave = result(1,:);

spectra = zeros(length(wave),nFiles);
code = zeros(1,nFiles);

for ii=1:length(spdFiles)
    a = split(spdFiles(ii).name,'level'); 
    a = split(a{2},'_');
    code(ii) = str2double(a{1});
    load(spdFiles(ii).name,'result');
    spectra(:,ii) = result(2,:)';
end

%{
% In case you want to check that the spd have the same shape

semilogy(wave,spectra);
set(gca,'ylim',[1e-3 1]);
mx = max(spectra);
spectra = spectra*diag(1./mx);
%}

% This plots the first principle component (mean) of the spectral energy
[U,S,V] = svd(spectra);
ieNewGraphWin;
[~,idx] = max(abs(U(:,1)));
if U(idx,1) < 0, pc1 = -1*U(:,1);
else, pc1 = U(:,1);
end
plot(wave,pc1)
title(sprintf('Channel %s\n',channel));

%% Compute Levels 

% These are the projection on the first principal component, scaled so
% that the brightest is 1
levels = pc1'*spectra;
% levels = levels/max(levels(:));

% Compare with 'code'
ieNewGraphWin;
% plot(code/max(code),levels,'o');
plot(code,levels,'o');
% plot(code,levels,'o');
% grid on; xlabel('Scaled file code'); ylabel('SPD level');
grid on; xlabel('Level file code'); ylabel('SPD level');
% set(gca,'ylim',[0 1.1]); 
% identityLine;
title(sprintf('Channel %s\n',channel));

%% Find the mean values in the region of the ARRI images

chdir(fullfile(icalRootPath,'local',arriDir));

arriFiles = dir('*_CameraImage*.ari');
nFiles = numel(arriFiles);
arriMean = zeros(3,nFiles);
code = zeros(1,nFiles);

% Seemed like a good spatial region of the raw image to use
% [~,rect] = imcrop(arriRGB);
rect = [431 375 127 127]; 

for ii=1:nFiles
    a = split(arriFiles(ii).name,'_');
    a = split(a{3},'.');
    code(ii) = str2double(a{1});
    arriRGB = arriRead(arriFiles(ii).name);
    % imagescRGB(arriRGB);
    arriCrop = imcrop(arriRGB,rect);
    arriMean(:,ii) = mean(RGB2XWFormat(arriCrop))';
end

% 
ieNewGraphWin;
plot(code,arriMean(1,:),'ro', code,arriMean(2,:),'go',code,arriMean(3,:),'bo');
% set(gca,'xlim',[0 11]);
xlabel('Code level','FontSize',24); ylabel('Channel mean','FontSize',24);
grid on; legend({'R','G','B'});
title(sprintf('Channel %s\n',channel),'FontSize',24,'FontWeight','normal');

%%
chdir(fullfile(icalRootPath,'local'));


%%