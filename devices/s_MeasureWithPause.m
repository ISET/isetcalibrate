%% s_MeasureWithPause
% Remotely control the PR670 photospectrometer to measure spectral
% reflection for OralEye project. Edit the code so that the result can be
% saved with the same format as ieSaveSpectralFiles do.

%% Initialize isetcam to use ieSaveSpectralFiles.m function
ieInit;

%%
tic
% Repeated measurements of a light
% cd('C:\Users\SCIENlab\Desktop\20190911LEDMeasurements');
folderName = 'C:\Users\SCIENlab\Desktop/ZhengLyu';
cd(folderName);
% SubjectName = 'WhiteTarget_Velscope';
SubjectName = 'Test_ZhengLyu';
photometerCOM = 'COM5';           % Select the correct COM port number for the photometer
%spectr = figure;

if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind);
end
instrfind;

% ph = PR670init(photometerCOM);
msg = PR670init(photometerCOM);
% ph = pr670init(photometerCOM);
% Change the pr aperture size to 0.5c
% The PR will integrate the spectrum over a smaller region, but the
% measurement will take longer
% fprintf(ph,'S,,,1\n');
% pause(1);
%%
nMeasruement = 3;
 %%
for ii = 1:nMeasurement
    fprintf('Measuring spectrum.... ');
    spd =[];
    wav = [350:5:780];
    setwav = [350 3 87];
    while isempty(spd)
        spd = PR670measspd();
        %     [spd, wav] = pr670spectrum(ph);
    end
%     figure();
    hold on
    plot(wav,spd);hold on
    result(1,:) = wav;
    result(2,:) = spd;
    %save(sprintf('spectr%d.mat',80),'spd');
    %cd('C:\Users\SCIENlab\Documents\MATLAB-scien\MATLAB\workdir\velscope')
%     filename= sprintf([SubjectName,'_%dV.mat'],29-ii);
    filename = sprintf([SubjectName, '_No_%d_test.mat'], ii);
    fullpathname = fullfile(pwd, filename);
%     save(filename,'result');
    ieSaveSpectralFile(wav, spd, filename, fullpathname);
    fprintf('Done!\n');
%     if ii~=3
%         uiwait(msgbox('Please decrease the light level by 1 V.','Pause','modal'));
%     end
end
saveas(gcf,[SubjectName,'_450Light.fig'],'fig');
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
