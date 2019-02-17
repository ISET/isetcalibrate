%% Download and estimate homogeneity (linearity with respect to intensity)
%
% The SPD files contain the measured light spectra
% The ARRI files contain the raw images (left and right) from the ARRI
% camera 
%
%      set(groot,'defaultAxesColorOrder',co)
%
% BW/JEF  SCIENSTANFORD, 2019

%% Open up to the data on Flywheel
st = scitran('stanfordlabs');
st.verify;

% Find the project and the first calibration session
project = st.lookup('arriscope/ARRIScope Calibration'); 
thisSession  = project.sessions.findOne('label="20190208"');

% Working directory
chdir(fullfile(icalRootPath,'local'));

%% Get data from an acquisition for one of the channels

channel = 'Green';   % 'Red','Green','Blue','Violet','White', 'Infrared'
str     = sprintf('label=%s',channel);
Acquisition = thisSession.acquisitions.findOne(str);

%%  Down load the spectra.  Not very big.

spdZipFile = sprintf('%s_LightSpectra_mat.zip',channel);
spdFile = Acquisition.getFile(spdZipFile);
spdZip = sprintf('%s_spd.zip',channel);
spdFile.download(spdZip);
spdDir = sprintf('%s_spd',channel);
unzip(spdZip,spdDir);


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

[U,S,V] = svd(spectra);
ieNewGraphWin;
[~,idx] = max(abs(U(:,1)));
if U(idx,1) < 0, pc1 = -1*U(:,1);
else, pc1 = U(:,1);
end
plot(wave,pc1)

%% Compute Levels 

% These are the projection on the first principal component, scaled so
% that the brightest is 1
levels = pc1'*spectra;
levels = levels/max(levels(:));

% Compare with 'code'
ieNewGraphWin;
plot(code/max(code),levels,'o')
grid on; xlabel('Scaled file code'); ylabel('SPD level');
set(gca,'ylim',[0 1.1]); legend({'R','G','B'});
identityLine;

%% Find the mean values in the region of the ARRI images

chdir(fullfile(icalRootPath,'local',arriDir));

arriFiles = dir('*_CameraImage*.ari');
nFiles = numel(arriFiles);
arriMean = zeros(3,nFiles);
code = zeros(1,nFiles);

% Seemed like a good spatial region of the raw image to use
rect = [431 375 127 127]; 

for ii=1:nFiles
    a = split(arriFiles(ii).name,'_');
    a = split(a{3},'.');
    code(ii) = str2double(a{1});
    arriRGB = arriRead(arriFiles(ii).name);
    arriCrop = imcrop(arriRGB,rect);
    arriMean(:,ii) = mean(RGB2XWFormat(arriCrop))';
end

% 
ieNewGraphWin;
plot(code,arriMean,'o');
set(gca,'xlim',[0 10]);
xlabel('Code level'); ylabel('Channel mean');
grid on; legend({'R','G','B'});

%{
  [~,rect] = imcrop(rgb);
%}

%%