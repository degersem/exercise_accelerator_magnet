function geometry_plot_arcsegments(arcsegments,colour)

% function geometry_plot_arcsegments(arcsegments,colour)
%   plots arc segments
%
% Inputs
%    arcsegments      : arcsegments
%    colour           : colour (optional; default: black)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('colour','var')
  colour='k';
end

for asg=1:size(arcsegments,1)
  cd=arcsegments(asg,8:9);
  R=arcsegments(asg,10);
  a1=arcsegments(asg,11);
  a2=arcsegments(asg,12);
  adiff=confine(a2-a1,0,2*pi);
  n=ceil(adiff/(arcsegments(asg,4)/180*pi));                         % [#]    : number of line segments to be drawn
  th=linspace(a1,a1+adiff,n+1);
  line(cd(1)+R*cos(th),cd(2)+R*sin(th),'Color',colour);
end
