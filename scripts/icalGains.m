%% Read the display and sensor RGB values from the gain experiment

chdir(fullfile(icalRootPath,'local','gain'));
cameraRGB = load('camera_rgb_values.mat');

% gains x levels x RGB
sensorRGB = cameraRGB.RGB_mean_values;
gains     = cameraRGB.gain_levels;
levels    = cameraRGB.levels;           % Equal to dSpectra.levels

dSpectra    = load('display_spectra.mat');
wavelength  = dSpectra.wave;
spdMeasured = dSpectra.spd;

%% Building up the table

M = [];
for ii=1:size(sensorRGB,1)
    M = [M ; levels, squeeze(sensorRGB(ii,:,:)) , repmat(gains(ii),size(sensorRGB,2),1)];
end

T = array2table(M);
T.Properties.VariableNames = {'dR','dG','dB','sR','sG','sB','gain'};

wave = 400:4:800;

spd = zeros(size(levels,1),numel(wave));
for ii=1:size(levels,1)
    spd(ii,:) = interp1(wavelength,spdMeasured(ii,:),wave);
end
spd = repmat(spd,numel(gains),1);

T.spd = spd;

%% Notice that the black condition includes light at 850nm (and elsewhere)

vcNewGraphWin;
blackSpectra = T{T.dR == 0 & T.dG == 0 & T.dB == 0,'spd'};
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

%%  All the display spectra

gain = 11;

blackSPD = T{T.dR == 0 & T.dG == 0 & T.dB == 0 & T.gain == gain,'spd'};

redSPD = T{T.dR > 0 & T.dG == 0 & T.dB == 0 & T.gain == gain,'spd'};
redSPD = redSPD - blackSPD;
redLevels = T{T.dR > 0 & T.dG == 0 & T.dB == 0 & T.gain == gain,'dR'};
redWeights = mean(redSPD * diag(1./mean(redMax)),2);

greenSPD = T{T.dR == 0 & T.dG > 0 & T.dB == 0 & T.gain == gain,'spd'};
greenSPD = greenSPD - blackSPD;   % plot(greenSPD')
greenLevels = T{T.dR == 0 & T.dG > 0 & T.dB == 0,'dG'};
greenWeights = mean(greenSPD * diag(1./mean(greenMax)),2);

blueSPD = T{T.dR == 0 & T.dG == 0 & T.dB > 0 & T.gain == gain,'spd'};
blueSPD = blueSPD - blackSPD;
blueLevels = T{T.dR == 0 & T.dG == 0 & T.dB > 0 & T.gain == gain,'dB'};
blueWeights = mean(blueSPD * diag(1./mean(blueMax)),2);

%%  Calculate the display gamma curves

dv = unique(redLevels(:,1));

%{
 dv = [0;dv];
 redWeights = [0;redWeights];
 greenWeights = [0;greenWeights];
 blueWeights = [0;blueWeights];
%}

vcNewGraphWin;
plot(dv,redWeights,'r-o',...
    dv,greenWeights,'g-o',...
    dv,blueWeights,'b-o'); grid on;
xlabel('Digital value')
ylabel('Relative intensity')

%% Pull out of the table two different gains

blackR = T{T.dR == 0 & T.dG == 0 & T.dB == 0 & T.gain==1,'sR'}

rGain1  = T{T.dR > 0 & T.dG == 0 & T.dB == 0 & T.gain==1,'sR'}  - blackR(1);
rGain6  = T{T.dR > 0 & T.dG == 0 & T.dB == 0 & T.gain==6,'sR'}  - blackR(2);
bGain11 = T{T.dR > 0 & T.dG == 0 & T.dB == 0 & T.gain==11,'sR'} - blackR(3);

vcNewGraphWin;
loglog(redWeights,rGain1, 'ro-',redWeights,rGain6,'bx-')
rGain6 ./ rGain1

%%
vcNewGraphWin;
bGain1  = T{T.dR == 0 & T.dG == 0 & T.dB > 0 & T.gain==1,'sB'};
bGain6  = T{T.dR == 0 & T.dG == 0 & T.dB > 0 & T.gain==6,'sB'};
% bGain11 = T{T.dR == 0 & T.dG == 0 & T.dB > 0 & T.gain==11,'sB'};

semilogy(blueWeights,bGain1, 'o',blueWeights,bGain6,'sb')

% plot(blueWeights,bGain1, 'o',blueWeights,bGain6,'x', blueWeights, bGain11,'s')
xlabel('Display level (linear)');
ylabel('Sensor response');

grid on
