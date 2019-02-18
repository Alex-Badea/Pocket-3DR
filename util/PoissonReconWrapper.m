function PoissonReconWrapper(in,out,depth,threads)
%POISSONRECONWRAPPER Summary of this function goes here
%   Detailed explanation goes here
exec = 'repo_external\PoissonRecon\PoissonRecon';
eval(['!' exec ' --verbose --ascii --normals --colors '...
    '--depth ' num2str(depth)...
    ' --in ' in ' --out ' out ' --threads ' num2str(threads)])
end