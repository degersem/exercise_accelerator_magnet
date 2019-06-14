function flag=anglebetween(angle,amin,amax,reltol)

% function flag=anglebetween(angle,amin,amax,reltol)
% returns 1 when the specified angle is between the minimal and maximal angle
%
% input parameters
%    angle          : [rad]  : specified angle
%    amin           : [rad]  : minimal angle
%    amax           : [rad]  : maximal angle
%    reltol         : []     : relative geometrical tolerance (optional; default: 1e-3)
%
% output parameters
%    flag           : [1/0]  : 1 for the angles between amin and amax
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if nargin<4
  reltol=1e-3;
end
a12=confine(amax-amin);
tol=a12*reltol;
tollen=a12+2*tol;
flag=((confine(angle-amin+tol)<tollen) & (confine(amax+tol-angle)<tollen));
