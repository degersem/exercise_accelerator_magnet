function [Kfem,jfem]=curlcurl_nonlinear(mesh,B,nu,dnudB2,Hc)
% function [Kfem,jfem]=curlcurl_nonlinear(mesh,B,nu,dnudB2,Hc)
%   returns the curl-curl matrix and magnetisation vector for the element-wise magnetic properties
%
% Inputs
%    mesh       : 2D FE mesh
%    B          : element-wise magnetic flux density (numelem-by-2 vector)
%    nu         : element-wise reluctivity (numelem-by-1 vector)
%    dnudB2     : element-wise differentiation of the reluctivity (numelem-by-1 vector)
%    Hc         : element-wise coercitivity (numelem-by-2 vector)
%
% Outputs
%    Kfem       : curl-curl matrix
%    jfem       : magnetisation vector
%
% See also
%   edgemass, curlcurl
%
% Author
%   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

numnode=size(mesh.node,1);                                                 % [#]  : number of FE nodes
numelem=size(mesh.elem,1);                                                 % [#]  : number of FE elements
i=zeros(9*numelem,1);
j=zeros(9*numelem,1);
v=zeros(9*numelem,1);
jfem=zeros(numnode,1);
if ~strcmp(mesh.symmetry_type,'planar')
  error('not yet implemented for axisymmetric and radial symmetric cases');
end
for k=1:numelem
  idx=mesh.elem(k,1:3);
  shape=[mesh.c(k,:);-mesh.b(k,:)];
  nud=nu(k,1)*eye(2)+2*B(k,:)'*dnudB2(k)*B(k,:);
  elemmat=(shape'*nud*shape)/(4*mesh.area(k)*mesh.depth(k));
  i(9*(k-1)+[1:9],1)=[idx idx idx]';
  j(9*(k-1)+[1:9],1)=reshape([idx; idx; idx],[],1);
  v(9*(k-1)+[1:9],1)=reshape(elemmat,[],1);
  elemvec=-shape'*Hc(k,:)'/2;
  jfem(idx,:)=jfem(idx,:)+elemvec;
end
Kfem=sparse(i,j,v,numnode,numnode);

end
