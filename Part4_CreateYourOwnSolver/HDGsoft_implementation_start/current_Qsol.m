function [Qsol,Gsol,Xsol] = current_Qsol(prb,sigma)

% function [Qsol,Gsol,Xsol] = current_Qsol(prb,sigma)
%   computes the coupling block for solid conductors e.g. for solid conductor q:
%       \int_{Vsolq} \frac{\sigma}{\ell_z}\vec{e}_z\cdot\vec{w}_i \udV
%
% Inputs
%    prb        : 2D FE problem data structure
%    sigma      : [S/m] : element-wise constant conductivity
%
% Outputs
%    Qsol       : [S]   : coupling blocks for solid conductors
%    Gsol       : [S]   : DC conductance of the solid conductors
%    Xsol       : []    : incidence matrix between global voltage drop and the voltages at the primary edges
%
% See also
%   divgrad, curlcurl, curlcurl_nonlinear, current_load
%
% Author
%   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

numnode=size(prb.mesh.node,1);                                             % [#]  : number of FE nodes
numelem=size(prb.mesh.elem,1);                                             % [#]  : number of FE elements
numregi=size(prb.region,1);                                                % [#]  : number of regions
numwire=length(prb.wire);                                                  % [#]  : number of wires
Qsol=sparse(numnode,numwire);
Gsol=zeros(numwire,1);
Xsol=sparse(numnode,numwire);
switch prb.mesh.shape_function_type
  case 'linear'
    for k=1:numelem
      rg=prb.mesh.elem(k,4);
      wr=prb.region(rg,5);
      if wr~=0
        idx=prb.mesh.elem(k,1:3);
        Qsol(idx,wr)=Qsol(idx,wr)+ones(3,1)*sigma(k,1)/prb.mesh.depth(k)*prb.mesh.area(k)/3;
        Gsol(wr,1)=Gsol(wr,1)+sigma(k,1)/prb.mesh.depth(k)*prb.mesh.area(k);
        Xsol(idx,wr)=1;
      end
    end
  case 'axicurl'
    [weights,localcds]=gauss_triangle(prb.mesh.integration_order);
    numgauss=length(weights);
    for k=1:numelem
      rg=prb.mesh.elem(k,4);
      wr=prb.region(rg,5);
      if wr~=0
        idx=prb.mesh.elem(k,1:3);
        r=localcds*prb.mesh.node(idx,1);
        z=localcds*prb.mesh.node(idx,2);
        Nrz=(ones(numgauss,1)*prb.mesh.a(k,:)+r.^2*prb.mesh.b(k,:)+z*prb.mesh.c(k,:))/(2*prb.mesh.D(k));
        elemQsol=zeros(3,1);
        elemGsol=0;
        for gp=1:numgauss
          elemQsol=elemQsol+weights(gp)*sigma(k,1)*Nrz(gp,:)'/(2*pi*r(gp))*prb.mesh.area(k);
          elemGsol=elemGsol+weights(gp)*sigma(k,1)/(2*pi*r(gp))*prb.mesh.area(k);
        end
        Qsol(idx,wr)=Qsol(idx,wr)+elemQsol;
        Gsol(wr,1)=Gsol(wr,1)+elemGsol;
        Xsol(idx,wr)=1;
      end
    end
  case 'radialcurl'
    error('implement!');
  otherwise
    error('Unknown shape-function type %s\n',prb.mesh.shape_function_type);

end

% % OBSOLETE VERSION
% numnode=size(prb.node,1);                             % [#]   : number of FE nodes
% numelem=size(prb.elem,1);                             % [#]   : number of FE elements
% numcirc=size(Xstr,1);                                 % [#]   : number of circuits
% idxelem2circ=prb.blocklabels(prb.elem(:,4),5);        % [@]   : indices of the circuits
% Pstr=zeros(numnode,size(Xstr,2));
% [a,b,c,area,r,z]=linear_shape_functions(prb);
% for bl=1:size(prb.blocklabels,1)
%   blockarea(bl)=sum(area(find(prb.elem(:,4)==bl)));
% for wr=1:numcirc
%   circarea(wr)=sum(area(find(idxelem2circ==wr)));
% end
% for k=1:numelem
%   wr=idxelem2circ(k);
%   if wr~=0
%     idx=prb.elem(k,1:3);
%     Pstr(idx,:)=Pstr(idx,:)+ones(3,1)*Xstr(wr,:)/circarea(wr)*area(k)/3; % HDG: use wr instead of :
%   end
% end
