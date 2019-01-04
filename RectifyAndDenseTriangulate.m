function [X,Colors,ScreenedX,ScreenedColors,Disparity] =...
    RectifyAndDenseTriangulate(im1,im2,F,KP1,KP2,CplotFlag)
%RECTIFYANDDENSETRIANGULATE Summary of this function goes here
%   Detailed explanation goes here

[H1, H2, im1Rec, im2Rec] = rectify(F,im1,im2);
im1RecPlt = im1Rec;
im2RecPlt = im2Rec;
im1Rec(im1Rec==0) = -1;
im2Rec(im2Rec==0) = -9999;
KP1Rec = H1*KP1;
KP2Rec = H2*KP2;

pars = [];
pars.mu = -10.6;
pars.window = 4;
pars.zonegap = 4;
pars.pm_tau = 0.99;
pars.tau = 0.7;
Disparity = gcs(im1Rec, im2Rec, [], pars);

if exist('CplotFlag','var')
    if any(contains(CplotFlag, 'plotCorrespondences'))
        mc12Rec = CorrsFromDisparity(Disparity);
        g = fix(linspace(1, size(mc12Rec,2), 1000));
        PlotCorrespondences(im1RecPlt, im2RecPlt, ...
            mc12Rec(:,g), mc12Rec(:,g))
        drawnow
    end
    if any(contains(CplotFlag, 'plotDisparityMap'))
        figure
        set(imagesc(Disparity),'AlphaData',~isnan(Disparity)), colormap(jet)
        colorbar,drawnow
    end
end

h = figure('pos', [0 100 getfield(get(0,'screensize'),{3}) 300]);
set(0,'CurrentFigure',h)
histogram(Disparity,1000), drawnow
pause(1)
lb = ginput(1);
ub = ginput(1);
hold on, plot([lb(1) ub(1)], [0 0], 'rx', 'LineWidth', 2), drawnow
hold off, close(gcf)
Disparity(Disparity<lb(1) | Disparity>ub(1)) = nan;
mc12Rec = CorrsFromDisparity(Disparity);

X = Triangulate(KP1Rec, KP2Rec, mc12Rec(1:4,:));

sz = [size(im1,1) size(im1,2)];
mc1Unr = [fix(Dehomogenize(H1\Homogenize(mc12Rec(1:2,:))));
    nan(1,size(mc12Rec,2))];
Colors = bsxfun(@(x,dummy) ...
    double(permute(im1(...
    min(abs(x(2)) + double(x(2)==0), sz(1)),...
    min(abs(x(1)) + double(x(1)==0), sz(2)),...
    :),[3 2 1])), ...
    mc1Unr, 1:size(mc12Rec,2));

ScreenedX1 = nan(size(Disparity));
ScreenedX1(~isnan(Disparity)) = X(1,:);
ScreenedX2 = nan(size(Disparity));
ScreenedX2(~isnan(Disparity)) = X(2,:);
ScreenedX3 = nan(size(Disparity));
ScreenedX3(~isnan(Disparity)) = X(3,:);
ScreenedX(:,:,1) = ScreenedX1;
ScreenedX(:,:,2) = ScreenedX2;
ScreenedX(:,:,3) = ScreenedX3;

ScreenedColors1 = nan(size(Disparity));
ScreenedColors1(~isnan(Disparity)) = Colors(1,:);
ScreenedColors2 = nan(size(Disparity));
ScreenedColors2(~isnan(Disparity)) = Colors(2,:);
ScreenedColors3 = nan(size(Disparity));
ScreenedColors3(~isnan(Disparity)) = Colors(3,:);
ScreenedColors(:,:,1) = ScreenedColors1;
ScreenedColors(:,:,2) = ScreenedColors2;
ScreenedColors(:,:,3) = ScreenedColors3;
end