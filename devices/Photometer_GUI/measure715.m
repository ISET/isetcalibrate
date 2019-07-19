function [spd, wav, result, ii] = measure715()
addpath(genpath('C:\Users\SCIENlab\Documents\MATLAB-scien\MATLAB\isetcalibrate'))
clear all;
photometerCOM = 7;           % Select the correct COM port number for the photometer
%spectr = figure;

if ~isempty(instrfind)
fclose(instrfind);
delete(instrfind);
end
instrfind

ph = pr715init(photometerCOM);
% ph = pr670init(photometerCOM);
% Change the pr aperture size to 0.5c
% The PR will integrate the spectrum over a smaller region, but the
% measurement will take longer
% fprintf(ph,'S,,,1\n');
% pause(1);

%%
for ii = 1
fprintf('Measuring spectrum.... ');
spd = [];
while isempty(spd)
    [spd, wav] = pr715spectrum(ph);
end
%plot(wav,spd);
result(1,:) = wav;
result(2,:) = spd;
%%filename= sprintf('715_400.mat',ii);
%%save(filename,'result');
fprintf('Done!\n');
end
%% 
fclose(ph);

end

