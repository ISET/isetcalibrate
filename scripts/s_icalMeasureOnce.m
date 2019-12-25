%% s_iCalMeasureMCC
%
%

%{
% Remember that for the PsychToolbox this must be the ordering of the
% IOPort call.

which -all IOPort
C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a\IOPort.mexw64
C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox\PsychBasic\IOPort.m
%}

%% Initialize isetcam to use ieSaveSpectralFiles.m function
ieInit;

%% Initialize the PR670 with PsychToolbox functions

% Select the correct COM port number for the photometer
% YOu can see which COM devices exist in the device manager under Ports
% (COM & LPT) sections.
photometerCOM = 'COM5';

if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
instrfind;

% ph = PR670init(photometerCOM);
msg = PR670init(photometerCOM);

startW = 380;
stepW  = 5;
endW   = 780;
wave   = startW:stepW:endW;  % Default pr670 wavelength sampling

% This is the isetcalibrate function that doesn't seem to run right.  The
% content seems to be for the 715 not the 670.
% ph = pr670init(photometerCOM);
% Change the pr aperture size to 0.5c
% The PR will integrate the spectrum over a smaller region, but the
% measurement will take longer
% fprintf(ph,'S,,,1\n');
% pause(1);

%% Initialize writing
dirName = [datestr(now,'yyyy-mm-dd'),'-MCC'];
folderName = fullfile(icalRootPath, 'local', dirName);
if ~exist(folderName, 'dir'), mkdir(folderName); end
cd(folderName);

%% Define the properties of this measurement
info.target      = 'white surface';  % tongue or white target
% info.target      = 'tongue';
info.lightsource = 'LED400 with short pass'; %
info.filter      = 'Y44';      % NIR
info.apertureSize = '1';
info.spectroRadioMeterModel = 'PR670';
info.nRepetitions = 1;
info.comment = 'Checking for residual long wave light';
comment = jsonwrite(info);

%% Make measurements and save them

% oeSet('light','blue')

fprintf('Measuring spectrum...');
% PsychToolbox function
spd = PR670measspd([startW stepW length(wave)]);
fprintf('Done\n')
oeSet('light','off')

ieNewGraphWin;
plot(wave,spd);
xlabel('Wavelength (nm)');
ylabel('Radiance (watts/sr/m2/nm)')

fname = sprintf('%s_%s_%s_%s',datestr(now,'hh-mm-ss'),info.target,info.lightsource,info.filter);
fullPathName = fullfile(folderName, fname);
fname =ieSaveSpectralFile(wave', spd, comment, fullPathName);

%% Quit PR670 remote mode
PR670write('Q', 0);

%% END