function msh = mesh_flip_negative_elements(msh)

% function msh = mesh_flip_negative_elements(msh)
%     checks the areas of the elements and changes the order of the nodes of elements with negative areas
%
% input parameters
%       msh                   : 2D FE mesh
%           elem                    : [@]   : elem-to-node incidences
%           node                    : [@]   : nodal coordinates
%
% output parameters
%       msh                   : 2D FE mesh
%
% Author
%   Herbert De Gersem

% B. Shortcuts
numelem=size(msh.elem,1);
x1=reshape(msh.node(msh.elem(:,1:3),1),numelem,3);
y1=reshape(msh.node(msh.elem(:,1:3),2),numelem,3);
x2=circshift(x1,[0 -1]);
y2=circshift(y1,[0 -1]);
x3=circshift(x1,[0 -2]);
y3=circshift(y1,[0 -2]);

% C. Element area and depth
msh.area=mean(((x2.*y3-x3.*y2)+(y2-y3).*x1+(x3-x2).*y1)/2,2);
idx=find(msh.area<0);
msh.elem(idx,[1 2 3])=msh.elem(idx,[1 3 2]);
