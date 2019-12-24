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
info.target      = 'mcc patches';  % tongue or white target
info.lightsource = 'Blue'; %
info.filter      = 'Y44';      % NIR
info.apertureSize = '1';
info.spectroRadioMeterModel = 'PR670';
info.nRepetitions = 1;
info.comment = 'Null';
comment = jsonwrite(info);

%%
% {'brown','orange','blue','white'}
oeSet('light','blue')
ieNewGraphWin;
nPatches = 24;
spd  = zeros(length(wave),nPatches);

for pp = 1:24
    fprintf('Ready for patch %d ',pp)
    pause;
    
    %% Make measurements and save them

    fprintf('Measuring spectrum (%d).... ',ii);
    % PsychToolbox function
    spd(:,pp) = PR670measspd([startW stepW length(wave)]);
    plot(wave,spd(:,pp));

    if ~isequal(length(wave),length(spd))
        warning('wav sampling not equal to spd measurements');
    end
    fprintf('\n');
    
end

%{
    ieNewGraphWin;
    plot(wave,spd); xlabel('Wavelength (nm)');
    ylabel('Radiance (watts/sr/m2/nm)')
%}

%% Save spectral data

fname = sprintf('%s_%s_%s',info.target,info.lightsource,info.filter);
fullPathName = fullfile(folderName, fname);
fname =ieSaveSpectralFile(wave', spd, comment, fullPathName);

%%
actions = oeActions('file name','mccWhite',...
    'directory',folderName,...
    'subject code','MCC',...
    'light',{'white','white'}, ...
    'exposure time',[30000 30000]);
 
files = oeCapture(actions);
oeShow(files{1})

%%
actions = oeActions('file name','mccBlue',...
    'directory',folderName,...
    'subject code','MCC',...
    'light',{'blue','blue'}, ...
    'exposure time',[30000,30000]);

files = oeCapture(actions);
oeShow(files{1})
oeShow(files{2})

%% Quit PR670 remote mode
PR670write('Q', 0);

%% END