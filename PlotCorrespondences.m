function PlotCorrespondences( im1, im2, x1, x2, x1Inliers, x2Inliers )
%PLOTCORRESPONDENCES Summary of this function goes here
%   Detailed explanation goes here

imBlend = im1./2 + im2./2;

figure, imshow(imBlend), hold on
plot([x1(1,:); x2(1,:)], [x1(2,:); x2(2,:)], 'k', 'LineWidth', 1.5)
plot(x1(1,:), x1(2,:), 'ko', 'MarkerSize', 3, 'LineWidth', 1.5)

if exist('x1Inliers', 'var') && exist('x2Inliers', 'var')
    plot([x1Inliers(1,:); x2Inliers(1,:)], [x1Inliers(2,:); x2Inliers(2,:)], 'b', 'LineWidth', 1.5)
    plot(x1Inliers(1,:), x1Inliers(2,:), 'bo', 'MarkerSize', 3, 'LineWidth', 1.5)
end
hold off
end

