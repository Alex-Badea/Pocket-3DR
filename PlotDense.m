function PlotDense(X,C)
%PLOTDENSE Summary of this function goes here
%   Detailed explanation goes here
figure, pcshow(X', C'/max(max(C)))
end

