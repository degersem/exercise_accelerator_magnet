function prp=xa_repprop(prp,sz)

% function prp=xa_REPPROP(prp,sz)
% check the number of properties given in the fields of prp
% and extends single properties to sz properties when necessary
%
% input parameters
%    prp               : structure with properties
%    sz                : number of properties needed in each field
%
% output parameters
%    prp               : structure with properties

fld=fieldnames(prp);
for q=1:length(fld)
  gv=prp.(fld{q});
  if ischar(gv)
    prp.(fld{q})=cell(sz,1);
    [prp.(fld{q}){:}]=deal(gv);
  elseif iscell(gv)
    switch length(gv)
      case 1
        prp.(fld{q})=cell(sz,1);
        [prp.(fld{q}){:}]=gv{1};
      case sz
      otherwise
        error('wrong size of cell array');
    end
  elseif isnumeric(gv)
    switch length(gv)
      case 1
        prp.(fld{q})=ones(sz,1)*gv;
      case sz
      otherwise
        error('wrong size of numeric array');
    end
  else
    error('untreated type');
  end
end
