function xi_addellips(center, ab, segment, prp0, varargin)

% function center=xi_addellips(center, ab, segment, prp0, varargin)
% adds the nodes and segments of an ellips (or segment of an ellips) and attaches properties to the segments
%
% input parameters
%    center               : [m,m]       : coordinate(s) of the center
%    ab                   : [m,m]       : length of the two axes
%    segment              : [radials]   : segment of the ellips in radials (pi/2, pi, 3*pi/2 or 2*pi)
%    prp0                 :             : properties independent of the problem type
%    varargin             :             : additional properties dependent on the problem type
%
% short-cut for
%    xi_addnode + xi_addsegment

if ~exist('prp0','var')
  prp0=[];
end
if ~exist('segment')
    segment=2*pi;
end
if isfield(prp0,'hmesh')
    hmesh=prp0.hmesh;
else
    hmesh=0.1;
end
a=max(ab);
b=min(ab);
t=linspace(0,segment,max(5,ceil((segment*a/2)/hmesh)));
t=linspace(0,segment,max(5,ceil((segment*a/2)/hmesh)));
x0=center(:,1);
x0 = x0(:,ones(1,length(t))).';
x0 = x0(:);
y0=center(:,2);
y0 = y0(:,ones(1,length(t))).';
y0 = y0(:);
x=repmat(a/2*cos(t),1,size(center,1));
y=repmat(b/2*sin(t),1,size(center,1));
x=x'+x0;
y=y'+y0;
cd=[x y];
xi_addnode(cd,prp0,varargin{:});
if abs((segment-2*pi)/2*pi)<1e-3
    for i=1:size(center,1)
        xi_addsegment(cd((i-1)*length(t)+1:i*length(t),:),circshift(cd((i-1)*length(t)+1:i*length(t),:),[1 0]),prp0,varargin{:});
    end
elseif abs((segment-pi/2)/2*pi)<1e-3 || abs((segment-3*pi/2)/2*pi)<1e-3 || abs((segment-pi)/2*pi)<1e-3
    for i=1:size(center,1)
        xi_addsegment(cd((i-1)*length(t)+1:i*length(t)-1,:),cd((i-1)*length(t)+2:i*length(t),:),prp0,varargin{:});
    end
else
    error('Invalid segment');
end

end
