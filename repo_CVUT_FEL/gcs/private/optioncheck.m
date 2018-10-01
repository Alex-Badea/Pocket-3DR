function optioncheck(varargin);
%
% optioncheck(o1,o2,...)
%
%   Checks whether the option names in the 2nd and further
%   arguments are compatible to the first argument. If an 
%   unknown option is found, a warning is issued.
%
% See also: Options
%

% Jan Cech, 15/08/2006, cechj@cmp.felk.cvut.cz

if isempty(varargin{2}),
    return;
end

for i=1:length(varargin),
    if ~isstruct(varargin{i}), error 'Parameter set is not a structure';  end
end

fn0 = fieldnames(varargin{1});

for j=2:length(varargin),
    cfn = fieldnames(varargin{j});
    for i=1:length(cfn),
        if ~any(strcmp(cfn(i),fn0)),
            warning(sprintf('Unknown option "%s"',cfn{i}));
        end
    end
end