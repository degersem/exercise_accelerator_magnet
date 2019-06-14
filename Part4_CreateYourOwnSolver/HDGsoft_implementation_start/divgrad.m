function Kfem = divgrad(mesh,elemperm)
    % function Kfem = divgrad(mesh,elemperm)
    %   returns the div-grad matrix for element-wise constant permittivities/(thermal)conductivities
    %
    % Inputs
    %    mesh       :       : 2D FE mesh
    %    elemperm   : [F/m] : permittivity/(thermal)conductivity (one per region or one per element)
    %
    % Outputs
    %    Kfem       : [F]   : div-grad matrix
    %
    % See also 
    %   edgemass, curlcurl
    %
    % Author
    %   Herbert De Gersem
    
    numnode=size(mesh.node,1);                                                 % [#]   : number of FE nodes
    numelem=size(mesh.elem,1);                                                 % [#]   : number of FE elements
    i=zeros(9*numelem,1);
    j=zeros(9*numelem,1);
    v=zeros(9*numelem,1);
    if size(elemperm,1)~=numelem
      error('Usage: Kfem=divgrad(mesh,prb_block2elem(prb,blockperm))');
    end
    switch size(elemperm,2)
      case 1
        elemperm=[elemperm elemperm];
      case 2
      case 3
        elemperm=elemperm(:,[1 3 2 3]);
      case 4
      otherwise
        error('The permittivity-per-element matrix should have 1, 2, 3 or 4 columns');
    end
    switch size(elemperm,2)
      case 2
        for k=1:numelem
          idx=mesh.elem(k,1:3);
          elemmat=(mesh.b(k,:)'*elemperm(k,1)*mesh.b(k,:)+mesh.c(k,:)'*elemperm(k,2)*mesh.c(k,:))/(4*mesh.area(k))*mesh.depth(k);
          i(9*(k-1)+[1:9],1)=[idx idx idx]';
          j(9*(k-1)+[1:9],1)=reshape([idx; idx; idx],[],1);
          v(9*(k-1)+[1:9],1)=reshape(elemmat,[],1);
        end
      case 4
        for k=1:numelem
          idx=mesh.elem(k,1:3);
          elemmat=(mesh.b(k,:)'*elemperm(k,1)*mesh.b(k,:)+mesh.b(k,:)'*elemperm(k,2)*mesh.c(k,:)+mesh.c(k,:)'*elemperm(k,3)*mesh.b(k,:)+mesh.c(k,:)'*elemperm(k,4)*mesh.c(k,:))/(4*mesh.area(k))*mesh.depth(k);
          i(9*(k-1)+[1:9],1)=[idx idx idx]';
          j(9*(k-1)+[1:9],1)=reshape([idx; idx; idx],[],1);
          v(9*(k-1)+[1:9],1)=reshape(elemmat,[],1);
        end
    end
    Kfem=sparse(i,j,v,numnode,numnode);
end
