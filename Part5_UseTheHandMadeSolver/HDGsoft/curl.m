function B = curl(mesh,az)
% function B = curl(mesh,az)
%   computes the magnetic flux density for a given distribution of the line-integrated magnetic vector potential
%
% Inputs
%       mesh      :      : 2D FE mesh
%       a         : [Wb] : line-integrated magnetic vector potential, numnode-by-1 vector
%
% Outputs
%       B         : [T]  : magnetic flux density, numelem-by-2 vector
%
% See also
%   grad, div
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

u=[az(mesh.elem(:,1),1) az(mesh.elem(:,2),1) az(mesh.elem(:,3),1)];
switch mesh.symmetry_info.type
  case 'planar'
    Bp=[sum(mesh.c.*u,2) -sum(mesh.b.*u,2)];
    denom=2*mesh.area.*mesh.depth;
    B=Bp./[denom denom];
  case 'axisymmetric'
    switch mesh.symmetry_info.shape_function_type
      case 'linear'
        Bp=[sum(mesh.c.*u,2) -sum(mesh.b.*u,2)];
        denom=2*mesh.area.*mesh.depth;
        B=Bp./[denom denom];
      case 'axicurl'
        Bp=[ sum(mesh.c.*u,2) -mesh.rav.*sum(2*mesh.b.*u,2)];
        denom=-(2*mesh.D).*mesh.depth;
        B=Bp./[denom denom];
      otherwise
        error('Unknown shape-function type %s\n',mesh.symmetry_info.shape_function_type);
    end
  case 'radialsymmetric'
    Bp=[ sum(mesh.c.*u./(mesh.symmetry_info.rvis),2) -sum(mesh.b.*u,2)];
    denom=2*mesh.area.*mesh.depth;
    B=Bp./[denom denom];
  otherwise
    error('Unknown symmetry type %s\n',mesh.symmetry_type);
end
