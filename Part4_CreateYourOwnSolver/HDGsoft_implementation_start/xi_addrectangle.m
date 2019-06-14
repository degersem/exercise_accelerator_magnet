function center=xi_addrectangle(cd1,cd2,prp0,varargin)

% function center=xi_addrectangle(cd1,cd2,prp0,varargin)
% adds the nodes and segments of a rectangle and attaches properties to the segments
%
% input parameters
%    cd1               : [m,m]   : coordinate(s) of one of the corners
%    cd2               : [m,m]   : coordinate(s) of the diametrally opposite corner
%    prp0              :         : properties independent of the problem type
%    varargin          :         : additional properties dependent on the problem type
%
% output parameters
%    center            : [m,m]   : center(s) of the rectangle(s)
%
% short-cut for
%    xi_addnode + xi_addsegment

if ~exist('prp0','var')
  prp0=[];
end
if (size(cd1,1)~=size(cd2,1))
  error('unequal number of corner points');
end

xmin=min(cd1(:,1),cd2(:,1));   xmax=max(cd1(:,1),cd2(:,1));            % [m]   : minimal and maximal x-coordinate(s)
ymin=min(cd1(:,2),cd2(:,2));   ymax=max(cd1(:,2),cd2(:,2));            % [m]   : minimal and maximal y-coordinate(s)
cds=[ xmin ymin ; xmax ymin ; xmax ymax ; xmin ymax ];                     % [m,m] : all corner nodes
xi_addnode(cds,prp0,varargin{:});
xi_addsegment(cds,circshift(cds,[ size(cd1,1) 0 ]),prp0,varargin{:});
center=(cd1+cd2)/2;                                                        % [m,m] : center coordinate(s)
