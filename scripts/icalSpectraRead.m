%% Inspecting spectra

chdir(fullfile(icalRootPath,'local'));
dSpectra = load('linearity_spectra.mat');

%% Simpler names
% 
%    dSpectra.values - These are the RGB values
%    dSpectra.wavelength - Wavelength samples in nm
%    dSpectra.linearity_spectra - SPD from the Photometer
%

wave = dSpectra.wavelength;
levels  = dSpectra.values;

% Pull out the spectra, but only up to 800 nm.  Last is 1068
lastWave = find(wave == 800);

wave = wave(1:lastWave);
spd  = dSpectra.linearity_spectra(:,1:lastWave)';

%% Notice that the black condition has a little bump of light around 850nm

vcNewGraphWin;
idx = logical( ((levels(:,2) == 0) .* (levels(:,3) == 0)) .* (levels(:,1) == 0));
blackSpectra = mean(spd(:,idx),2);
plot(wave, blackSpectra)
title('Black level'); grid on

%%  Test display spectra homogeneity

idx = logical( ((levels(:,2) == 0) .* (levels(:,3) == 0)) .* (levels(:,1) > 0));
redSpectra = spd(:,idx);
redSpectra = redSpectra - blackSpectra;
vcNewGraphWin;
plot(wave, redSpectra)
title('Red spectra (minus black)'); grid on

%% Green
idx = logical( ((levels(:,1) == 0) .* (levels(:,3) == 0)) .* (levels(:,2) > 0));
greenSpectra = spd(:,idx);
greenSpectra = greenSpectra - blackSpectra;
vcNewGraphWin;
plot(wave, greenSpectra)
title('Green spectra (minus black)'); grid on

%% Blue
idx = logical( ((levels(:,1) == 0) .* (levels(:,2) == 0)) .* (levels(:,3) > 0));
blueSpectra = spd(:,idx);
blueSpectra = blueSpectra - blackSpectra;
vcNewGraphWin;
plot(wave, blueSpectra)
title('Blue spectra (minus black)'); grid on

%% Test spectral additivity of the phosphors

% We used to call this phosphor independence some 30 years ago.  Brainard
% paper.
idx = logical(((levels(:,1) == 1) .* (levels(:,2) == 1)) .* (levels(:,3) == 1));
whiteSpectra = spd(:,idx) - blackSpectra;
vcNewGraphWin;
plot(wave, blueSpectra(:,end) + greenSpectra(:,end) + redSpectra(:,end),'--',...
    wave,whiteSpectra);
title('Test spectral additivity'); grid on

%% Solve for the scalar relationship between the spectra
%  Find a the scalar such that 

% Here is the display gamma
redWeights = mean(diag(1./redSpectra(:,end)) * redSpectra)';
dv = unique(levels(:,1));

% The 0 value is omitted from the output, but it is in the dv.  So we add
% it manually here.
plot(dv,[0;redWeights],'r-o'); grid on;
xlabel('Digital value')
ylabel('Relative intensity')

%%
% Here is the display gamma
greenWeights = mean(diag(1./greenSpectra(:,end)) * greenSpectra)';
dv = unique(levels(:,1));

% The 0 value is omitted from the output, but it is in the dv.  So we add
% it manually here.
plot(dv,[0;greenWeights],'r-o'); grid on;
xlabel('Digital value')
ylabel('Relative intensity')

%%
% Here is the display gamma
blueWeights = mean(diag(1./blueSpectra(:,end)) * blueSpectra)';
dv = unique(levels(:,1));

% The 0 value is omitted from the output, but it is in the dv.  So we add
% it manually here.
plot(dv,[0;blueWeights],'r-o'); grid on;
xlabel('Digital value')
ylabel('Relative intensity')

