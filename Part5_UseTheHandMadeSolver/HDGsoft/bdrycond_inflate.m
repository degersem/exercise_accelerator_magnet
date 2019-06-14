function ufem = bdrycond_inflate(bdrycond,ubcs,numunknown,idxdof,insert_dirichlet)
% function ufem = bdrycond_inflate(bdrycond,ubcs,numunknown,idxdof,insert_dirichlet)
%   inflates the solution from solution for the degrees of freedom to solution for all nodes
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    ubcs               : [Wb]  : solution for the degrees of freedom
%    numunknown         : [#]   : number of unknowns in the formulation
%    idxdof             : [@]   : indices of the degrees of freedom (optional; default: [])
%    insert_dirichlet   : [1/0] : insert nonhomogeneous Dirichlet data or not (optional; default: 1)
%
% Outputs
%    ufem               : [Wb]  : solution for all nodes
%
% Note
%    "unary" boundary conditions are assigned to nodes (e.g. Dirichlet/Neumann/Robin boundary conditions
%    "binary" boundary conditions connect nodes (e.g. (anti-)periodic boundary conditions and air-gap interface conditions
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('insert_dirichlet','var')
  insert_dirichlet=1;
end

% A. Initialisation
numcol=size(ubcs,2);                                                       % [#]    : number of columns
ufem=zeros(numunknown,numcol);                                             % [Wb]   : blow the reduced solution vector up to a full solution vector
ufem(idxdof,:)=ubcs;                                                       % [Wb]   : introduce degrees of freedom
ufem=bdrycond_applyP(bdrycond,ufem,insert_dirichlet);                      % [Wb]   : apply the boundary conditions

end