%% icalRGBRead
%
%

%%
chdir(fullfile(icalRootPath,'local'));
dRGB = load('rgb_values.mat');

rgb = dRGB.RGB_mean_values';
levels = dRGB.values;

%%

idx = logical( ((levels(:,2) == 0) .* (levels(:,3) == 0)) .* (levels(:,1) == 0));
blackRGB = mean(rgb(:,idx),2);


%%

idx = logical( ((levels(:,2) == 0) .* (levels(:,3) == 0)) .* (levels(:,1) > 0));
redRGB = rgb(:,idx);
redRGB = redRGB - blackRGB;
vcNewGraphWin;
plot3(redRGB(1,:),redRGB(2,:),redRGB(3,:),'o-');
grid on
axis equal

rWeights = mean(diag( 1./ redRGB(:,end)) * redRGB)';
plot(redWeights,rWeights,'o');
axis equal; identityLine; grid on;
%%
idx = logical( ((levels(:,1) == 0) .* (levels(:,3) == 0)) .* (levels(:,2) > 0));
greenRGB = rgb(:,idx);
greenRGB = greenRGB - blackRGB;
vcNewGraphWin;
plot3(greenRGB(1,:),greenRGB(2,:),greenRGB(3,:),'o-');
grid on
axis equal

gWeights = mean(diag( 1./ greenRGB(:,end)) * greenRGB)';
plot(greenWeights,bWeights,'o');
axis equal; identityLine; grid on;
%% Blue RGB values
idx = logical( ((levels(:,1) == 0) .* (levels(:,2) == 0)) .* (levels(:,3) > 0));
blueRGB = rgb(:,idx);            % Raw RGB values
blueRGB = blueRGB - blackRGB;    % Remove the black level

% These should be a straight line
vcNewGraphWin;
plot3(blueRGB(1,:),blueRGB(2,:),blueRGB(3,:),'o-');
grid on

% These should be scaled the same way as the SPD intensities
bWeights = mean(diag( 1./ blueRGB(:,end)) * blueRGB)';
plot(blueWeights,bWeights,'o');
axis equal; identityLine; grid on;

%% Check the whiteRGB

idx = logical( ((levels(:,1) == 1) .* (levels(:,2) == 1)) .* (levels(:,3) == 1));
whiteRGB = rgb(:,idx);
whiteRGB = whiteRGB - blackRGB;
vcNewGraphWin;
redRGB(:,end) + greenRGB(:,end) + blueRGB(:,end)
whiteRGB 

%%
