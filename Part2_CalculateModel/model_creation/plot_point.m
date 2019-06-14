function plot_point(point)

% function PLOT_POINT(point)
% draws all points with their numbers such that connecting with edges and arcs becomes feasible
%
% input parameters
%    point       : point coordinates (numpoint-by-2 vector)
%
% see also

modifier=sprintf('%%%dd',ceil(log10(length(point))));
for i=1:length(point)
  ptnum(i,:)=sprintf(modifier,i);
end
text(point(:,1),point(:,2),ptnum);
axis([min(point(:,1)) max(point(:,1)) min(point(:,2)) max(point(:,2))]);
axis off;
