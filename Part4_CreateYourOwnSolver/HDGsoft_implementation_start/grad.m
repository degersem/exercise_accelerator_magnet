function E = grad(mesh,phi)
    % function E = grad(mesh,phi)
    %   computes the electric field strength for a given distribution of the electric scalar potential
    %   MIND THE LACK OF THE MINUS SIGN, WHICH HAS TO BE APPLIED BY THE USER OUTSIDE THIS ROUTINE
    %
    % Inputs
    %       mesh      :      : 2D FE mesh
    %       phi       : [V]  : electric scalar potential, numnode-by-1 vector
    %
    % Outputs
    %       E         : [V/m]: MINUS the electric field strength, numelem-by-1 vector
    %
    % Author
    %   Herbert De Gersem

    u=[phi(mesh.elem(:,1),1) phi(mesh.elem(:,2),1) phi(mesh.elem(:,3),1)];
    switch mesh.shape_function_type
      case 'linear'
        E=[sum(mesh.b.*u,2) sum(mesh.c.*u,2)]./[2*mesh.area 2*mesh.area];
      otherwise
        error('not yet implemented');
    end
        
end
