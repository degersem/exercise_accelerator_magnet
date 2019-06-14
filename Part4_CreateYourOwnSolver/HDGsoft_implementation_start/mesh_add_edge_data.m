function msh = mesh_add_edge_data(msh)
    % function msh = mesh_add_edge_data(msh)
    %   adds edge-to-node and element-to-edge incidence data
    %
    % Inputs
    %    msh           : 2D FE mesh
    %
    % Outputs
    %    msh           : 2D FE mesh
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    numelem=size(msh.elem,1);                                  % [#]  : old number of elements
    edge2node=[
      msh.elem(:,[2 3]) ;
      msh.elem(:,[3 1]) ;
      msh.elem(:,[1 2]) ;
      ];                                                       % [@]  : edge-to-node indicence matrix
    signidx=find(edge2node(:,1)>edge2node(:,2));               % [@]  : indices of the edges with negative orientation (positive orientation corresponds to increasing node number)
    edge2node(signidx,[1 2])=edge2node(signidx,[2 1]);         % [@]  : turn the negatively orientated edges
    [edge2node,dummy,sortidx]=unique(edge2node,'rows');        % [@]  : indices of the unique edges
    numedge=size(edge2node,1);                                 % [#]  : number of edges
    mapedge=sortidx;                                           % [@]  : maps the original edge indices to the final ones (3*numelem-by-1; range between 1 and numedge)
    mapedge(signidx,:)=-mapedge(signidx);
    msh.elem2edge=[
      mapedge(0*numelem+[1:numelem],1) ...
      mapedge(1*numelem+[1:numelem],1) ...
      mapedge(2*numelem+[1:numelem],1) ...
    ];
    msh.edge=edge2node;
    if 0
      % check
      [ipos,jpos]=find(msh.elem2edge>0); vpos=elem2edge(sub2ind(size(msh.elem2edge),ipos,jpos));
      [ineg,jneg]=find(msh.elem2edge<0); vneg=-elem2edge(sub2ind(size(msh.elem2edge),ineg,jneg));
      elem2node=full(sparse([ipos;ipos;ineg;ineg],[rem(jpos,3)+1;rem(jpos+1,3)+1;rem(jneg,3)+1;rem(jneg+1,3)+1],[edge2node(vpos,1);edge2node(vpos,2);edge2node(vneg,2);edge2node(vneg,1)],numelem,3))/2;
      [elem2node msh.elem(:,1:3)]
      fprintf('Columns 1 2 3 should be equal to columns 4 5 6\n');
    end
    
end
