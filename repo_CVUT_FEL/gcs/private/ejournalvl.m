function level=ejournalvl
%
% ejournalvl
%    Returns current journal nesting level. Auxiliary function.
%
% See also: Journal
 
% (c) Radim Sara (sara@cmp.felk.cvut.cz) FEE CTU Prague, 06 Sep 00
 
 
% global ejournalstack
 global ejrnlmaxlvl
 
 st = dbstack;
 st = st(3:end);

 if isempty(st)
  ejournalstack=[];
  level = 0;
  return
 end
 caller = st(1);
 
 % change 28.5.2004 by RS: If called from a local procedure, the
 % corresponding main file is considered the caller, i.e. just the
 % first token goes to the ejournalstack
 
 ejournalstack = {};
 for i=1:length(st)
  nm = st(i).name;
  sep = find(nm==' '); % white space separates local function name
  if ~isempty(sep)
   ejournalstack{end+1} = nm(1:sep-1);
  else
   ejournalstack{end+1} = nm;
  end
%  ejournalstack{end+1} = strtok(st(i).name); % the strtok is very
                                             % slow, consumes 80% of
                                             % all time here
 end
 ejournalstack = union(ejournalstack,{});
 
 
%  ejournalstack = union(intersect(ejournalstack,{st.name}),...
% 		       {strtok(caller.name)});
 
% ejournalstack = union(intersect(ejournalstack,{st.name}), {caller.name});
 
% dead = setdiff(ejournalstack,{st.name});
% ejournalstack = union(setdiff(ejournalstack,dead),{caller.name});
 level = length(ejournalstack);

 % check if the jrnlmaxlevel is not exceeded
 if ~isempty(ejrnlmaxlvl)
  m = find(ismember({ejrnlmaxlvl.name}, ejournalstack));
  if ~isempty(m)
   if level > ejrnlmaxlvl(m).level
    level = NaN; % NaN beats Inf in the test in ejrnlprintf, etc.
   end
  end
 end

 return