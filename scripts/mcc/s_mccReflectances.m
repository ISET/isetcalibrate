%% Compare multiple MCC stored reflectances
%
%  Conclusion is that the mini is a little bit different from the one we
%  use as a stored default
%
%  The stored default might be spatially uniform - but we aren't sure where
%  we got it from.  The was measured by us, and the light might be slightly
%  nonuniform.  The sFactor image shows that the scaling we need is pretty
%  substantial, from 0.83 to 1.27
%

%%
w = 400:10:700;
mccSurfaces = macbethChartCreate(1,[],w);
mccReflectance = RGB2XWFormat(mccSurfaces.data);
plotReflectance(w,mccReflectance);

%%
mcc1 = ieReadSpectra('macbethChart.mat',w);
mcc2 = ieReadSpectra('macbethChart-20180324.mat',w);
mcc3 = ieReadSpectra('/Users/wandell/Documents/MATLAB/LABS/WL/arriscope/data/macbethColorChecker/MiniatureMacbethChart.mat',w);

%%
ieNewGraphWin;
scatter(mcc1(:),mcc2(:)); identityLine

%%
ieNewGraphWin;
scatter(mcc1(:),mcc3(:)); identityLine

%% There is a spatial scale difference between the default and the mini

sFactor = zeros(1,24);
for ii=1:24
    ref2 = mcc2(:,ii);
    ref3 = mcc3(:,ii);
    sFactor(ii) = ref2\ref3;
end

%% Here is the scale factor as an image
ieNewGraphWin;
imagesc(reshape(sFactor,4,6))
% mesh(reshape(sFactor,4,6))

%% Now correct and compare
mcc2to3 = mcc2*diag(sFactor);

ieNewGraphWin;
scatter(mcc2to3(:),mcc3(:))
identityLine;
grid on;

%%  END
