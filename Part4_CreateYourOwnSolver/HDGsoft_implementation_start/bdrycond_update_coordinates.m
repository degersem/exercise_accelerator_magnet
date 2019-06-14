function bdrycond=bdrycond_update_coordinates(bdrycond,msh,allocation)
% function bdrycond=bdrycond_update_coordinates(bdrycond,msh,allocation)
%   updates the coordinates of the boundary simplices for inhomogeneous boundary conditions
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    msh                :       : 2D FE mesh
%    allocation         : 'node'/'edge'/'face'/'volume' : allocation of the degrees of freedom
%
% Outputs
%    bdrycond           :       : data for boundary conditions (BCs)
%
% Author
%   Herbert De Gersem

% F. Provide coordinate information for inhomogeneous Dirichlet boundary conditions
bdlist=[ find(strcmp({bdrycond.type},'dirichlet')) find(strcmp({bdrycond.type},'neumann')) ]; % [@]    : identifiers of the inhomogeneous boundary conditions that may be defined by an expression
for ii=1:length(bdlist)
  bd=bdlist(ii);                                                           % [@]    : BC identifier
  if ~isempty(bdrycond(bd).expression)
    switch allocation
      case 'node'
        switch bdrycond(bd).type
          case 'dirichlet'
            xy=msh.node(bdrycond(bd).idxnode,1:2);                         % [m,m]  : coordinates
          case 'neumann'
            ed=bdrycond(bd).idxedge;
            xy=(msh.node(msh.edge(ed,1),1:2)+msh.node(msh.edge(ed,2),1:2))/2;  % [m,m]  : coordinates
        end
      case 'edge'
        ed=bdrycond(bd).idxedge;
        xy=(msh.node(msh.edge(ed,1),1:2)+msh.node(msh.edge(ed,2),1:2))/2;  % [m,m]  : coordinates
      otherwise
        error('Unknown allocation %s\n',allocation);
    end
    [theta,r]=cart2pol(xy(:,1),xy(:,2));    
    switch msh.symmetry_type
      case 'planar'
        if depends_on(bdrycond(bd).expression,'z')
          error('use (x,y) coordinates for defining expression boundary conditions in axisymmetric problems');
        end
        if depends_on(bdrycond(bd).expression,'x')                         % Dirichlet data depends on x
          bdrycond(bd).para.x=xy(:,1);
        end
        if depends_on(bdrycond(bd).expression,'y')                         % Dirichlet data depends on y
          bdrycond(bd).para.y=xy(:,2);
        end
        if depends_on(bdrycond(bd).expression,'r')                         % Dirichlet data depends on r
          bdrycond(bd).para.r=r;
        end
        if depends_on(bdrycond(bd).expression,'theta')                     % Dirichlet data depends on theta
          bdrycond(bd).para.theta=theta;
        end
      case 'axisymmetric'
        if depends_on(bdrycond(bd).expression,'x') | depends_on(bdrycond(bd).expression,'y')
          error('use (r,z) coordinates for defining expression boundary conditions in axisymmetric problems');
        end
        if depends_on(bdrycond(bd).expression,'r')                         % Dirichlet data depends on x
          bdrycond(bd).para.r=xy(:,1);
        end
        if depends_on(bdrycond(bd).expression,'z')                         % Dirichlet data depends on y
          bdrycond(bd).para.z=xy(:,2);
        end
        if depends_on(bdrycond(bd).expression,'rho')                       % Dirichlet data depends on r
          bdrycond(bd).para.rho=rho;
        end
        if depends_on(bdrycond(bd).expression,'theta')                     % Dirichlet data depends on theta
          bdrycond(bd).para.theta=theta;
        end
      case 'radialsymmetric'
        if depends_on(bdrycond(bd).expression,'z')
          error('use (x,y) coordinates for defining expression boundary conditions in radialsymmetric problems');
        end
        if depends_on(bdrycond(bd).expression,'x')                         % Dirichlet data depends on x
          bdrycond(bd).para.x=xy(:,1);
        end
        if depends_on(bdrycond(bd).expression,'y')                         % Dirichlet data depends on y
          bdrycond(bd).para.y=xy(:,2);
        end
        if depends_on(bdrycond(bd).expression,'r')                         % Dirichlet data depends on r
          bdrycond(bd).para.r=r;
        end
        if depends_on(bdrycond(bd).expression,'theta')                     % Dirichlet data depends on theta
          bdrycond(bd).para.theta=theta;
        end
      otherwise
        error('non-treated 2D symmetry type');
    end
  end
end
