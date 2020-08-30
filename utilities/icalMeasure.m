function [fname,msg] = icalMeasure(info,varargin)
% Make a single measurement with the PR670
%
% Info defines the properties of this measurement
%
% See also
%  icalInfo

% Examples:
%{
 info = icalInfo;
 fname = icalMeasure(info,'directory','test');
 foo = load(fname);
 ieNewGraphWin; plot(foo.wavelength,foo.data);
%}


% NOTE:  This may have to be run separately if PsychToolbox is not
% configured correctly.  That happens when we restart Matlab from time to
% time.
%
%{
% Remember that for the PsychToolbox this must be the ordering of the
% IOPort call.

which -all IOPort

C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a\IOPort.mexw64
C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox\PsychBasic\IOPort.m
If this is not the order, then we do this:
    cd C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox
     SetupPsychtoolbox
   type yes to all the questions
It should work after it finishes setup.
%}

%% Validate path

str = which('IOPort','-all');
[~,~,e]= fileparts(str{1});
if ~isequal(e,'.mexw64')
    error('PsychToolbox needs to be set.');
    % cd C:\Users\SCIENlab\Documents\MATLAB\Psychtoolbox\Psychtoolbox-3-master\Psychtoolbox
    % SetupPsychtoolbox
end

%% Parse inputs
p = inputParser;
p.addRequired('info',@isstruct);

defaultDirectory = [datestr(now,'yyyy-mm-dd'),'-Unknown'];
p.addParameter('directory',defaultDirectory,@ischar);
p.addParameter('doplot',true,@islogical);
p.parse(info,varargin{:});
info = p.Results.info;

target      = info.target;
lightsource = info.lightsource;
pr670filter = info.pr670filter;
comment     = info.comment;
doPlot      = p.Results.doplot;
dirName     = p.Results.directory;

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
folderName = fullfile(pwd, dirName);
if ~exist(folderName, 'dir'), mkdir(folderName); end
cd(folderName);
%% Make measurements and save them

% oeSet('light','blue') 

fprintf('Measuring spectrum...');
% PsychToolbox function
spd = PR670measspd([startW stepW length(wave)]);
fprintf('Done\n')

fname = sprintf('%s_%s_%s_%s',datestr(now,'hh-mm-ss'),target,lightsource,pr670filter);
fullPathName = fullfile(folderName, fname);
fname =ieSaveSpectralFile(wave', spd, comment, fullPathName);

%%
if doPlot
    ieNewGraphWin;
    plot(wave,spd);
    xlabel('Wavelength (nm)');
    ylabel('Radiance (watts/sr/m2/nm)')
end
%% Quit PR670 remote mode
PR670write('Q', 0);

end
