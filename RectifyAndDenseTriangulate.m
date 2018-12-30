function [CX, CColor] = RectifyAndDenseTriangulate(...
    Cim, CF, CKP, CplotFlag)
%RECTIFYANDDENSETRIANGULATE Summary of this function goes here
%   Detailed explanation goes here
if length(Cim) ~= length(CF)+1 || length(Cim) ~= length(CKP) ...
        || length(CF)+1 ~= length(CKP)
    error('Erroneous input')
end

n = length(Cim);
CX = cell(1,n-1);
CColor = cell(1,n-1);
for i = 1:n-1
    [H1, H2, im1Rec, im2Rec] = rectify(CF{i}, Cim{i}, Cim{i+1});
    im1RecPlt = im1Rec;
    im2RecPlt = im2Rec;
    im1Rec(im1Rec==0) = -1;
    im2Rec(im2Rec==0) = -9999;
    KP1Rec = H1*CKP{i};
    KP2Rec = H2*CKP{i+1};
    
    pars = [];
    pars.mu = -10.6;
    pars.window = 4;
    pars.zonegap = 4;
    pars.pm_tau = 0.99;
    pars.tau = 0.7;
    D = gcs(im1Rec, im2Rec, [], pars);
    
    if exist('CplotFlag','var') 
        if any(contains(CplotFlag, 'plotCorrespondences'))
            mc12Rec = CorrsFromDisparity(D);
            g = fix(linspace(1, size(mc12Rec,2), 1000));
            PlotCorrespondences(im1RecPlt, im2RecPlt, ...
                mc12Rec(:,g), mc12Rec(:,g))
        end
        if any(contains(CplotFlag, 'plotDisparityMap'))
            figure
            set(imagesc(D),'AlphaData',~isnan(D)), colormap(jet), colorbar
            drawnow
        end
    end
    
    figure('pos', [0 100 3000 300])
    histogram(D,1000), drawnow
    lb = ginput(1);
    ub = ginput(1);
    hold on, plot([lb(1) ub(1)], [0 0], 'rx', 'LineWidth', 2), drawnow
    hold off, close(gcf)
    D(D<lb(1) | D>ub(1)) = nan;
    mc12Rec = CorrsFromDisparity(D);
    
    CX{i} = Triangulate(KP1Rec, KP2Rec, mc12Rec(1:4,:));
    
    sz = [size(Cim{i},1) size(Cim{i},2)];
    mc1Unr = [fix(Dehomogenize(H1\Homogenize(mc12Rec(1:2,:))));
        nan(1,size(mc12Rec,2))];
    CColor{i} = bsxfun(@(x,dummy) ...
        double(permute(Cim{i}(...
        min(abs(x(2)) + double(x(2)==0), sz(1)),...
        min(abs(x(1)) + double(x(1)==0), sz(2)),...
        :),[3 2 1])), ...
        mc1Unr, 1:size(mc12Rec,2));
end
end