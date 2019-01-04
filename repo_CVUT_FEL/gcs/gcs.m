function [D,W,x,w,K,SEEDs] = gcs(Il,Ir,inSEEDs,pars)
%GCS - stereo matching via growing correspondence seeds in disparity space
%
% [D,W,x,w,K,SEEDs] = gcs(Il,Ir,inSEEDs,pars);
%
%    Il,Ir - imput images (horizontally rectified)
%  inSEEDS - initial correspondences 
%                per row: [column_left, column_right, row] (nx3)
%                (set [], to run a simple Harris prematcher)
%     pars - parametres (structure) 
% 
%        D - disparity map
%        W - correlation map (corresponding to D)
%        x - list of all disparity space candidates 
%        w - correlation list (corresponding to x)
%        K - number of disparity candidates (corresponding to D)
%    SEEDs - initial correspondences (obtained by prematchig)
%
%
%  default parametres: pars.
%  -------------------------    
%    algorithm = 'dgrow1';    
%                   'dgrow0' - baseline (non-robust, 3x faster than dgrow1)
%                   'dgrow1' - BenCOS CVPR version (robust + fast)                         
%    tau = 0.6; threshold for correlation growing
%                (decrease to support growing, set -Inf with random seeds)
%    mu = 0.1;  correlation margin for growing [dgrow1 only]
% 
%    searchrange = [-inf,inf]; disparity search range (unlimited)
%    epsilon = 0; local ambiguity (minimal dist. 1st and 2nd corr. maxima),
%                  [dgrow0 only]
%    window = 2; half window size (2 means matching window of 5x5 pixels)
%    max_candidates = 10; maximum number of disp. candidates 
%                         (decreas to save memory or keep unlimited =Inf)
%    init_seeds_accept = 0; accept all initial seeds (turned off)
%
%    csbeta = 0.1; correlation margin for stable fusion [dgrow1 only]
%    csalgorithm = 'cXS'; stable fusion algorithm [dgrow1 only]
%                     'cXS' - confidently stable with uniqueness constraint
%                     'cFXS-fast' - confidently stable with 
%                                   uniqueness+ordering constraint
%                     'cXD' - dominant with uniqueness constraint
%    zonegap = 3; %zonegap size (the higher the denser results, if too high
%                                it may increase the errors, 
%                                zonegap=0 equivalent to GCS 1.0) 
%
%    pm_tau = 0.9;            %pre-matching correlation threshold (decreas 
%                               for more seeds)
%    pm_window = 3;           %pre-matching half window size 
%    pm_harris_prctile = 10;  %pre-matching percentile of interest points 
%                               to be kept (set 0 to keep all Harris points)
%
%% The algorithm is described in:
%     Jan Cech, Radim Sara; Efficient Sampling of Disparity Space for fast
%     and Accurate Matching; In Proc. BenCOS CVPR Workshop, 2007.
%     (also available from http://cmp.felk.cvut.cz/~cechj)
%
% Jan Cech, cechj@cmp.felk.cvut.cz, 1/9/2006
% (toolbox revised: 23/05/2007)
% (GCS 2.0 - integrated 21/01/2008)


%input checking
t = whos('Il');
if ~strcmp(t.class,'double');
    Il = double(Il);
end
t = whos('Ir');
if ~strcmp(t.class,'double');
    Ir = double(Ir);
end
if size(Il,1)~=size(Ir,1),
    error('Images do not have equal height. Horizontal rectification is required.');
end
if length(size(Il))==3, %color image -> grayscale
    Il = sum(Il,3); 
end
if length(size(Ir))==3, %color image -> grayscale
    Ir = sum(Ir,3); 
end

if ~isempty(inSEEDs) & size(inSEEDs,2)~=3,
    error('The inSEEDs array must be (nx3).');
end

% parametres setting ----------------------------------------------------

pars0 = []; %default parametres
pars0.algorithm = 'dgrow1';

if exist('pars','var')
    pars = optionmerge(pars0,pars);
else
    pars = pars0;
end

fn = fieldnames(pars); %current parametres fieldnames
main_fn = {'algorithm'};
pm_fn = {'pm_tau','pm_window','pm_keypoints','pm_harris_prctile','pm_searchrange'};
m_fn = {'window','range','tau','epsilon','growing','init_seeds_accept','seeds_accept','searchrange','searchrangeV','max_candidates','vis_step','mu','csbeta','csalgorithm','grow_version','zonegap'};

%check for unknown option
fn_unknown = setdiff(fn, [main_fn,pm_fn,m_fn]);
for i=1:length(fn_unknown),
    warning(sprintf('Unknown option "%s".',fn_unknown{i}));
end

%main parametres
main_pars = [];
main_fn_ = intersect(fn,main_fn);
for i=1:length(main_fn_);
    main_pars = setfield(main_pars,main_fn_{i},getfield(pars,main_fn_{i}));
end

%prematching parametres
pm_pars = [];
pm_fn_ = intersect(fn,pm_fn);
for i=1:length(pm_fn_);
    pm_pars = setfield(pm_pars,pm_fn_{i},getfield(pars,pm_fn_{i}));
end

%matching parametres
m_pars = [];
m_fn_ = intersect(fn,m_fn);
for i=1:length(m_fn_);
    m_pars = setfield(m_pars,m_fn_{i},getfield(pars,m_fn_{i}));
end
% end

%set prematching searchrange according to searchrange if defined
if ~isfield(pm_pars,'pm_searchrange') & isfield(m_pars,'searchrange')
    pm_pars.pm_searchrange = m_pars.searchrange;
end


% ------------------------------------------------------------------

%prematching

if isempty(inSEEDs),
    t=cputime;
    fprintf('Prematching...');
    [SEEDs] = prematching(Il,Ir,pm_pars);
    disp(sprintf('Done. (%g s)',cputime-t));
else
    %SEEDs = [xl,xr,yl,yr];
    %if ~strcmp(main_pars.algorithm,'dgrow4') 
    %    inSEEDs = inSEEDs(:,1:3);
    %end
    
    %multiplicity in seeds must be removed
    SEEDs = unique(inSEEDs,'rows'); 
    %range checking
    if isfield(m_pars,'window')
        w = m_pars.window;
    else
        w = 2;
    end
    [r,c]=find(SEEDs < w+1); 
    SEEDs(r,:)=[];
    r=find(SEEDs(:,1) > size(Il,2) - (w+1));
    SEEDs(r,:)=[];
    r=find(SEEDs(:,2) > size(Ir,2) - (w+1));
    SEEDs(r,:)=[];
    r=find(SEEDs(:,3) > size(Il,1) - (w+1));
    SEEDs(r,:)=[];
    if size(SEEDs,2) == 4,
        r=find(SEEDs(:,4) > size(Ir,1) - (w+1));
        SEEDs(r,:)=[];
    end
end

% ------------------------------------------------------------------

%matching

t = cputime;
fprintf('Matching (%s)...',main_pars.algorithm);
if strcmp(main_pars.algorithm,'dgrow0'),
    [D,W] = dgrow0(Il,Ir,SEEDs,m_pars);
    x = []; w = []; K = [];
elseif strcmp(main_pars.algorithm,'dgrow1'), 
    m_pars.algorithm = main_pars.algorithm;
    [D,W,x,w,K] = dgrow1(Il,Ir,SEEDs,m_pars);
else
    error('Unknown algorithm');
end
disp(sprintf('Done. (%g s)',cputime-t));

% ------------------------------------------------------------------
