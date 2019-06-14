function g2 = bdrycond_applyPt(bdrycond,g1,bd)
% function g2 = bdrycond_applyPt(bdrycond,g1,bd)
%   applies boundary conditions for the co-normal derivative this corresponds to g2=P'*g1 where P' is a boundary-condition projector
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    g1                 : [A]   : unconstrained righthandside vector
%    [bd]               : [@]   : identifiers for which the projector should be applied (optional; default: all)
%
% Outputs
%    g2                 : [A]   : constrained and shrinked righthandside vector
%
% Note
%    "unary" boundary conditions are assigned to nodes (e.g. Dirichlet/Neumann/Robin boundary conditions
%    "binary" boundary conditions connect nodes (e.g. (anti-)periodic boundary conditions and air-gap interface conditions
%    be aware of the fact that the order of applying the boundary/interface conditions should be respected the projectors implementing the boundary conditions do not commute!
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Initialisation
if nargin<3
  bd=1:length(bdrycond);
end
g2=g1;

% B. (First!) Binary interface/boundary conditions
for q=1:length(bd)
  switch bdrycond(bd(q)).type
    case 'dirichlet'
    case 'sibc'
    case 'robin'
    case 'airgap'
    case {'periodic','antiperiodic'}
      X=bdrycond(bd(q)).X;
      idxslv=bdrycond(bd(q)).idx(:,1);
      idxmst=bdrycond(bd(q)).idx(:,2);
      g2(idxmst,:)=g2(idxmst,:)+X'*g2(idxslv,:);
    otherwise
      error('Unknown boundary condition %s\n',bdrycond(bd(q)).type);
  end
end

% C. (Secondly!) Air-gap interface conditions
for q=1:length(bd)
  if strcmp(bdrycond(bd(q)).type,'airgap')
    X=bdrycond(bd(q)).airgap.R;
    idxslv=bdrycond(bd(q)).idx(:,1);
    idxmst=bdrycond(bd(q)).idx(:,2);
    g2(idxmst,:)=g2(idxmst,:)+X'*g2(idxslv,:);
  end
end

% D. (Thirdly!) Unary boundary conditions
for q=1:length(bd)
  switch bdrycond(bd(q)).type
    case 'dirichlet'
      %g2=g2-Abcs(:,prb.bdrycond(bd(q)).idxnode)*prb.bdrycond(bd(q)).data;   % [A]    : load vector after inserting of the boundary excitations
    case 'sibc'
    case 'robin'
    case 'airgap'
    case {'periodic','antiperiodic'}
    otherwise
      error('Unknown boundary condition %s\n',bdrycond(bd(q)).type);
  end

end
