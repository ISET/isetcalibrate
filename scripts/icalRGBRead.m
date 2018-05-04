%% icalRGBRead
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

%%