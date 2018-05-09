%% Make a table to store the calibration data
%
% The columns will be
%
%  display         sensor             SPD
% R   G   B      R   G   B           Vector
%

%% Read the display and sensor RGB values

chdir(fullfile(icalRootPath,'local'));
dRGB = load('rgb_values.mat');

sensorRGB = dRGB.RGB_mean_values;
displayRGB = dRGB.values;

dSpectra = load('linearity_spectra.mat');
wave = dSpectra.wavelength;
idxMaxWave = find(wave == 840);
wave = wave(1:idxMaxWave);

%% Make a table

% The first six columns are R, G, B of the display or sensor
% The seventh column is the corresponding spd for that level.
% 
T = array2table([displayRGB, sensorRGB]);
T.Properties.VariableNames = {'dR','dG','dB','sR','sG','sB'};

T.spd = dSpectra.linearity_spectra(:,1:idxMaxWave);

head(T)

%% Notice that the black condition has a little bump of light around 850nm

vcNewGraphWin;
blackSpectra = T{T.dR==0 & T.dG == 0 & T.dB == 0,'spd'};
blackSPD = mean(blackSpectra);
plot(wave,blackSPD)
title('Black level'); grid on

%%  Estimate the primary spectra from max display settings

redMax = T{T.dR == 1 & T.dG == 0 & T.dB == 0,'spd'};
redMax = redMax - blackSPD;
greenMax = T{T.dR == 0 & T.dG == 1 & T.dB == 0,'spd'};
greenMax = greenMax - blackSPD;
blueMax = T{T.dR == 0 & T.dG == 0 & T.dB == 1,'spd'};
blueMax = blueMax - blackSPD;
whiteMax = T{T.dR == 1 & T.dG == 1 & T.dB == 1,'spd'};
whiteMax = whiteMax - blackSPD;

%%
vcNewGraphWin;
plot(wave, redMax, 'r-',wave, ...
    greenMax','g-',...
    wave,blueMax','b-', ...
    wave,whiteMax','k--', ...
    wave,redMax + greenMax + blueMax, 'k:')
grid on;
set(gca,'ylim',[0 1.1*max(whiteMax(:))]);
legend({'red','green','blue','white','sum'})

title('Primary spectra and sums (minus black)'); grid on
xlabel('Wavelength (nm)');
ylabel('Energy');

%%  All the spectra

redSPD = T{T.dR > 0 & T.dG == 0 & T.dB == 0,'spd'};
redSPD = redSPD - blackSPD;
redLevels = T{T.dR > 0 & T.dG == 0 & T.dB == 0,'dR'};
redWeights = mean( redSPD * diag(1./redMax),2);

greenSPD = T{T.dR == 0 & T.dG > 0 & T.dB == 0,'spd'};
greenSPD = greenSPD - blackSPD;   % plot(greenSPD')
greenWeights = mean(greenSPD * diag(1./greenMax),2);
greenLevels = T{T.dR == 0 & T.dG > 0 & T.dB == 0,'dG'};

blueSPD = T{T.dR == 0 & T.dG == 0 & T.dB > 0,'spd'};
blueSPD = blueSPD - blackSPD;
blueLevels = T{T.dR == 0 & T.dG == 0 & T.dB > 0,'dB'};
blueWeights = mean( blueSPD * diag(1./blueMax),2);

%%
dv = unique(redLevels(:,1));
dv = [0;dv];
redWeights = [0;redWeights];
greenWeights = [0;greenWeights];
blueWeights = [0;blueWeights];

plot(dv,redWeights,'r-o',...
    dv,greenWeights,'g-o',...
    dv,blueWeights,'b-o'); grid on;
xlabel('Digital value')
ylabel('Relative intensity')

