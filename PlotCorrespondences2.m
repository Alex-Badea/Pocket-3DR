function PlotCorrespondences2( im1, im2, x1, x2, x1Inliers, x2Inliers )
%PLOTCORRESPONDENCES Summary of this function goes here
%   Detailed explanation goes here
aux = imfuse(im1,im2);
aux2 = im1;
aux3 = im2;
aux2(size(aux,1), size(aux,2)) = 0;
aux3(size(aux,1), size(aux,2)) = 0;
imBlend = [aux2 aux3];

figure, imshow(imBlend), hold on
x2(1,:) = x2(1,:) + size(im1,2);
for i = 1:size(x1,2)
    plot([x1(1,i); x2(1,i)], [x1(2,i); x2(2,i)], 'k', 'LineWidth', 0.8,'Color',rand(1,3))
    plot(x1(1,i), x1(2,i), 'ko', 'MarkerSize', 3, 'LineWidth', 0.8)
end
if exist('x1Inliers', 'var') && exist('x2Inliers', 'var')
    x2Inliers(1,:) = x2Inliers(1,:) + size(im1,2);
    plot([x1Inliers(1,:); x2Inliers(1,:)], [x1Inliers(2,:); x2Inliers(2,:)], 'b', 'LineWidth', 0.8,'Color',rand(1,3))
    plot(x1Inliers(1,:), x1Inliers(2,:), 'bo', 'MarkerSize', 3, 'LineWidth')
end
hold off
end

