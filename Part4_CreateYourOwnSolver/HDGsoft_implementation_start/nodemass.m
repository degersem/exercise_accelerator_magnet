function Mfem = nodemass(mesh,rhocap)
    % function Mfem = nodemass(mesh,rhocap)
    %   returns the cff-node-mass matrix for an element-wise constant material property rhocap
    %
    % Inputs
    %       mesh      :          : 2D FE mesh
    %       rhocap    : [J/Km^3] : element-wise constant material property
    %
    % Outputs
    %       Mfem      : [J/K]    : FE mass matrix (numnode-by-numnode matrix)
    %
    % See also 
    %   divgrad, curlcurl, curlcurl_nonlinear
    %
    % Author
    %   Herbert De Gersem
    

    numnode=size(mesh.node,1);                                                 % [#] : number of FE nodes
    numelem=size(mesh.elem,1);                                                 % [#] : number of FE elements
    if size(rhocap,1)~=numelem
      error('Usage: Mfem=nodemass(mesh,prb_block2elem(prb,blockrhocap))');
    end
    i=zeros(9*numelem,1);
    j=zeros(9*numelem,1);
    v=zeros(9*numelem,1);
    for k=1:numelem
      idx=mesh.elem(k,1:3);
      elemmat=mesh.area(k)/12*[2 1 1;1 2 1;1 1 2]*rhocap(k,1)*mesh.depth(k);
      i(9*(k-1)+[1:9],1)=[idx idx idx]';
      j(9*(k-1)+[1:9],1)=reshape([idx; idx; idx],[],1);
      v(9*(k-1)+[1:9],1)=reshape(elemmat,[],1);
    end
    Mfem=sparse(i,j,v,numnode,numnode);

end