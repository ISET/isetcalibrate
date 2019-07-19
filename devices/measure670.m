function [spd, wav, result, ii] = measure670()
clear all;
photometerCOM = 'COM5';           % Select the correct COM port number for the photometer
%spectr = figure;
if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind);
end

instrfind
% ph = PR670init(photometerCOM);
msg = PR670init(photometerCOM);
% ph = pr670init(photometerCOM);
% Change the pr aperture size to 0.5c
% The PR will integrate the spectrum over a smaller region, but the
% measurement will take longer
% fprintf(ph,'S,,,1\n');
% pause(1);
%%

for ii = 1

%ii=1;
fprintf('Measuring spectrum.... ');
spd =[];
wav = [350:5:780];%---default
setwav = [350 5 length(wav)];
while isempty(spd)
        spd = PR670measspd();
%     [spd, wav] = pr670spectrum(ph);
end
%hold on

%plot(wav,spd);hold on

result(:,1) = wav;
result(:,2) = spd;

%save(sprintf('spectr%d.mat',80),'spd');
%cd('pink_jedeye_tungsten_spectra') 
% filename= sprintf('007_tongue_blue_flashlight_%d.mat',ii);
% filename= sprintf('007_tongue_tungsten_%d.mat',ii);
% filename= sprintf('007_lip_blue_flashlight_%d.mat',ii);
% filename= sprintf('007_lip_tungsten_%d.mat',ii);
% filename= sprintf('007_teeth_blue_flashlight_%d.mat',ii);
% filename= sprintf('007_teeth_tungsten_%d.mat',ii);
% filename= sprintf('007_white_blue_%d.mat',ii);
%%filename = sprintf('velscope.mat');
% filename= sprintf('007_white_tungsten_%d.mat',ii);
%%save(filename,'result');
fprintf('Done!\n');
end
%% quit remote mode
PR670write('Q', 0);
% fclose(ph);
