function o = optionmerge(varargin)
%
% o = optionmerge(o1,o2,...)
%
%    Merges option sets into one. Each option set is a structure with
%    named fields. The merge is again such a structure. If the same
%    parameter is set multiple times the last occurence counts. Since
%    each function must recognize its own parameters and disregard the
%    others it is a good practice to prepend a function identifier to
%    each parameter separated by an underscore (_).
%
% See also: Options

% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 24 Jan 03

 o = varargin{1};
 if ~isstruct(o); error 'Parameter set is not a structure'; end
 
 for i = 2:length(varargin)
  oi = varargin{i};
  if ~isempty(oi)
   if ~isstruct(oi); error 'Parameter set is not a structure'; end
 
   for fld = fieldnames(oi)'
    o = setfield(o,fld{1},getfield(oi,fld{1}));
   end
  end
 end

return
 