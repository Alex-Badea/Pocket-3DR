function [CFilteredX,CFilteredColors] = ReconstructPointCloud(...
    plyName,CScreenedX,CScreenedColors)
%REMESH Summary of this function goes here
%   Detailed explanation goes here
[CFilteredX,CFilteredColors] = psr(CScreenedX,CScreenedColors);
%movefile('psr_out.ply',plyName)
%delete psr_in.ply
end

