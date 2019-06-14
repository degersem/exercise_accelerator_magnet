function jpm = curlHs_ll(mesh,Hs)
% function jpm = curlHs_ll(mesh,Hs)
%   returns the curl-Hs load vector
%
% input parameters
%    mesh       :       : 2D FE mesh
%    Hs         : [A/m] : source magnetic field strength (numelem-by-2)
%
% Outputs
%    jpm        : [A]   : discrete magnetisation current
%
% See also
%   curlcurl_ll
%
% Author
%   Herbert De Gersem

numnode=size(mesh.node,1);                                                 % [#] : number of FE nodes
numelem=size(mesh.elem,1);                                                 % [#] : number of FE elements
if size(Hs,1)~=numelem
  error('parameter Hs should be numelem-by-2');
end
if size(Hs,2)~=2
  error('parameter Hs should be numelem-by-2');
end

jpm=zeros(numnode,1);
switch mesh.shape_function_type
  case 'linear'
    % loop form
    % for k=1:numelem
    %   idx=mesh.elem(k,1:3);
    %   jpm(idx,:)=jpm(idx,:)-(Hs(k,1)*mesh.c(k,:)'-Hs(k,2)*mesh.b(k,:)')/2;
    % end
    % vector form
    k=find(Hs(:,1) | Hs(:,2));
    idx=mesh.elem(k,1:3);
    jpmmat=-repmat(Hs(k,1),1,3).*mesh.c(k,:)/2+repmat(Hs(k,2),1,3).*mesh.b(k,:)/2;
    jpm=sparse(idx(:),1,jpmmat(:),numnode,1);
  case 'axicurl'
    % implementation only for axial magnetisation
    for k=1:numelem
      idx=mesh.elem(k,1:3);
      jpm(idx,:)=jpm(idx,:)-Hs(k,2)*mesh.b(k,:)*mesh.rav(k)/mesh.D(k)*mesh.area(k);
    end
    if any(Hs(:,1))
      error('this implementation is not yet checked');
      [weights,localcds]=gauss_triangle(mesh.integration_order);
      for k=1:numelem
        idx=mesh.elem(k,1:3);
        int_2pir=weights*(1./(2*pi*localcds*mesh.node(idx,1)));
        jpm(idx,:)=jpm(idx,:)+Hs(k,1)*mesh.rref*mesh.c(k,:)'/mesh.D(k)*pi*mesh.area(k);
      end
    end
  case 'radialcurl'
    k=find(Hs(:,1) | Hs(:,2));
    idx=mesh.elem(k,1:3);
    jpmmat=-mesh.symmetry_info.rvis*repmat(Hs(k,1),1,3).*mesh.c(k,:)./((mesh.lz(k,2).^2-mesh.lz(k,1).^2)*ones(1,3)).*(log(mesh.lz(k,2)./mesh.lz(k,1))*ones(1,3))+repmat(Hs(k,2),1,3).*mesh.b(k,:)/(2);
    jpm=sparse(idx(:),1,jpmmat(:),numnode,1);
  otherwise
    error('Unknown shape-function type %s\n',mesh.shape_function_type);
end
