function viewprop(prb,prop,options)

% function viewprop(prb,prop,options)
% plots the magnitude of element properties
%
% input parameters
%       prb       : 2D FEMM problem
%       prop      : properties (one per element)
%       options                      : plot options (optional; default values, see below)
%           elemmask      []         : element mask
%           nodemask      []         : node mask
%           range         []         : range for the equipotential lines
%           node                     : nodal coordinates (for creating deformed plots)
%           colorbar      [1/0]      : colorbar or not (optional; default: 1)
%
% output parameters
%       none
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter Check
numelem=size(prb.mesh.elem,1);
numnode=size(prb.mesh.node,1);
if ~exist('options','var')
  options.elemmask=[];                 % element mask
end
if ~isfield(options,'elemmask')
  options.elemmask=[];                 % element mask
end
if ~isfield(options,'range')
  options.range=[];                    % range for the equipotential lines
end
if ~isfield(options,'node')
  options.node=prb.mesh.node;          % nodal coordinates
end
if ~isfield(options,'colorbar')
  options.colorbar=1;
end
if isempty(options.elemmask)
  options.elemmask=1:numelem;
end

% B. Plot
x=prb.mesh.node(:,1); elemx=transpose(x(prb.mesh.elem(options.elemmask,[1 2 3 1])));
y=prb.mesh.node(:,2); elemy=transpose(y(prb.mesh.elem(options.elemmask,[1 2 3 1])));
if ~isempty(options.range)
  maxprop=max(options.range); prop(find(prop>maxprop),1)=maxprop;
  minprop=min(options.range); prop(find(prop<minprop),1)=minprop;
end
switch length(prop)
  case numelem
    elemp=transpose([prop prop prop prop]);
  case numnode
    elemp=transpose(prop(prb.mesh.elem(:,[1 2 3 1])));
  otherwise
    error('Unrecognised size of property vector\n');
end
fill(elemx,elemy,elemp(:,options.elemmask),'LineStyle','none'); colormap('default'); %cm=colormap('gray'); colormap(flipud(cm));
%fill3(elemx,elemy,elemp,elemp);
%view(2);
axis('equal'); axis('off');
% colormat=[zeros(32,1) linspace(0,1,32)' linspace(1,0,32)';linspace(1/31,1,31)' linspace(30/31,0,31)' zeros(31,1)];
% colormap(colormat);
if options.colorbar
  colorbar('vert');
end

% numelem=size(prb.mesh.elem,1);
% numnode=size(prb.mesh.node,1);
% n=0;
% for k=1:numelem
%   x1=prb.mesh.node(prb.mesh.elem(k,1),1);
%   x2=prb.mesh.node(prb.mesh.elem(k,2),1);
%   x3=prb.mesh.node(prb.mesh.elem(k,3),1);
%   y1=prb.mesh.node(prb.mesh.elem(k,1),2);
%   y2=prb.mesh.node(prb.mesh.elem(k,2),2);
%   y3=prb.mesh.node(prb.mesh.elem(k,3),2);
%   n=n+1;
%   elemx(1,n)=x1;
%   elemx(2,n)=x2;
%   elemx(3,n)=x3;
%   elemx(4,n)=x1;
%   elemy(1,n)=y1;
%   elemy(2,n)=y2;
%   elemy(3,n)=y3;
%   elemy(4,n)=y1;
%   Bmag(1,n)=prop(k,1);
%   Bmag(2,n)=prop(k,1);
%   Bmag(3,n)=prop(k,1);
%   Bmag(4,n)=prop(k,1);
% end
% fill(elemx,elemy,Bmag,'LineStyle','none');
% cm=colormap('gray'); colormap(flipud(cm));
% %fill3(elemx,elemy,Bmag,Bmag);
% %view(2);
% axis('equal');
% axis('off');
% %colormat=[zeros(32,1) linspace(0,1,32)' linspace(1,0,32)';linspace(1/31,1,31)' linspace(30/31,0,31)' zeros(31,1)];
% %colormap(colormat);
% colorbar('vert');
