function [center,R,a1,a2,selcd]=convert_arc_info(cd1,cd2,angle)

% function [center,R,a1,a2,selcd]=convert_arc_info(cd1,cd2,angle)
% converts arc information given by begin/end points and angle
% to arc information given by center point, radius and begin/end angles
%
% input parameters
%    cd1                    : [m,m] : first point
%    cd2                    : [m,m] : second point
%    angle                  : [rad] : angle
%
% output parameters
%    center                 : [m,m] : coordinate of the center point
%    R                      : [m]   : radius
%    a1                     : [rad] : first angle
%    a2                     : [rad] : second angle
%    selcd                  : [m,m] : coordinate of the selection point (at half the arc)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

df=cd2-cd1;                                                                % [m,m] : displacement between both arc-segment points
center=(cd1+cd2)/2+[-df(:,2) df(:,1)]./(2*tan(angle/2)*ones(1,2));         % [m,m] : center point
b=pyth(df)/2;                                                              % [m]   : distance between both points
R=b./sin(angle/2);                                                         % [m]   : arc radius
if nargout>2
  w1=cd1-center; a1=atan2(w1(:,2),w1(:,1));                                % [rad] : first angle
  w2=cd2-center; a2=atan2(w2(:,2),w2(:,1));                                % [rad] : second angle
  if nargout>4
    ahalf=a1+angle/2;
    selcd=center+[R.*cos(ahalf) R.*sin(ahalf)];                            % [m,m]   : coordinates of the selection points
  end
end
