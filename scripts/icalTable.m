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
wavelength = dSpectra.wavelength;
% idxMaxWave = find(wave == 800);
% wave = wave(1:idxMaxWave);

%% Make a table

% The first six columns are R, G, B of the display or sensor
% The seventh column is the corresponding spd for that level.
% 
T = array2table([displayRGB, sensorRGB]);
T.Properties.VariableNames = {'dR','dG','dB','sR','sG','sB'};

wave = 400:20:800;

spd = zeros(size(dSpectra.linearity_spectra,1),numel(wave));
for ii=1:size(dSpectra.linearity_spectra,1)
    spd(ii,:) = interp1(wavelength,dSpectra.linearity_spectra(ii,:),wave);
end
T.spd = spd;

% To see the top few lines of the table, do this
% head(T)

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
k = 1e-1;
sensor = zeros(length(wave),3);
offset = zeros(1,3);
X = spd';
for ii = 1:3
    % ridge(y,X,k)
    % foo = (spd*spd' + k*eye(size(spd,1)))*spd*sensorRGB(ii,:)';
    y = sensorRGB(ii,:)';
    X = spd';
    
    % This solves so that y = X*b, where
    % y is 40 x 1, X is 40 x nWave, and b is nWave x 1
    % The predictions are not perfect, but the sensors look a lot like the
    % true sensors.  Why?
    
    b = ridge(y,X,k,1);
    sensor(:,ii) = b;
    
    %{
    b = lsqnonneg(X,y);
    sensor(:,ii) = b;
    %}
    % This produces perfect predictions.  Puzzling.  The sensors are not at
    % all like the real sensors.
    %{
     b0 = ridge(y,X,k,0);
     % yHat = X*b(2:end) + b(1);
     % vcNewGraphWin; plot(yHat(:),y(:),'o');
     sensor(:,ii) = b0(2:end);  % The first term is a constant offset
     offset(ii)   = b0(1);
    %}
    
    % This produces something unlike the ridge regression, although it is
    % supposed to produce the same.  Maybe if I normalized X or something?
    % b = pinv(X'* X + k*eye(size(X,2))) * X'* y;  % plot(wave,b)

    % For the case of flag = 1;
    % Ypred = mean(y) + ((Xpred-m)./s')*B1
    
    % From regression to ridge regression
    % y = Xb
    % X'y = (X' X)b
    % (X' X + kI ) ^-1 y = b

    % k = 1e-1
    % b = pinv(X'* X + k*eye(size(X,2))) * X'* y;  % plot(wave,b)
    

    % From the doc ridge notes
    % m = mean(X); s = std(X,0,1)';
    % b_scaled = b ./ s;
    % b0 = [mean(y) - m*b_scaled; b_scaled];
    % vcNewGraphWin; plot(b0(2:end),b1(:),'o')
    % vcNewGraphWin; plot(y(:),X*b,'o'); identityLine;
    
    % tmp = inv(X'*X + k*eye(size(X,2)))*X'*y; % plot(wave,tmp)
    % Find b that solves y = X*b subject to the ridge reg constraint
    
    %{
    foo = ridge(y,X,k);  % plot(wave,foo)
    tmp = inv(((X'* X) + k*eye(size(X,2)))) * X' * y; % plot(wave,tmp)
    vcNewGraphWin; plot(foo(:),tmp(:),'o')
    %}
    
    % tmp = ((X'* X) + k*eye(size(X,2))) \ ( X' * y);
end

%% Calculate the predicted sensor value, which is a scale factor different
% from the 
obs  = sensorRGB';
pred = spd'*sensor + offset;  % X*sensor + offset

% Find the scale factor to deal with the ridge regression screwing up the
% scale because of 'k' value
%    obs = pred*s
%    pred'*obs = pred'*pred*s
%    inv(pred'*pred)*(pred'*obs) = scaleFactor
%
scaleFactor = (pred(:)'*pred(:))\(pred(:)'*obs(:));
pred = pred*scaleFactor;

%%
vcNewGraphWin;
plot(wave,sensor/max(sensor(:)))
title(sprintf('RMSE(k=%.3f) %.3g',k,sqrt(mean((pred(:) - obs(:)).^2))))
xlabel('Wavelength (nm)');
ylabel('Responsivity');
grid on
set(gca,'ylim',[-0.3 1.1]);

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

