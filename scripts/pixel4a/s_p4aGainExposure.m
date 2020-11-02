%% Images were taken in the integrating sphere
%
% s_p4aGainExposure
%
% The images have different gain and exposure.
% The light level was always the same
%
% We read the camera response, gain, and exposure.  We plot the
% relationship.
%


%%
% dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201024/ISO Gain/A';
% dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201024/ISO Gain/CWF';
% dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201024/ISO Gain/Day';

% dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201026/Vignetting-Exposure-Speed';
% dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/20201027/Vignetting-Exposure-Speed';
% dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Camera A/relativeIlluminationGretag';
% dataDir = '/Volumes/Wandell/Data Psych 221 Projects/Color calibration/Measurements 1/DNG-Illuminant-A';
% dataDir = '/Volumes/Wandell/Data Psych 221 Projects/Color calibration/Measurements 1/DNG-Illuminant-CWF';
% dataDir = '/Volumes/Wandell/Data Psych 221 Projects/Color calibration/Measurements 1/DNG-Illuminant-Day';

chdir(dataDir)

%% Read them and dumpt the headers to see if the orientation is coded there
dngFiles = dir('*.dng');
nFiles = numel(dngFiles);
fname = cell(nFiles,1);
speed = zeros(nFiles,1);
exposure = zeros(nFiles,1);
black = zeros(nFiles,1);

%%
fprintf('\n\n----------\n');
for ii=1:nFiles
    fname{ii} = dngFiles(ii).name;
    [~,info] = ieDNGRead(fname{ii},'simple info',true,'only info',true);
    speed(ii)     = info.isoSpeed;
    exposure(ii)  = info.exposureTime;
    black(ii)     = info.blackLevel(1);
    fprintf('%s\n',fname{ii});
    fprintf('speed %d, exp time %.3f ms, black level %.2f\n\n', speed(ii),exposure(ii)*1e3, black(ii)); 
end

%% Create an XL table

T = table(fname,speed,exposure,black);
writetable(T,'fileinfo.xlsx','Sheet',1);

%%  Make a sensor from the file
[sensorM, info] = sensorDNGRead(fname{1});

%% END