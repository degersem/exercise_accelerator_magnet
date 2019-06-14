function idxdof = bdrycond_idxdof(bdrycond,numunknown)
% function idxdof = bdrycond_idxdof(bdrycond,numunknown)
%   determines the indices of the degrees of freedom
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    numunknown         : [#]   : number of unknowns in the formulation
%
% Outputs
%    idxdof             : [@]   : indices of the degrees of freedom (optional; default: [])
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

idxdof=[1:numunknown]';                                                    %       : indices of the degrees of freedom
for bd=1:length(bdrycond)
  switch bdrycond(bd).type
    case 'sibc'
      % keep all degrees of freedom
    case 'dummy'
    otherwise
      idxdof=setdiff(idxdof,bdrycond(bd).idx(:,1));
  end
end

end
