function node = geometry_reconstruct_arcs(gmy,node)
    % function node = geometry_reconstruct_arcs(gmy,node)
    %   repairs the the radii of the nodes at arc segments
    %
    % Inputs
    %    gmy              : 2D geometry
    %    node             : set of node coordinates
    %
    % Outputs
    %    node             : reconstructed set of node coordinates
    %
    % See also 
    %   shell_repair_radii
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    if size(gmy.arcsegments,2)<12
      error('run gmy=geometry_extend_info(gmy) before using geometry_reconstruct_arcs');
    end
    if size(node,2)<6
      error('run msh=mesh_connect_geometry(msh,gmy) before using geometry_reconstruct_arcs');
    end
    for asg=1:size(gmy.arcsegments,1)
      idxnode=find(node(:,6)==asg);                                            % [@]   : indices of all nodes at the arc
      center=gmy.arcsegments(asg,8:9);                                         % [m,m] : center point
      R=gmy.arcsegments(asg,10);                                               % [m]   : radius
      a=atan2(node(idxnode,2)-center(2),node(idxnode,1)-center(1));            % [rad] : angles
      node(idxnode,1:2)=[R*cos(a)+center(1) R*sin(a)+center(2)];               % [m,m] : put all nodes exactly on the arc
    end
    
end

