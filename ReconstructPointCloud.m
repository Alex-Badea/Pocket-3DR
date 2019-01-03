function ReconstructPointCloud(CScreenedX,plyName)
%REMESH Summary of this function goes here
%   Detailed explanation goes here
psr(ScreenedX)
movefile('psr.ply',plyName)
delete psr.npts
end

