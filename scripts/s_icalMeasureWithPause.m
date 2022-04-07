%% s_iCalMeasureWithPause
%
% Old Psychtoolbox methods.  Deprecated for icalPR670 modern code.
%
% Remotely control the PR670 photospectrometer to measure spectral
% reflection for OralEye project. Edit the code so that the result can be
% saved with the same format as ieSaveSpectralFiles do.
%
% PsychToolbox must be on the path and it must have the proper ordering of
% the IOPort directories.
%
%{
chdir('C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox');
SetupPsychtoolbox
PsychStartup
%}
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
dirName = datestr(now,'yyyy-mm-dd');
folderName = fullfile(icalRootPath, 'local', dirName);
if ~exist(folderName, 'dir'), mkdir(folderName); end
cd(folderName);

%% Define the properties of this measurement

info.target      = 'whiteSurface';  % tongue or white target
info.lightsource = 'Tungsten'; % 
info.filter      = 'NIR';      % NIR
info.apertureSize = '1';
info.spectroRadioMeterModel = 'PR670';
info.nRepetitions = 1;
info.comment = 'Null';
comment = jsonwrite(info);

%% Make several measurements and save them

spd  = zeros(length(wave),nRepetitions);
for ii = 1:info.nRepetitions
    fprintf('Measuring spectrum (%d).... ',ii);
    % PsychToolbox function
    spd(:,ii) = PR670measspd([startW stepW length(wave)]);
    if ~isequal(length(wave),length(spd))
        warning('wav sampling not equal to spd measurements');
    end
    fprintf('\n');
end

% isetcalibrate - not yet working we think
%     [spd, wav] = pr670spectrum(ph);
    
%{
    ieNewGraphWin;
    hold on
    plot(wave,spd); xlabel('Wavelength (nm)'); 
    ylabel('Radiance (watts/sr/m2/nm)')
%}

%% Save spectral data

fname = sprintf('%s_%s_%s',info.target,info.lightsource,info.filter);
fullPathName = fullfile(folderName, fname);
fname =ieSaveSpectralFile(wave', spd, comment, fullPathName);

% {
nir = 'whiteSurface_Tungsten_NIR.mat';
none = 'whiteSurface_Tungsten_none.mat';
spdNIR = ieReadSpectra(nir,wave);
spdNone = ieReadSpectra(none,wave);
ieNewGraphWin; plot(wave,spdNIR,'k-',wave,spdNone,'r:');
ieNewGraphWin; semilogy(wave,spdNIR ./ spdNone);
grid on



%}
%% Quit PR670 remote mode
PR670write('Q', 0);

%% END