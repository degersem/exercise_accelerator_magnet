function msh = mesh_linear_shape_functions(msh,shape_function_type,integration_order)
    % function msh = mesh_linear_shape_functions(msh,shape_function_type,integration_order)
    %   returns for a list of elements, the corresponding nodal coordinates, linear shape functions and area's
    %
    % Inputs
    %       msh                   : 2D FE mesh
    %           elem                    : [@]   : elem-to-node incidences
    %           node                    : [@]   : nodal coordinates
    %           symmetry_type           :
    %           'cartesian'/'axisymmetric'/'radialsymmetric
    %       shape_function_type   : type of shape functions (optional; default: linear)
    %           possibilities
    %           - linear                : linear shape functions (default)
    %           - axicurl               : linear in z, quadratic in r (recommended for curlcurl formulations)
    %           - radialcurl            : proportional with r in theta, proportional with 1/r in z (recommended for consistency)
    %       integration_order     : []: 1,2,3 up to 7 : order of the Gauss integration rule
    %
    % Outputs
    %       msh                   : 2D FE mesh
    %           a                       : shape function coefficients      numelem-by-3 array
    %           b                       : shape function coefficients      numelem-by-3 array
    %           c                       : shape function coefficients      numelem-by-3 array
    %           area                    : element areas                    numelem-by-1 vector
    %           depth                   : element depths                   numelem-by-1 vector
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    % A. Preamble
    % A.1. Shape function type
    if ~exist('shape_function_type','var')
      shape_function_type='linear';
    end
    % A.2. Gauss integration order
    msh.shape_function_type=shape_function_type;
    if ~exist('integration_order','var')
      integration_order=4;
    end
    msh.integration_order=integration_order;

    % B. Shortcuts
    numelem=size(msh.elem,1);
    x1=reshape(msh.node(msh.elem(:,1:3),1),numelem,3);
    y1=reshape(msh.node(msh.elem(:,1:3),2),numelem,3);
    x2=circshift(x1,[0 -1]);
    y2=circshift(y1,[0 -1]);
    x3=circshift(x1,[0 -2]);
    y3=circshift(y1,[0 -2]);
    
    if strcmp(shape_function_type,'radialcurl')
      z1=msh.symmetry_info.extent(1)*ones(numelem,3);
      z2=msh.symmetry_info.extent(2)*ones(numelem,3);
    end
    
    % C. Element area and depth
    switch msh.shape_function_type
      case 'linear'
        msh.area=mean(((x2.*y3-x3.*y2)+(y2-y3).*x1+(x3-x2).*y1)/2,2);
      case 'axicurl'
        msh.area=mean(((x2.*y3-x3.*y2)+(y2-y3).*x1+(x3-x2).*y1)/2,2);
      case 'radialcurl'
        %msh.area=1/2*(msh.lz(1,1)+msh.lz(1,2)).*mean(((x2.*y3-x3.*y2)+(y2-y3).*x1+(x3-x2).*y1)/2,2);
        msh.area=mean(msh.symmetry_info.extent).*mean(((x2.*y3-x3.*y2)+(y2-y3).*x1+(x3-x2).*y1)/2,2);
      otherwise
        error('Unknown shape-function type %s\n',msh.shape_function_type);
    end
    %msh.area=(msh.a(:,1)+msh.b(:,1).*x1(:,1)+msh.c(:,1).*y1(:,1))/2; % only valid when a,b,c refer to linear shape functions
    idx=find(msh.area<0);
    if ~isempty(idx)
      fprintf('The following elements have a negative area, possibly because of wrong node orientation\n   ');
      fprintf(' %d',idx);
      if 1
        figure(2); clf; trimesh(msh.elem(:,1:3),msh.node(:,1),msh.node(:,2),'Color','k');
        hold on; trimesh(msh.elem(idx,1:3),msh.node(:,1),msh.node(:,2),'Color','r');
        for ii=1:length(idx)
          k=msh.elem(idx(ii),1:3);
          cp(ii,1:2)=mean(msh.node(k,1:2),1);
          plot(msh.node(k,1),msh.node(k,2),'rx');
        end
        plot(cp(:,1),cp(:,2),'rd');
        axis equal; xlabel('x (m)'); ylabel('y (m)'); title('mesh');
      end
      error('\nFatal error\n\n');
    end
    
    switch msh.shape_function_type
      case 'linear'
        msh.depth=msh.lz*ones(numelem,1);
      case 'axicurl'
        msh.rav=mean(x1,2);
        msh.depth=2*pi*msh.rav;
      case 'radialcurl'
        msh.depth=diff(msh.symmetry_info.extent)*ones(numelem,1);
        msh.lz=ones(numelem,1)*msh.symmetry_info.extent;
        
      otherwise
        error('Unknown shape-function type %s\n',msh.shape_function_type);  
    end

    % D. Shape function coefficients
    switch msh.shape_function_type
      case 'linear'
        msh.a=x2.*y3-x3.*y2;
        msh.b=y2-y3;
        msh.c=x3-x2;
        msh.D=msh.area;
      case 'axicurl'
        msh.a=x2.^2.*y3-x3.^2.*y2;
        msh.b=y2-y3;
        msh.c=x3.^2-x2.^2;
        msh.D=sum(x2.^2.*y3-x3.^2.*y2,2)/2;
      case 'radialcurl'
%         msh.a=(z1+z2)/2.*(x2.*y3-x3.*y2); %_OLD WRONG EDGE SHAPE FUNCTION
        msh.a=(z2.^2-z1.^2)./(2*log(z2./z1)).*(x2.*y3-x3.*y2); %_NEW RIGHT EDGE SHAPE FUNCTION
        msh.b=y2-y3;
        msh.c=(z2.^2-z1.^2)./(2*log(z2./z1)).*(x3-x2);
        msh.D=msh.area;
      otherwise
        error('Unknown shape-function type %s\n',msh.shape_function_type);
    end
end
