function gmy = geometry_extend_info(gmy)
    % function gmy = geometry_extend_info(gmy)
    %   extends the information in the geometry structures arc segments : adds center points, radii, begin/end angles
    %
    % Inputs
    %    gmy       : 2D geometry
    %
    % Outputs
    %    gmy       : 2D geometry
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    % A. Add center, radii, begin/end angle for arc segments
    cd1=gmy.points(gmy.arcsegments(:,1),1:2);                                  % [m,m] : first arc-segment point
    cd2=gmy.points(gmy.arcsegments(:,2),1:2);                                  % [m,m] : second arc-segment point
    angle=gmy.arcsegments(:,3)/180*pi;                                         % [rad] : angle
    [center,R,a1,a2]=convert_arc_info(cd1,cd2,angle);
    gmy.arcsegments(:,8:12)=[center R a1 a2];
    
end
