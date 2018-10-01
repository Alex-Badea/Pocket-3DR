function h = point(x,varargin)
% 
%  h = POINT(X) plots a point set, returns a handle to a line object.
%       X - matrix of points, one per column

% (c) Radim Sara, GRASP U of Penn, September 5, 1997

 if size(x,1) == 2
  hh = line(x(1,:), x(2,:), 'linestyle', 'none', 'marker', '.', varargin{:});
elseif size(x,1) == 3
  hh = line(x(1,:), x(2,:), x(3,:),...
	    'linestyle', 'none', 'marker', '.', varargin{:});
else
 error 'Support 2D or 3D points only'
end

if nargout>0
 h = hh;
end

 
return
 

% function h = point_old(x, opt1, opt2, opt3, opt4, opt5, opt6)
% %
% %  h = POINT(X) plots a point set, returns a handle to a line object.
% %
% %       X - matrix of points, one per column
% 
% % Language: Matlab 5.2, Matlab 4 compliant
% % (c) Radim Sara, GRASP U of Penn, September 5, 1997
% 
% %figure(gcf) % to pop it up
% 
% if size(x,1) == 2
%  if matlabver(1) < 5
%   hh = line(x(1,:), x(2,:), 'linestyle', '.');
%  else
%   hh = line(x(1,:), x(2,:), 'linestyle', 'none', 'marker', '.',...
%   'markersize', 1);
%  end
% elseif size(x,1) == 3
%  if matlabver(1) < 5
%   hh = line(x(1,:), x(2,:), x(3,:), 'linestyle', '.');
%  else
%   hh = line(x(1,:), x(2,:), x(3,:), 'linestyle', 'none', 'marker', '.',...
%   'markersize', 1);
%  end
% else
%  error 'Support 2D or 3D points only'
% end
% 
% % set the parameters
% if nargin > 1
%  set(hh, opt1, opt2);
% end
% if nargin > 3
%  set(hh, opt3, opt4);
% end 
% if nargin > 5
%  set(hh, opt5, opt6)
% end 
% 
% if nargout>0
%  h = hh;
% end
