%% s_pr670MeasureMCCWithPause
%
% Remotely control the PR670 photospectrometer to measure spectral
% radiance for each of the 24 patches in the MCC.
% The radiances are saved in the column of a matrix in the
% ieSaveSpectralFiles format. 

%% Initialize isetcam to use ieSaveSpectralFiles.m function
ieInit;

%%
% Repeated measurements of a light
folderName = chdir(fullfile(oreyeRootPath,'local','mcc'));

%% Define the filename session

target = 'mcc24'; % tongue or white target
lightsource = 'OralEye_blue'; % LED400 / LED425 / LED450
filter = 'Y44'; % Y52 / NoY52
SubjectName = strcat(target,'_' ,lightsource,'_' ,filter);

%% Define the comment
subjectNumber = 'none';
shortPassFilter = 'None';
spectroRadioMeterModel = 'PR670';
longPassFilter = 'Y44';
power = 'None';
apertureSize = '0.5';

comment = strcat(target, " measurements for subject ", subjectNumber,...
            " illuminated with a ", lightsource, " with ", shortPassFilter,...
            " shortpass filter and measured with a ", spectroRadioMeterModel,...
            "spectroradiometer with ", longPassFilter,...
            ". Power supply was: ", power, " watts.", ...
            " The aperture size was: ", apertureSize, " deg.");
%% Initialize the communication to the instrument

photometerCOM = 'COM5'; % Select the correct COM port number for the photometer
%spectr = figure;

% Seems to close any open serial ports???
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
instrfind;

msg = PR670init(photometerCOM);

% ph = pr670init(photometerCOM);
% Change the pr aperture size to 0.5c
% The PR will integrate the spectrum over a smaller region, but the
% measurement will take longer
% fprintf(ph,'S,,,1\n');
% pause(1);

%%
wav = (350:5:780);
% setwav = [350 3 87];

% To measure fewer patches, make this number smaller
nPatches = 24;
data = zeros(length(wav),nPatches);
for ii = 1:nPatches
    fprintf('Set the photometer to patch %d\n',ii);
    pause;
    
    spd =[];
    while isempty(spd)
        spd = PR670measspd();
        % [spd, wav] = pr670spectrum(ph);
    end
    hold on
    plot(wav,spd);hold on
    data(:,ii) = spd;
end
fprintf('Done!\n');

%%
fullPathName = fullfile(pwd, SubjectName);
saveas(gcf,[SubjectName,'_mcc.fig'],'fig');
ieSaveSpectralFile(wav', data, comment, fullPathName);
toc
% fclose(ph);
%{
s_400 = load('stanford_670_400.mat');
s_400 = s_400.result;filename= sprintf('oraleye_2_20190711_oraleye_reflect_blue_10.mat');

plot(s_400(1,:), s_400(2,:));hold on
p_400 = load('715_400.mat');
p_400 = p_400.result;
plot(p_400(1,:), p_400(2,:));
%}

%% quit remote mode
PR670write('Q', 0);
