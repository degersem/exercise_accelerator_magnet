function geometry_plot_linesegments(segments,points,colour)

% function geometry_plot_linesegments(segments,points,colour)
%   plots line segments
%
% Inputs
%    segments         : line segments
%    points           : points
%    colour           : colour (optional; default: black)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('colour','var')
  colour='k';
end

pt1=segments(:,1);
pt2=segments(:,2);
line([points(pt1,1)' ; points(pt2,1)'],[points(pt1,2)' ; points(pt2,2)'],'Color',colour);
