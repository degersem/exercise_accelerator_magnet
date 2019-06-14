function prp=dealstruct(prp,prp0)

% function prp=DEALSTRUCT(prp,prp0)
% copies the fields of second structure prp0 into first structure prp
% fields unexisting in prp are newly created
%
% input parameters
%    prp            : (first) structure where fields will be copied into
%    prp0           : (second) structure from where data are taken
%
% output parameters
%    prp            : concatenated structure

if ~isempty(prp0) & isstruct(prp0)
  fld=fieldnames(prp0);
  for q=1:length(fld)
    prp.(fld{q})=prp0.(fld{q});
  end
end
