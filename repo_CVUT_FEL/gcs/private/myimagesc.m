function h = myimagesc(x,y,a,clim)
%
% h = myimagesc(im)
%      Extended imagesc
%      all NaN, Inf values in im are displayed with
%      index to colormap equal to 0 in Matlab4.
%      Identical to imagesc in Matlab5
%
% See also: IMAGESC

% (c) Radim Sara, GRASP UPenn, Dec. 7, 1996
% Modified for Matlab 5, Mar 31, 1998

ver = version;
ver = eval(ver(1));

cm = colormap;
m = size(cm,1);

if ver < 5
 replaceNaNs = 1;
else
  replaceNaNs = 0;
end

if ver >= 5

 if nargin == 1
  sz = size(x);
  if length(sz)==3
   % reshape if possible
   if sz(1) == 1
    x = reshape(x,sz(2:3));
   end
   if sz(2) == 1
    x = reshape(x,sz([1 3]));
   end
  end
  if ndims(x) == 3 && strcmp(class(x),'double')
   x = sdiv(x,max(x(:)),NaN); % normalize to unity
  end
  hh = imagesc(x);
 end
 if nargin == 3
  hh = imagesc(x,y,a); 
 end
 if nargin == 4
  hh = imagesc(x,y,a,clim);  
 end
 
 if nargout > 0
  h = hh;
 end
 return 
end

if nargin <= 2
   a = x;
end
if rem(nargin,2)
   aa = a(:);
   amin = min(aa(finite(aa)));
   amax = max(aa(finite(aa)));
elseif nargin == 4
   amin = clim(1);
   amax = clim(2);
elseif nargin == 2
   amin = y(1);
   amax = y(2);
end

if ver >= 5
 if ndims(a) == 3
  idx = (a-amin)/(amax-amin);
 else
  idx = nan2x(min(m,round((m-1)*(a-amin)/(amax-amin))+1), 0);
 end
else
 idx = nan2x(min(m,round((m-1)*(a-amin)/(amax-amin))+1), 0);
end

if replaceNaNs
 idx = nan2x(idx,0);
end

if nargin <= 2
 hh = image(idx);
else
 hh = image(x,y,idx);
end

if any(~finite(a(:)))
 % modify the colormap
 clr = get(gca,'color');
 if isstr(clr)
  clr = get(gcf,'color');
 end
 cm(1,:) = clr(1:3);
end
colormap(cm);


set(hh,'UserData',full([amin amax]));
if nargout > 0
   h = hh;
end
