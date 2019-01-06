function [Cim] = ResizeImages(Cim,resolution)
%RESIZEIMAGES Summary of this function goes here
%   Detailed explanation goes here
r = resolution(1)/resolution(2);
s = size(Cim{1});
for i = 2:length(Cim)
    if ~isequal(size(Cim{i}), s)
        error('Inconsistent sizes')
    end
end
if r ~= s(2)/s(1)
    error('Inconsistent ratio')
end
if any(s(1) < resolution(2) || s(2) < resolution(1))
    error('Cannot resize to higher resolution')
end

for i = 1:length(Cim)
    Cim{i} = imresize(Cim{i},flip(resolution));
end
end

