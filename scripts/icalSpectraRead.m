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
rgb  = dSpectra.values;

% Pull out the spectra, but only up to 800 nm.  Last is 1068
lastWave = find(wave == 800);

wave = wave(1:lastWave);
spd  = dSpectra.linearity_spectra(:,1:lastWave)';

%% Notice that the black condition has a little bump of light around 850nm

vcNewGraphWin;
plot(wave, spd(:,1))
title('Black level'); grid on

%%  Test display spectra homogeneity

idx = logical((rgb(:,2) == 0) .* (rgb(:,3) == 0));
redSpectra = spd(:,idx);
redSpectra = redSpectra - spd(:,1);
vcNewGraphWin;
semilogy(wave, redSpectra)
title('Red spectra (minus black)'); grid on

%% Green
idx = logical((rgb(:,1) == 0) .* (rgb(:,3) == 0));
greenSpectra = spd(:,idx);
greenSpectra = greenSpectra - spd(:,1);
vcNewGraphWin;
plot(wave, greenSpectra)
title('Green spectra (minus black)'); grid on

%% Blue
idx = logical((rgb(:,1) == 0) .* (rgb(:,2) == 0));
blueSpectra = spd(:,idx);
blueSpectra = blueSpectra - spd(:,1);
vcNewGraphWin;
plot(wave, blueSpectra)
title('Blue spectra (minus black)'); grid on

%% Test spectral additivity of the phosphors

idx = logical(((rgb(:,1) == 1) .* (rgb(:,2) == 1)) .* (rgb(:,3) == 1));
whiteSpectra = spd(:,idx) - spd(:,1);
vcNewGraphWin;
plot(wave, blueSpectra(:,end) + greenSpectra(:,end) + redSpectra(:,end),'--',...
    wave,whiteSpectra);
title('Test spectral additivity'); grid on

%% Solve for the scalar relationship between the spectra
%  Find a the scalar such that 

redWeights = mean(diag(1./redSpectra(:,end)) * redSpectra);

