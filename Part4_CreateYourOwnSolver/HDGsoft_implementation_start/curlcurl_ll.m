function Kfem = curlcurl_ll(mesh,nu)
% function Kfem = curlcurl_ll(mesh,nu)
%   returns the curl-curl matrix for the element-wise constant reluctivities reginu
%
% Inputs
%    mesh       :       : 2D FE mesh
%    nu         : [m/H] : reluctivity (one per element)
%
% Outputs
%    Kfem       : [1/H] : curl-curl matrix
%
% See also
%   edgemass, curlcurl_nonlinear
%
% Author
%   Jeroen Deryckere
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

numnode=size(mesh.node,1);                                                 % [#] : number of FE nodes
numelem=size(mesh.elem,1);                                                 % [#] : number of FE elements
i=zeros(9*numelem,1);
j=zeros(9*numelem,1);
v=zeros(9*numelem,1);

if size(nu,1)~=numelem
  error('Version problem, use curlcurl(prb.mesh,prb_block2elem(prb,blocknu))');
end
if size(nu,2)<2
  nu=[nu nu];
end

for k=1:numelem
  idx=mesh.elem(k,1:3);
  % ---------------------- START IMPLEMENTATION TASK 3a ----------------------
  % calculate and assemble the curl-reluctance-curl matrix and the winding matrix
  % ----------------------- END IMPLEMENTATION TASK 3a -----------------------
  elemmat;
  i(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
  j(9*(k-1)+(1:9),1)=[idx idx idx]';
  v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
end
Kfem=sparse(i,j,v,numnode,numnode);
