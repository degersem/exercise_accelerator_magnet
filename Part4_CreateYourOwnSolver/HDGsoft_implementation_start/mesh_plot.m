function mesh_plot(msh,mark,restrict2,colour)

% function mesh_plot(msh,mark,restrict2,colour)
%   plots (parts of) a FE mesh and marks elements, edges and nodes
%
% Inputs
%    msh              : 2D FE mesh
%    mark             : structure indicating which elements/edges/nodes should be marked (optional; default: no marks)
%        elem           : [@]  : indices of the elements to be marked
%        edge           : [@]  : indices of the edges to be marked
%        node           : [@]  : indices of the nodes to be marked
%    restrict2        : structure indicating to which elements the mesh plot should be restricted (optional; default: all elements)
%        elem           : [@]  : indices of the elements to be plotted
%    colour           : colour (optional; default: black)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('mark','var')
  mark=[];
end
if ~exist('restrict2','var')
  restrict2=[];
end
if ~exist('colour','var')
  colour='k';
end

if isfield(msh,'elem')
  idxelem=1:size(msh.elem,1);
  if ~isempty(restrict2)
    if isfield(restrict2,'elem')
      idxelem=intersect(idxelem,restrict2.elem);
    end
  end
  trimesh(msh.elem(idxelem,1:3),msh.node(:,1),msh.node(:,2),'Color',colour); axis equal; axis off;
end
if ~isempty(mark)
  if isfield(msh,'elem') & isfield(mark,'elem')
    nd1=msh.elem(mark.elem,1);
    nd2=msh.elem(mark.elem,2);
    nd3=msh.elem(mark.elem,3);
    hold on; fill([msh.node(nd1,1)' ; msh.node(nd2,1)' ; msh.node(nd3,1)'],[msh.node(nd1,2)' ; msh.node(nd2,2)' ; msh.node(nd3,2)'],'y');
  end
  if isfield(msh,'edge') & isfield(mark,'edge')
    nd1=msh.edge(mark.edge,1);
    nd2=msh.edge(mark.edge,2);
    hold on; line([msh.node(nd1,1)' ; msh.node(nd2,1)'],[msh.node(nd1,2)' ; msh.node(nd2,2)'],'Color','m');
  end
  if isfield(mark,'node')
    nd=mark.node;
    hold on; plot(msh.node(nd,1),msh.node(nd,2),'rx');
  end

end
