function [mccRadiance, w] = icalRadianceMCCRead(dataDir)
% Read in the radiance data from the MCC chart captured with the PR670
%
% See also
%

%%
thisDir = pwd;
chdir(dataDir);

radianceFiles = dir(fullfile(dataDir,'*.mat'));
if isempty(radianceFiles), error('No radiance files found'); end

% How many wavelength samples?
[~, w] = ieReadSpectra(fullfile(radianceFiles(1).folder,radianceFiles(1).name));

%%
mccRadiance = zeros(4,6,numel(w));

for ii=1:numel(radianceFiles)
    d = ieReadSpectra(fullfile(dataDir,radianceFiles(ii).name),w);
    row = str2double(radianceFiles(ii).name(1));
    col = str2double(radianceFiles(ii).name(2));
    if row >= 1  && row <= 4 && col >= 1 && col <= 6
        mccRadiance(row,col,:) = d(:);
        fprintf('%d %d -------\n',row,col);
    end
end

%%
chdir(thisDir)

end