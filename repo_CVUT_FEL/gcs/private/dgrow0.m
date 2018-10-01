function [D,W,Dr]=dgrow0(Il,Ir,SEEDs,pars)
%%dgrow - disparity map growing from seed matches
% 
% [D,W] = dgrow0(Il,Ir,SEEDs,pars);
%
%   Il,Ir...input images (rectified)
%   SEEDs...initial correspondences [xl,xr,row] (nx3 vector)
%   pars....
%
%   D...disparity map
%   W...correlation map
%

t= cputime;

pars0 = []; %default parametres
pars0.window = 2; %half window size
pars0.range = 1; %local disparity searchrange [+r,-r]
pars0.tau = 0.6; %threshold for correlation growing
pars0.epsilon = 0; %local ambiguity (minimal distance of 1st and 2nd corr. maxima)
pars0.searchrange = [-inf,inf]; %disparity searchrange (unlimited)
pars0.vis_step = inf; %number of steps to display current disparity map
pars0.growing = 'best-first'; %growing process (best-first, normal)
pars0.init_seeds_accept = 0; %accept all initial seeds (turned off)
pars0.seeds_accept = 1; %accept all seeds (turned on)
pars0.grow_version = 5; %1..standard, 5...symmetric neighbourhood

if exist('pars','var'),
    optioncheck(pars0,pars);
    pars = optionmerge(pars0,pars);
else
    pars = pars0;
end

w = pars.window;
range = pars.range;
c_thr = max(-1,pars.tau);
epsilon = pars.epsilon;
vis_step = pars.vis_step;
searchrange = pars.searchrange;
i_seed_accept = pars.init_seeds_accept;
seed_accept = pars.seeds_accept;
grow_version = pars.grow_version;

a = (2*w+1)^2;

%precomputed local characteristics

sL = conv2(Il,ones(2*w+1),'same')/sqrt(a);
sR = conv2(Ir,ones(2*w+1),'same')/sqrt(a);

vL = conv2(Il.^2,ones(2*w+1),'same') - sL.^2;
vR = conv2(Ir.^2,ones(2*w+1),'same') - sR.^2;

%
% c = MNCC(xl,xr,row) 
%
% c = 2*( sLR(xl,xr,row) - sL(row,xl)*sR(row,xr) ) / ( vL(row,xl) + vR(row,xr) )
% var Il(row,xl) = vL/a   %variance normalized by n, not (n-1)
%

switch lower(pars.growing)
    case {'normal','n'}
        [D,W,Dr]=dgrow0_mex(Il,Ir,sL,sR,vL,vR,SEEDs,w,range,c_thr,vis_step,searchrange,epsilon);
    case {'best-first','bf'}
        [D,W,Dr]=dgrow0_bf_mex(Il,Ir,sL,sR,vL,vR,SEEDs,w,range,c_thr,vis_step,searchrange,epsilon, ...
                            i_seed_accept,seed_accept,grow_version);
    otherwise
        error('Unknown growing mode.');
end

