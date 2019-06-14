function geometry_plot(gmy,mark,colour)

% function geometry_plot(gmy,mark,colour)
%   plots a 2D geometry and marks points, line segments and arc segments
%
% Inputs
%    gmy              : 2D geometry
%    mark             : structure indicating which elements/edges/nodes should be marked (optional; default: no marks)
%        geometry         : [1/0]: plot geometry or not (optional; default: 1)
%        points           : [@]  : indices of the points to be marked (use inf for marking all points)
%        segments         : [@]  : indices of the line segments to be marked (use inf for marking all segments)
%        arcsegments      : [@]  : indices of the arc segments to be marked (use inf for marking all arc segments)
%        pointnumbers     : [@]  : indices of the points to be numbered (use inf for numbering all points)
%        segmentnumbers   : [@]  : indices of the segments to be numbered (use inf for numbering all segments)
%        arcsegmentnumbers: [@]  : indices of the arc segments to be numbered (use inf for numbering all arc segments)
%    colour           : colour (optional; default: black)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('mark','var')
  mark=struct('geometry',1);
end
if ~isfield(mark,'geometry')
  mark.geometry=1;
end
if ~exist('colour','var')
  colour='k';
end

% A. Plot line segments
if mark.geometry
  geometry_plot_linesegments(gmy.segments,gmy.points,colour);
  axis equal; axis off; hold on;
  % B. Plot arc segments
  D=max(pyth(gmy.points(:,1:2)-ones(size(gmy.points,1),1)*gmy.points(1,1:2))); % [m]    : measure for the extend of the model
  geometry_plot_arcsegments(gmy.arcsegments,colour);
end
% C. Marking points, line segments and arc segments
if isfield(mark,'points')
  if isinf(mark.points)
    pt=1:size(gmy.points,1);
  else
    pt=mark.points;
  end
  plot(gmy.points(pt,1),gmy.points(pt,2),[colour 'o']);
end
if isfield(mark,'segments')
  if isinf(mark.segments)
    sg=1:size(gmy.segments,1);
  else
    sg=mark.segments;
  end
  pt1=gmy.segments(sg,1);
  pt2=gmy.segments(sg,2);
  line([gmy.points(pt1,1)' ; gmy.points(pt2,1)'],[gmy.points(pt1,2)' ; gmy.points(pt2,2)'],'Color',colour);
end
if isfield(mark,'arcsegments')
  warning('Marking arc segments is not yet implemented\n');
  % jobstudent
end
% C. Numbering points, line segments and arc segments
if isfield(mark,'pointnumbers')
  if isinf(mark.pointnumbers)
    pt=1:size(gmy.points,1);
  else
    pt=mark.pointnumbers;
  end
  for i=1:length(pt)
    text(gmy.points(pt(i),1),gmy.points(pt(i),2),int2str(pt(i)));
  end
end
if isfield(mark,'segmentnumbers')
  if isinf(mark.segmentnumbers)
    sg=1:size(gmy.segments,1);
  else
    sg=mark.segmentnumbers;
  end
  pt=gmy.segments(sg,1:2);
  for i=1:length(sg)
    text(mean(gmy.points(pt(i,:),1)),mean(gmy.points(pt(i,:),2)),int2str(sg(i)));
  end
end
if isfield(mark,'arcsegmentnumbers')
  warning('plotting arc segment numbers not yet implemented');
  % jobstudent
end
