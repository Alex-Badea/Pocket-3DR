function [CX, CColor] = RectifyAndDenseTriangulate(...
    K, Cim, CF, CP, CplotFlag)
%RECTIFYANDDENSETRIANGULATE Summary of this function goes here
%   Detailed explanation goes here
if length(Cim) ~= length(CF)+1 || length(Cim) ~= length(CP) ...
        || length(CF)+1 ~= length(CP)
    error('Erroneous input')
end

n = length(Cim);
CX = cell(1,n-1);
CColor = cell(1,n-1);
for i = 1:n-1
    [H1, H2, im1Rec, im2Rec] = rectify(CF{i}, Cim{i}, Cim{i+1});
    im1Rec(im1Rec==0) = -1;
    KP1Rec = H1*K*CP{i};
    KP2Rec = H2*K*CP{i+1};
    
    pars = [];
    pars.mu = -10.6;
    pars.window = 4;
    pars.zonegap = 10;
    pars.pm_tau = 0.95;
    D = gcs(im1Rec, im2Rec, [], pars);
    figure('pos', [0 100 2600 300])
    histogram(D,100), drawnow
    lb = ginput(1);
    ub = ginput(1);
    hold on, plot([lb(1) ub(1)], [0 0], 'rx', 'LineWidth', 2), drawnow
    hold off
    D(D<lb(1) | D>ub(1)) = nan;
    mc12Rec = MatchesFromDisparity(D);
    
    if exist('CplotFlag','var') 
        if any(contains(CplotFlag, 'plotCorrespondences'))
            g = fix(linspace(1, size(mc12Rec,2), 1000));
            PlotCorrespondences(im1Rec, im2Rec, ...
                mc12Rec(1:2,g), mc12Rec(3:4,g))
        end
        if any(contains(CplotFlag, 'plotDisparityMap'))
            figure
            set(imagesc(D),'AlphaData',~isnan(D)), colormap(jet), colorbar
            drawnow
        end
    end
    
    CX{i} = LinearTriangulation(KP1Rec, KP2Rec, ...
        mc12Rec(1:2,:), mc12Rec(3:4,:));
    
    mc1Unr = [fix(Dehomogenize(H1\Homogenize(mc12Rec(1:2,:))));
        nan(1,size(mc12Rec,2))];
    CColor{i} = bsxfun(@(x,dummy) ...
        double(permute(Cim{i}(x(2),x(1),:),[3 2 1])), ...
        mc1Unr, 1:size(mc12Rec,2));
end
end