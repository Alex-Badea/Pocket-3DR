function [A] = BlockReshape(A, blockLinesNo)
% https://stackoverflow.com/a/40508999
A = reshape(permute(reshape(A,size(A,1),size(A,2)/blockLinesNo,[]),[1,3,2]), ...
    [], size(A,2)/blockLinesNo);
end

