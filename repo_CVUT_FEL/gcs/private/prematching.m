function [SEEDs] = prematching(Il,Ir,pars);
%prematching - fast sparse matching of interest point on rectified images
%
% [SEEDs] = prematching(Il,Ir);
%
%   Il,Ir - input rectified images
%   SEEDs - prematched seeds
%

%default parametres
pars0.pm_tau = 0.9;         %pre-matching correlation threshold
pars0.pm_window = 3;           %half window size 
pars0.pm_keypoints = 'harris'; %harris/foerstner keypoints
pars0.pm_harris_prctile = 10;  %percentile of interest points to be kept
pars0.pm_searchrange = [-inf,inf]; %disparity searchrange

if exist('pars','var'),
    optioncheck(pars0,pars);
    pars = optionmerge(pars0,pars);
else
    pars = pars0;
end

c_thr = pars.pm_tau;
w = pars.pm_window;
p = pars.pm_harris_prctile;
keypoints = pars.pm_keypoints;
searchrange = pars.pm_searchrange;

if strcmp(keypoints,'harris'),
    F = harris(Il); F(F==0)=NaN; 
    G = harris(Ir); G(G==0)=NaN;
    
    p_thr = prctile(F(~isnan(F)),p);
    
    F(F<p_thr) = NaN;
    G(G<p_thr) = NaN;
elseif strcmp(keypoints,'foerstner'),
    f = round(foerstner(Il));
    g = round(foerstner(Ir));
    
    F = repmat(NaN, size(Il));
    G = repmat(NaN, size(Ir));
    
    F(sub2ind(size(F),f(1,:),f(2,:))) = 1;
    G(sub2ind(size(G),g(1,:),g(2,:))) = 1;
    
else
    error('Unknown keypoints');
end


F = cutoff(F,2*[w,w]+1); F = border(F,2*[w,w]+1,NaN);
G = cutoff(G,2*[w,w]+1); G = border(G,2*[w,w]+1,NaN);



%precomputed local characteristics
a = (2*w+1)^2;
sL = conv2(Il,ones(2*w+1),'same')/sqrt(a);
sR = conv2(Ir,ones(2*w+1),'same')/sqrt(a);
vL = conv2(Il.^2,ones(2*w+1),'same') - sL.^2;
vR = conv2(Ir.^2,ones(2*w+1),'same') - sR.^2;

[X,W]=prematch_mex(Il,Ir,sL,sR,vL,vR,F,G,w,c_thr,searchrange);
SEEDs = [X(:,2),X(:,2)-X(:,3),X(:,1)];
%D = seeds2dmap(SEEDs,size(Il));


%prematching by strict CSM (very inefficient)
%D = repmat(NaN,size(Il));
% Z = zeros(size(Il,2),size(Ir,2));
% for row=1:size(Il,1),
%     C = repmat(NaN, size(Il,2),size(Ir,2));
%     f = F(row,:);
%     g = G(row,:);
%     i = find(~isnan(f));
%     j = find(~isnan(g));
%     [u,v] = meshgrid(i,j);
%     u = u(:);
%     v = v(:);
%     for l=1:length(u);
%         %C(u(l),v(l)) = -(f(u(l))-g(v(l)))^2; %harris descriptor only
%         c = wcorr(Il,Ir,u(l),row,v(l),row,w,'MNCC');
%         if c>c_thr, 
%             C(u(l),v(l)) = c;                        
%         end
%     end
%     M = smatching(C,Z,'simple','algorithm','cfxs-fast');
%     for l=1:size(M,2),
%         xl = M(1,l);
%         xr = M(2,l);
%         D(row,xl) = xl-xr;
%     end
% end


%-----stable fusion 
%        excluded 27.10.2006 (conflict is unlikely to happen and if so,
%        does not metter)

%D = sfusion(X',W',Il,Ir,'Reweight','off');
%%D = xyd2dmap(X,size(Il));

%conversion to SEEDs array
%[row,xl]=find(~isnan(D));
%dd = D(sub2ind(size(D),row,xl));
%SEEDs = [xl,xl-dd,row];
