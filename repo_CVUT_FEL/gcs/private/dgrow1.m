function [D,W,x,w,K]=dgrow1(Il,Ir,SEEDs,pars)
%dgrow3 - disparity map growing from seed matches (with overgrowing)
% 
% [D,W] = dgrow(Il,Ir,SEEDs,pars);
%
%   Il,Ir...input images (rectified)
%   SEEDs...initial correspondences [xl,xr,row] (nx3 vector)
%   pars....(see dgmatching)
%
%   D...disparity map
%   W...correlation map
%

pars = rmfield(pars,'algorithm');

t=cputime;

pars0 = []; %default parametres
pars0.window = 2; %half window size
pars0.range = 1; %local disparity searchrange [+r,-r]
pars0.tau = 0.6; %threshold for correlation growing
pars0.searchrange = [-inf,inf]; %disparity searchrange
pars0.max_candidates = 10; %maximum number of canidates per disparity 
pars0.growing = 'best-first'; %growing process (best-first, normal)
pars0.csbeta = 0.1; %beta for CSM-fusion
pars0.csalgorithm = 'cXS'; %beta for CSM-fusion
pars0.mu = 0.1;
pars0.grow_version = 5; %version of growing procedure (1-normal,2-fast,3,4,5-fully symmetric)
pars0.init_seeds_accept = 0; %accept all initial seeds (if not, it checks the correlation above threshold)
pars0.zonegap = 3; %zonegap size

if exist('pars','var'),
    optioncheck(pars0,pars);
    pars = optionmerge(pars0,pars);
else
    pars = pars0;
end

w = pars.window;
range = pars.range;
c_thr = max(-1,pars.tau);
searchrange = pars.searchrange;
max_candidates = pars.max_candidates;
beta = pars.mu;
grow_version = pars.grow_version;
init_seeds_accept = pars.init_seeds_accept;

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

[x,w,K]=dgrow3b_bf_mex(Il,Ir,sL,sR,vL,vR,SEEDs,w,range,c_thr,searchrange,max_candidates, ...
    beta,grow_version,init_seeds_accept);

%sfusion ------------------------------------------------------
ts = cputime;

%if 0; %old version
% %[D,W]=sfusion(x',w',Il,Ir,'Reweight','off');
% [D,W]=sfusion2(x',w',pars.csbeta*abs(w'),Il,Ir,'algorithm',pars.csalgorithm);
%end

%new fusion
if ~issorted(x(:,1))
 error 'array x must be sorted in x(:,1)';
end

M = smatchingl(...
  [x(:,2), x(:,2)-x(:,3), x(:,1), w, pars.csbeta*abs(w)]',...
  'problemsize',[size(Il,2),size(Ir,2)],...
  'zonegap', pars.zonegap);

wM = w(M);
wM(wM<0) = 0;  % remove matches with negative correlation (usu not needed)
subs = sub2ind(size(Il),x(M,1),x(M,2));
D = accumarray(subs, -x(M,3).*wM, [numel(Il),1]);
A = accumarray(subs, wM, [numel(Il),1]);
W = accumarray(subs, wM, [numel(Il),1], @max);
D = -reshape(sdiv(D,A,NaN), size(Il));
W = reshape(W,size(Il));

fprintf('[smatching: %g%%] ',(cputime-ts)/(cputime-t)*100);
