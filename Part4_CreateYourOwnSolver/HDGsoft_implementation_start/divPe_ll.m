function rhope = divPe_ll(mesh,Pe)
% function rhope = divPe_ll(mesh,Pe)
%   returns the div-Pe load vector
%   \int -div(Hs) Ni dV  == \int Hs grad(Ni) dV
%
% input parameters
%    mesh       :         : 2D FE mesh
%    Pe         : [C/m^2] : polarisation (numelem-by-2)
%
% Outputs
%    rhope      : [C]     : discrete polarisation charge
%
% See also
%   divgrad_ll
%
% Author
%   Herbert De Gersem

numnode=size(mesh.node,1);                                                 % [#] : number of FE nodes
numelem=size(mesh.elem,1);                                                 % [#] : number of FE elements
if (size(Pe,1)~=numelem) || (size(Pe,2)~=2)
  error('parameter Pe should be numelem-by-2');
end

rhope=zeros(numnode,1);
switch mesh.shape_function_type
  case 'linear'
    % loop form
    % for k=1:numelem
    %   idx=mesh.elem(k,1:3);
    %   jpm(idx,:)=jpm(idx,:)-(Hs(k,1)*mesh.c(k,:)'-Hs(k,2)*mesh.b(k,:)')/2;  % this is still the curl-curl form
    % end
    % vector form
    k=find(Pe(:,1) | Pe(:,2));
    idx=mesh.elem(k,1:3);
    rhopemat=(repmat(Pe(k,1),1,3).*mesh.b(k,:)/2+repmat(Pe(k,2),1,3).*mesh.c(k,:)/2).*repmat(mesh.depth(k,1),1,3);
    rhope=sparse(idx(:),1,rhopemat(:),numnode,1);
  case 'axicurl'
    error('these lines are irrelevant here');
    k=find(Pe(:,1) | Pe(:,2));
    idx=mesh.elem(k,1:3);
    rhopemat=(repmat(Pe(k,1),1,3).*mesh.b(k,:)/2+repmat(Pe(k,2),1,3).*mesh.c(k,:)/2).*repmat(2*pi*mesh.rav(k,1),1,3);
    rhope=sparse(idx(:),1,rhopemat(:),numnode,1);
  case 'radialcurl'
    error('not implemented');
  otherwise
    error('Unknown shape-function type %s\n',mesh.shape_function_type);
end
