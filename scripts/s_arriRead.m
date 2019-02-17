%% Testing ARRISCOPE read routines
%

chdir(fullfile(icalRootPath,'local','arri'));
[R,G,B,RGB,Raw] = arriRead('blue_cameraImage_6.ari');
ieNewGraphWin;
imagesc(B); colorbar;

%% Our guess about the relationship between the TIFF and the left image

chdir(fullfile(icalRootPath,'local','tiff'));
img = imread('blue_cameraImage_6.tif');
BTif = img(:,:,3);

BTifR = imrotate(BTif, -90);
% BTifRF = fliplr(BTifR);

ieNewGraphWin;
imagesc(BTifR); colormap(gray);
axis image


%% Split the RGB into two parts
[rows,cols,~] = size(RGB);
left = RGB(:,1:cols/2,:);
sCol = (cols/2 - 1080)/2
sRow = (rows/2 
ieNewGraphWin; 
imagesc(left(84:end,:,3)); colormap(gray); axis image

% left = left(1:1920,1:1080,:);
%%
right = RGB(:,(cols/2 + 1):end,:);

vcNewGraphWin;
% imagescRGB(left)
% imagescRGB(right)
imagescRGB(RGB)

%% Try downloading a file from 
vcNewGraphWin;
mesh(squeeze(left(:,:,3)))

%%
