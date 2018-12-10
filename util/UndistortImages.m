function [Cim] = UndistortImages(Cim,K,d)
%UNDISTORTIMAGES Summary of this function goes here
%   Detailed explanation goes here
s = size(Cim{1});
for i = 2:length(Cim)
    if ~isequal(size(Cim{i}), s)
        error('Inconsistent sizes')
    end
end

c = cameraIntrinsics([K(1,1) K(2,2)], [K(1,3) K(2,3)], [s(1) s(2)],...
    'RadialDistortion', d);
for i = 1:length(Cim)
    Cim{i} = undistortImage(Cim{i}, c, 'OutputView', 'same');
end
end