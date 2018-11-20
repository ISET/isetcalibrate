clear all;
photometerCOM = 6;           % Select the correct COM port number for the photometer

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
ii=2;
fprintf('Measuring spectrum.... ');
spd = [];
while isempty(spd)
    [spd, wav] = pr715spectrum(ph);
%     [spd, wav] = pr670spectrum(ph);
end
%figure();
plot(wav,spd);

%save(sprintf('spectr%d.mat',80),'spd');
%cd('pink_jedeye_tungsten_spectra') 
result(1,:) = wav;
result(2,:) = spd;
filename= sprintf('test.mat',ii);
save(filename,'result');
fprintf('Done!\n');
%% 
fclose(ph);
