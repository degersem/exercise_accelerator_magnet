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

    switch mesh.shape_function_type
      case 'linear'
        for k=1:numelem
          idx=mesh.elem(k,1:3);
          elemmat=(mesh.b(k,:)'*nu(k,2)*mesh.b(k,:)+mesh.c(k,:)'*nu(k,1)*mesh.c(k,:))/(4*mesh.area(k)*mesh.depth(k));
          i(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
          j(9*(k-1)+(1:9),1)=[idx idx idx]';
          v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
        end
      case 'axicurl'
        [weights,localcds]=gauss_triangle(mesh.integration_order);
        for k=1:numelem
          idx=mesh.elem(k,1:3);
    %       elemmat=mesh.b(k,:)'*nu(k,2)*mesh.b(k,:)/(2*pi*mesh.D(k)^2)*mesh.rav(k)*mesh.area(k)...
    %         +mesh.c(k,:)'*nu(k,1)*mesh.c(k,:)/(4*mesh.D(k)^2*mesh.depth(k))*mesh.area(k);
          int_2pir=weights*(1./(2*pi*localcds*mesh.node(idx,1)));
          elemmat=mesh.b(k,:)'*nu(k,2)*mesh.b(k,:)/(2*pi*mesh.D(k)^2)*mesh.rav(k)*mesh.area(k)...
            +mesh.c(k,:)'*nu(k,1)*mesh.c(k,:)/(4*mesh.D(k)^2)*int_2pir*mesh.area(k);
          i(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
          j(9*(k-1)+(1:9),1)=[idx idx idx]';
          v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
        end
      case 'radialcurl'
        for k=1:numelem 
          idx=mesh.elem(k,1:3);
          elemmat=mesh.b(k,:)'*nu(k,2)*mesh.b(k,:)/(4*mesh.area(k)*mesh.depth(k));
          if mesh.lz(k,1)~=0                                               % if r1 is equal to zero, than the second part of the equantion must be canceld due to the log: (c=0)^2*inf=0
               elemmat=elemmat+mesh.c(k,:)'*nu(k,1)*mesh.c(k,:)/(4*mesh.area(k)*mesh.depth(k))*(2*log(mesh.lz(k,2)/mesh.lz(k,1))/(mesh.lz(k,2)^2-mesh.lz(k,1)^2));
          end
          i(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
          j(9*(k-1)+(1:9),1)=[idx idx idx]';
          v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
        end
      otherwise
        error('Unknown shape-function type %s\n',mesh.shape_function_type);
    end
    Kfem=sparse(i,j,v,numnode,numnode);
end