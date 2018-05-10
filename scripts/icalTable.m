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
idxMaxWave = find(wave == 800);
wave = wave(1:idxMaxWave);

%% Make a table

% The first six columns are R, G, B of the display or sensor
% The seventh column is the corresponding spd for that level.
% 
T = array2table([displayRGB, sensorRGB]);
T.Properties.VariableNames = {'dR','dG','dB','sR','sG','sB'};

T.spd = dSpectra.linearity_spectra(:,1:idxMaxWave);
 
% To see the top few lines of the table, do this
% head(T)

%% Notice that the black condition has a little bump of light around 850nm

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

%%  Calculate the gamma curves

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

%% Predict the sensor RGB from the spectra using ridge regression

% We get the sensor RGB values, and we assume that they should be 0 when
% the display RGB is 0.  So we find the black response and subtract that
% from the measured sensorRGB
sensorRGB = [T.sR, T.sG, T.sB]';
blackRGB(1)  = mean(T{T.dR == 0 & T.dG == 0 & T.dB == 0,'sR'});
blackRGB(2)  = mean(T{T.dR == 0 & T.dG == 0 & T.dB == 0,'sG'});
blackRGB(3)  = mean(T{T.dR == 0 & T.dG == 0 & T.dB == 0,'sB'});
sensorRGB = sensorRGB - blackRGB';

spd       = T.spd';

% There should be a sensor matrix that maps the spectra into the sensor RGB
% values
%
% Find an S such that sensorRGB = S*spd;
% S = sensorRGB*pinv(spd);
% But because of noise we use ridge regression

% y = X*b
k = 0.07;
sensor = zeros(length(wave),3);
for ii = 1:3
    % ridge(y,X,k)
    % foo = (spd*spd' + k*eye(size(spd,1)))*spd*sensorRGB(ii,:)';
    y = sensorRGB(ii,:)';
    X = spd';
    sensor(:,ii) = ridge(y,X,k,1);
    % sensor(:,ii) = inv(X'*X + k*eye(size(X,2)))*X'*y;
end

%%
obs  = sensorRGB';
pred = spd'*sensor;

% Find the scale factor to deal with the ridge regression screwing up the
% scale because of 'k' value
%    obs = pred*s
%    pred'*obs = pred'*pred*s
%    inv(pred'*pred)*(pred'*obs) = scaleFactor
%
scaleFactor = (pred(:)'*pred(:))\(pred(:)'*obs(:));
pred = pred*scaleFactor;

vcNewGraphWin;
plot(wave,sensor)
title(sprintf('RMSE(k=%.3f) %.3g',k,sqrt(mean((pred(:) - obs(:)).^2))))
xlabel('Wavelength (nm)');
ylabel('Responsivity');
grid on

%%
vcNewGraphWin;
plot(obs(:,1),pred(:,1),'ro', ...
    obs(:,2),pred(:,2),'go',...
    obs(:,3),pred(:,3),'bo','markersize',10);
grid on; identityLine; axis equal
xlabel('Observed RGB');
ylabel('Predicted RGB');
title(sprintf('RMSE(k=%.3f) %.3g',k,sqrt(mean((pred(:) - obs(:)).^2))))

%%


%%

