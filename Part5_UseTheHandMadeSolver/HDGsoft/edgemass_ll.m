function Mfem = edgemass_ll(mesh,sigma)
    % function Mfem = edgemass_ll(mesh,sigma)
    %   returns the cff-edge-mass matrix for a certain element-wise constant conductivity
    %
    % Inputs
    %    mesh       :       : 2D FE mesh
    %    sigma      : [S/m] : conductivity (one per element)
    %
    % Ouputs
    %       Mfem      : FE mass matrix                                                                           numnode-by-numnode matrix
    %
    % See also 
    %   divgrad, curlcurl, curlcurl_nonlinear
    %
    % Author
    %   Jeroen Deryckere
%
% author: Herbert De Gersem
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

    switch mesh.shape_function_type
      case 'linear'
        for k=1:numelem
          idx=mesh.elem(k,1:3);
          elemmat=mesh.area(k)/12*[2 1 1;1 2 1;1 1 2]*sigma(k,1)/mesh.depth(k);
          i(9*(k-1)+(1:9),1)=[idx idx idx]';
          j(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
          v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
        end
      case 'axicurl'
        [weights,localcds]=gauss_triangle(mesh.integration_order);
        numgauss=length(weights);
        for k=1:numelem
          idx=mesh.elem(k,1:3);
          r=localcds*mesh.node(idx,1);
          z=localcds*mesh.node(idx,2);
          Nrz=(ones(numgauss,1)*mesh.a(k,:)+r.^2*mesh.b(k,:)+z*mesh.c(k,:))/(2*mesh.D(k));
          elemmat=zeros(3,3);
          for gp=1:numgauss
            elemmat=elemmat+weights(gp)*transpose(Nrz(gp,:))*sigma(k,1)*Nrz(gp,:)/(2*pi*r(gp))*mesh.area(k);
          end
          i(9*(k-1)+(1:9),1)=[idx idx idx]';
          j(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
          v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
        end
      case 'radialcurl'   % exact calculation of the integral
        rvis=mesh.symmetry_info.rvis;
        lr=diff(mesh.symmetry_info.extent);
        r1=mesh.symmetry_info.extent(1);
        r2=mesh.symmetry_info.extent(2);
        qr_=log(r2/r1);
        qr0=r2-r1;
        qr1=(r2^2-r1^2)/2;
        qr2=(r2^3-r1^3)/3;
        qr3=(r2^4-r1^4)/4;
        thetaelem=[ mesh.node(mesh.elem(:,1),1) mesh.node(mesh.elem(:,2),1) mesh.node(mesh.elem(:,3),1) ];
        zelem    =[ mesh.node(mesh.elem(:,1),2) mesh.node(mesh.elem(:,2),2) mesh.node(mesh.elem(:,3),2) ];
        thetaX   =mean(thetaelem,2);
        zX       =mean(zelem,2);
        thetaY   =mean([ thetaelem.^2     thetaelem.*circshift(thetaelem,[0 1]) ],2);
        zY       =mean([ zelem.^2         zelem.*circshift(zelem,[0 1]) ],2);
        zthetaY  =mean([ thetaelem.*zelem thetaelem.*circshift(zelem,[0 1]) ],2);
        for k=1:numelem
          idx=mesh.elem(k,1:3);
          a=mesh.a(k,:); b=mesh.b(k,:); c=mesh.c(k,:);
%           elemmat=sigma(k,1)*(a'*a*qr1+b'*b*qr3*thetaY(k)+c'*c*qr_*zY(k) ...
%               +(a'*b+b'*a)*qr2*thetaX(k)+(a'*c+c'*a)*qr0*zX(k)+(b'*c+c'*b)*qr1*zthetaY(k))/(4*mesh.area(k)^2)/lr^2*mesh.area(k)/rvis; %_OLD WRONG EDGE SHAPE FUNCTION
          elemmat=sigma(k,1)*(a'*a*qr_+b'*b*qr3*thetaY(k)+c'*c*qr_*zY(k) ...
              +(a'*b+b'*a)*qr1*thetaX(k)+(a'*c+c'*a)*qr_*zX(k)+(b'*c+c'*b)*qr1*zthetaY(k))/(4*mesh.area(k)^2)/lr^2*mesh.area(k)/rvis; %_NEW RIGHT EDGE SHAPE FUNCTION
          i(9*(k-1)+(1:9),1)=[idx idx idx]';
          j(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
          v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
        end
%       case 'radialcurl'   % exact integration in r-direction, Gauss quadrature in \theta and z directions
%         rvis=mesh.symmetry_info.rvis;
%         lr=diff(mesh.symmetry_info.extent);
%         r1=mesh.symmetry_info.extent(1);
%         r2=mesh.symmetry_info.extent(2);
%         qr_=log(r2/r1);
%         qr0=r2-r1;
%         qr1=(r2^2-r1^2)/2;
%         qr2=(r2^3-r1^3)/3;
%         qr3=(r2^4-r1^4)/4;
%         [weights,localcds]=gauss_triangle(mesh.integration_order);
%         %weights=1; localcds=[ 1/3 1/3 1/3 ];
%         numgauss=length(weights);
%         for k=1:numelem
%           idx=mesh.elem(k,1:3);
%           theta=localcds*mesh.node(idx,1);
%           z=localcds*mesh.node(idx,2);
%           a=mesh.a(k,:); b=mesh.b(k,:); c=mesh.c(k,:);
%           elemmat=zeros(3,3);
%           for gp=1:numgauss
% %             elemmat=elemmat+weights(gp)*sigma(k,1)*(a'*a*qr1+b'*b*qr3*theta(gp)^2+c'*c*qr_*z(gp)^2 ...
% %               +(a'*b+b'*a)*qr2*theta(gp)+(a'*c+c'*a)*qr0*z(gp)+(b'*c+c'*b)*qr1*theta(gp)*z(gp))/(4*mesh.area(k)^2)/lr^2*mesh.area(k)/rvis; %_OLD WRONG EDGE SHAPE FUNCTION
%             elemmat=elemmat+weights(gp)*sigma(k,1)*(a'*a*qr_+b'*b*qr3*theta(gp)^2+c'*c*qr_*z(gp)^2 ...
%               +(a'*b+b'*a)*qr1*theta(gp)+(a'*c+c'*a)*qr_*z(gp)+(b'*c+c'*b)*qr1*theta(gp)*z(gp))/(4*mesh.area(k)^2)/lr^2*mesh.area(k)/rvis; %_NEW RIGHT EDGE SHAPE FUNCTION
%           end
%           i(9*(k-1)+(1:9),1)=[idx idx idx]';
%           j(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
%           v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
%         end
%       case 'radialcurl'     % Gauss quadrature in all three directions
%         rvis=mesh.symmetry_info.rvis;
%         lr=diff(mesh.symmetry_info.extent);
%         [weights,localcds]=gauss_triangular_prism(mesh.integration_order);
%         numgauss=length(weights);
%         for k=1:numelem
%           idx=mesh.elem(k,1:3);
%           r=localcds(:,4)*lr+mesh.symmetry_info.extent(1);
%           theta=localcds(:,1:3)*mesh.node(idx,1);
%           z=localcds(:,1:3)*mesh.node(idx,2);
%           %numgauss=3; r=rvis*ones(3,1); theta=mesh.node(idx,1); z=mesh.node(idx,2);
%           % Nrthetaz=(ones(numgauss,1)*mesh.a(k,:)+r.*theta*mesh.b(k,:)+z./r*mesh.c(k,:))/(2*mesh.area(k)); %_OLD WRONG EDGE SHAPE FUNCTION
%           Nrthetaz=(ones(numgauss,1)./r*mesh.a(k,:)+r.*theta*mesh.b(k,:)+z./r*mesh.c(k,:))/(2*mesh.area(k)); %_NEW RIGHT EDGE SHAPE FUNCTION
%           elemmat=zeros(3,3);
%           for gp=1:numgauss
%             elemmat=elemmat+weights(gp)*transpose(Nrthetaz(gp,:))*sigma(k,1)*Nrthetaz(gp,:)*(r(gp)/rvis)/lr*mesh.area(k); %*r(gp)/rvis
%           end
%           i(9*(k-1)+(1:9),1)=[idx idx idx]';
%           j(9*(k-1)+(1:9),1)=reshape([idx; idx; idx],[],1);
%           v(9*(k-1)+(1:9),1)=reshape(elemmat,[],1);
%         end
      otherwise
        error('Unknown shape-function type %s\n',mesh.shape_function_type);
    end
    Mfem=sparse(i,j,v,numnode,numnode);
    
end
