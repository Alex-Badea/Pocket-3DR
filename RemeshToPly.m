function RemeshToPly(plyName,X,Normals,Colors)
%REMESHTOPLY Summary of this function goes here
%   Detailed explanation goes here
MakePly('in.ply',X,Normals,Colors)
PoissonReconWrapper('in.ply', plyName, 8, feature('numcores'));
fclose('all');
delete('in.ply')
end