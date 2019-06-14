function [idxnode snode idxedge sedge] = mesh_order_segment(msh,gmy,sg)
    % function [idxnode snode idxedge sedge] = mesh_order_segment(msh,gmy,sg)
    %   returns the indices of the nodes at a line segment ordered from the first point to the second point
    %
    % Inputs
    %    msh              :      : 2D FE mesh
    %    gmy              :      : 2D geometry
    %    sg               : [@]  : segment number
    %
    % Outputs
    %    idxnode          : [@]  : indices of the nodes ordered from the first line-segment point to the second line-segment point
    %    snode            : [m]  : local coordinate of the nodes (== distances in increasing order to the first line-segment point)
    %    idxedge          : [@]  : indices of the edges ordered from the first line-segment point to the second line-segment point
    %    sedge            : [m]  : local coordinate of the edges (== distances in increasing order to the first line-segment point)
    %
    % Author
    %   Herbert De Gersem
    %
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    refcd=gmy.points(gmy.segments(sg,1),1:2);                                  % [m,m] : reference coordinate

    % A. Order edges
    idxedge=find(msh.edge(:,3)==sg);                                           % [@] : indices of the edges at the line segment
    sssedge=pyth((msh.node(msh.edge(idxedge,1),1:2)+msh.node(msh.edge(idxedge,2),1:2))/2-ones(length(idxedge),1)*refcd); % [m] : distances to the reference coordinate
    [sedge,jjj]=sort(sssedge);                                                 % [m] : local coordinates for the edges (== distances in increasing order)
    idxedge=idxedge(jjj);                                                      % [@] : indices of the edges (in increasing distance to the first line-segment point)

    % B. Order nodes
    idxnode=reshape(unique(msh.edge(idxedge,1:2)),[],1);                       % [@] : indices of the nodes at the line segment
    sssnode=pyth(msh.node(idxnode,1:2)-ones(length(idxnode),1)*refcd);         % [m] : distances to the reference coordinate
    [snode,iii]=sort(sssnode);                                                 % [m] : local coordinate for the nodes (== distances in increasing order)
    idxnode=idxnode(iii);                                                      % [@] : indices of the nodes (in increasing distance to the first line-segment point)
    
end
