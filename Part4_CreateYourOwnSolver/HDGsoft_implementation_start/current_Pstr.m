function [Pstr,Rstr] = current_Pstr(prb,sigma)%,Wstr)

% function [Pstr,Rstr] = current_Pstr(prb,sigma)%,Wstr)
%   computes the coupling blocks for stranded conductors
%
% Inputs
%    prb        : 2D FE problem data structure
%    sigma      : [S/m] : conductivity (one per element)
%    Wstr       : (obsolete) connection matrix (if all coils are disconnected, use diag(Nstr) where Nstr are the number of turns)
%               : represents the connection between the individual wires in the model and the excitations
%               : (if all coils are disconnected, use diag(Nstr) where Nstr are the number of turns)
%
% Outputs
%    Pstr       : []    : coupling blocks for stranded conductors (in the theory, we use Xstr=Pstr)
%    Rstr       : [Ohm] : resistance of the stranded conductors
%
% See also
%   divgrad, curlcurl, curlcurl_nonlinear, current_load
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

numnode=size(prb.mesh.node,1);                                             % [#]  : number of FE nodes
numelem=size(prb.mesh.elem,1);                                             % [#]  : number of FE elements
numregi=size(prb.region,1);                                                % [#]  : number of regions
numwire=length(prb.wire);                                                  % [#]  : number of wires (do you mean ellectric circuit)?

if ~exist('sigma','var')
  if nargout>=2
    error('For calculating the resistance of the stranded conductors, one needs to supply conductivity-per-element data');
  else
    sigma=ones(numelem,1);
  end
end
if size(sigma)~=[numelem 0]
  error('You are possible using an obsolete version of current_Pstr.m (type ''help current_Pstr'')');
end

for rg=1:numregi
  regionarea(rg)=sum(prb.mesh.area(find(prb.mesh.elem(:,4)==rg)));         % DVO Note for the radial case the region area is determined by the elementary ellement Se. Meaning the reqionarea is alread scaled with a factor rvis/((r1+r1)/2) and not deteremind from the FEMM model with a radius rvis
  mt=prb.region(rg,3);                                                     % [@]  : material identifiers
  Nt=prb.region(rg,8);                                                     % [#]  : Number of turns
  if prb.material(mt).wireD~=0
    fillfactor(rg)=Nt*pi*(prb.material(mt).wireD/2)^2/regionarea(rg);      % [] : fill factor
  else
    fillfactor(rg)=1;
  end
end
Pstr=sparse(numnode,numwire);
Rstr=zeros(numwire,1);
switch prb.mesh.shape_function_type
  case 'linear'
    for k=1:numelem
      rg=prb.mesh.elem(k,4);                                               % [@]  : region identifier
      mt=prb.region(rg,3);                                                 % [@]  : material identifier
      wr=prb.region(rg,5);                                                 % [@]  : circuit identifier
      Nt=prb.region(rg,8);                                                 % [#]  : number of turns 
      if wr~=0
        idx=prb.mesh.elem(k,1:3);
        Pstr(idx,wr)=Pstr(idx,wr)+ones(3,1)*Nt/regionarea(rg)*prb.mesh.area(k)/3;
        Rstr(wr,1)=Rstr(wr,1)+(Nt/regionarea(rg))^2*prb.mesh.depth(k)/(sigma(k,1)*fillfactor(rg))*prb.mesh.area(k);
      end
    end
  case 'axicurl'
    [weights,localcds]=gauss_triangle(prb.mesh.integration_order);
    numgauss=length(weights);
    for k=1:numelem
      rg=prb.mesh.elem(k,4);
      wr=prb.region(rg,5);
      Nt=prb.region(rg,8);
      if wr~=0
        idx=prb.mesh.elem(k,1:3);
%         r=localcds*prb.mesh.node(idx,1);
%         z=localcds*prb.mesh.node(idx,2);
%         Nrz=(ones(numgauss,1)*prb.mesh.a(k,:)+r.^2*prb.mesh.b(k,:)+z*prb.mesh.c(k,:))/(2*prb.mesh.D(k));
%         elemPstr=zeros(3,1);
%         for gp=1:numgauss
%           elemPstr=elemPstr+Nt/regionarea(rg)*weights(gp)*Nrz(gp,:)'/(2*pi*r(gp))*prb.mesh.area(k);
%         end
%         Pstr(idx,wr)=Pstr(idx,wr)+elemPstr;
%         Rstr(wr,1)=Rstr(wr,1)+(Nt/regionarea(rg))^2*(2*pi*prb.mesh.rav(k))/(sigma(k,1)*fillfactor(rg))*prb.mesh.area(k);
        % previous implementation (possibly wrong)
        r=prb.mesh.node(idx,1);
        z=prb.mesh.node(idx,2);
        rav2=(r'*r+r'*circshift(r,1))/6;
        zav=mean(z);
        Pstr(idx,wr)=Pstr(idx,wr)+Nt/regionarea(rg)* ...
          transpose(prb.mesh.a(k,:)+prb.mesh.b(k,:)*rav2+prb.mesh.c(k,:)*zav) ...
          *prb.mesh.area(k)./(2*transpose(prb.mesh.D(k,:)));
        Rstr(wr,1)=Rstr(wr,1)+(Nt/regionarea(rg))^2*(2*pi*prb.mesh.rav(k))/(sigma(k,1)*fillfactor(rg))*prb.mesh.area(k)/3;
      end
    end
  case 'radialcurl'
    for k=1:numelem
      rg=prb.mesh.elem(k,4);                                               % [@]  : region identifier
      mt=prb.region(rg,3);                                                 % [@]  : material identifier
      wr=prb.region(rg,5);                                                 % [@]  : circuit identifier
      Nt=prb.region(rg,8);                                                 % [#]  : number of turns 
      if wr~=0                                                             % If there is a electric circuit coupeled to this ellement
          idx=prb.mesh.elem(k,1:3);
          Pstr(idx,wr)=Pstr(idx,wr)+ones(3,1)*Nt/regionarea(rg)*prb.mesh.area(k)/3; %DVO the term radsymminfo.rvis/((radsymminfo.r1+radsymminfo.r2)/2) is not implementated, due do the fact that reqionarea is already scaled in line 40
          Rstr(wr,1)=Rstr(wr,1)+(Nt/regionarea(rg))^2*prb.mesh.depth(k)/(sigma(k,1)*fillfactor(rg))*prb.mesh.area(k);                           
      end
    end
  otherwise
    error('Unknown shape-function type %s\n',mesh.shape_function_type);
end
idxi=find(prb.mesh.node(:,4));
for iii=1:length(idxi)
  i=idxi(iii);
  pt=prb.mesh.node(i,4);
  wr=prb.geometry.points(pt,5);
  if wr~=0
    Pstr(i,wr)=Pstr(i,wr)+1;
  end
end

% % OBSOLETE VERSION
% numnode=size(prb.node,1);                             % [#]   : number of FE nodes
% numelem=size(prb.elem,1);                             % [#]   : number of FE elements
% numcirc=size(Wstr,1);                                 % [#]   : number of circuits
% idxelem2circ=prb.blocklabels(prb.elem(:,4),5);        % [@]   : indices of the circuits
% Pstr=zeros(numnode,size(Wstr,2));
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
%     Pstr(idx,:)=Pstr(idx,:)+ones(3,1)*Wstr(wr,:)/circarea(wr)*area(k)/3; % HDG: use wr instead of :
%   end
% end
