function h = mesh_edge_length(msh)
    % function h = mesh_edge_length(msh)
    %   return the lengths of the edges
    %
    % Inputs
    %    msh             : 2D FE mesh
    %
    % Outputs
    %    h               : [m]   : edge lenghts
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    if ~isfield(msh,'edge')
      msh=mesh_add_edge_data(msh);
    end
    h=pyth(msh.node(msh.edge(:,1),1:2)-msh.node(msh.edge(:,2),1:2));
    
end
