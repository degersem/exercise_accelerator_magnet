function xnew=confine(x,xmin,xmax)

% function xnew=confine(x,x1,x2)
% confines a given value between two extremal values
% by adding/substracting integral number of periods
%
% input parameters
%    x       : original value
%    xmin    : minimal value
%    xmax    : maximal value
%
% output parameters
%    xnew    : new value : (xmin<=x) & (x<xmax)
%
% examples
%    angle_between_0_and_2pi = confine(3*pi,0,2*pi)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if nargin<2
  xmin=0;
  xmax=2*pi;
end
Dx=xmax-xmin;
xnew=x-Dx*floor((x-xmin)/Dx);
