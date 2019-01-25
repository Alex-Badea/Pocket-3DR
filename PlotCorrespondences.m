function PlotCorrespondences( im1, im2, corrs, corrsIn, K, mode)
%PLOTCORRESPONDENCES Summary of this function goes here
%   Detailed explanation goes here
if ~exist('mode','var')
    mode = 'overlay';
end
if ~exist('K','var')
    K = eye(3);
end

x1 = Dehomogenize(K*Homogenize(corrs(1:2,:)));
x2 = Dehomogenize(K*Homogenize(corrs(3:4,:)));
x1Inliers = Dehomogenize(K*Homogenize(corrsIn(1:2,:)));
x2Inliers = Dehomogenize(K*Homogenize(corrsIn(3:4,:)));

if strcmp(mode,'overlay')
    imBlend = imfuse(im1,im2);
    figure
    imshow(imBlend), drawnow, hold on
    plot([x1(1,:); x2(1,:)], [x1(2,:); x2(2,:)], 'k', 'LineWidth', 1), drawnow
    plot(x1(1,:), x1(2,:), 'ko', 'MarkerSize', 3, 'LineWidth', 0.8), drawnow

    if exist('x1Inliers', 'var') && exist('x2Inliers', 'var')
        plot([x1Inliers(1,:); x2Inliers(1,:)], [x1Inliers(2,:); x2Inliers(2,:)], ...
            'b', 'LineWidth', 1), drawnow
        plot(x1Inliers(1,:), x1Inliers(2,:), ...
            'bo', 'MarkerSize', 3, 'LineWidth', 0.8), drawnow
    end
    hold off
elseif strcmp(mode, 'sideBySide')
    aux1 = imfuse(im1,im2);
    aux2 = im1;
    aux3 = im2;
    aux2(size(aux1,1), size(aux1,2)) = 0;
    aux3(size(aux1,1), size(aux1,2)) = 0;
    imBlend = [aux2 aux3];

    figure, imshow(imBlend), hold on
    x2(1,:) = x2(1,:) + size(im1,2);
    for i = 1:size(x1,2)
        plot([x1(1,i); x2(1,i)], [x1(2,i); x2(2,i)], ...
            'k', 'LineWidth', 0.8)
        plot(x1(1,i), x1(2,i), 'ko', 'MarkerSize', 3, 'LineWidth', 0.8)
    end
    if exist('x1Inliers', 'var') && exist('x2Inliers', 'var')
        x2Inliers(1,:) = x2Inliers(1,:) + size(im1,2);
        for i = 1:size(x1Inliers,2)
            plot([x1Inliers(1,i); x2Inliers(1,i)], ...
                [x1Inliers(2,i); x2Inliers(2,i)], 'LineWidth', 0.8, ...
                'Color', rand(1,3))
        plot(x1Inliers(1,i), x1Inliers(2,i), 'bo', ...
            'MarkerSize', 3, 'LineWidth', 0.8)
        end
    end
    hold off
end
end

