function hdl=viewequi(prb,solu,numequi,options)

% function VIEWEQUI(prb,solu,numequi,options)
% plots equipotential lines for a nodal-based field distribution
%
% input parameters
%       prb                          : FEMM problem-data structure
%       solu                         : nodal-based field distribution (numnode-by-1)
%       numequi                      : number of equipotential lines (optional; default: 24)
%       options                      : plot options (optional; default values, see below)
%           numequi       24         : number of equipotential lines
%           elemmask      []         : element mask
%           nodemask      []         : node mask
%           color         'b'        : color
%           range         []         : range for the equipotential lines
%           distribution  []         : distribution of the equipotential lines
%           node                     : nodal coordinates (for creating deformed plots)
%
% output parameters
%       hdl                          : handle
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Default parameters
numelem=size(prb.mesh.elem,1);
numnode=size(prb.mesh.node,1);

% B. Parameter control
if ~exist('solu','var')
  solu=prb.mesh.node(:,3);
end
if ~exist('numequi','var')
  numequi=24;
end
if ~exist('options','var')
  options.numequi=numequi;             % number of equipotential lines
end
if ~isfield(options,'elemmask')
  options.elemmask=[];                 % element mask
end
if ~isfield(options,'nodemask')
  options.nodemask=[];                 % node mask
end
if ~isfield(options,'color')
  options.color='b';                   % color
end
if ~isfield(options,'range')
  options.range=[];                    % range for the equipotential lines
end
if ~isfield(options,'distribution')
  options.distribution=[];             % distribution of the equipotential lines
end
if ~isfield(options,'node')
  options.node=prb.mesh.node;          % nodal coordinates
end

% C. Final
if isempty(options.elemmask)
  options.elemmask=1:numelem;
  options.nodemask=1:numnode;
elseif isempty(options.nodemask)
  options.nodemask=unique(reshape(prb.mesh.elem(options.elemmask,:)),[],1);
end

% D. Determine the range and distribution of the equipotential lines
distribution=options.distribution;
if isempty(distribution)
  if isempty(options.range)
    options.range=[min(real(solu(options.nodemask,:))) max(real(solu(options.nodemask,:)))];
  end
  sdff=diff(options.range)/options.numequi/3;
  distribution=linspace(options.range(1)+sdff,options.range(2)-sdff,options.numequi)';
else
  options.numequi=length(distribution);
end

% E. Plot equipotential lines
store_x=zeros(2,0);
store_y=zeros(2,0);
for q=1:length(options.elemmask)
  k=options.elemmask(q);
  px=options.node(prb.mesh.elem(k,:),1);
  py=options.node(prb.mesh.elem(k,:),2);
  ps=real(solu(prb.mesh.elem(k,:)));
  minps=min(ps);
  maxps=max(ps);
  for e=1:options.numequi
    if ((distribution(e) >= minps) & (distribution(e) <= maxps))
      num=0;
      for p1=1:3
        p2=rem(p1,3)+1;
        p3=rem(p2,3)+1;
        s=sort([ps(p1); ps(p2)]);
        if ((distribution(e) >= s(1)) && (distribution(e) <= s(2)))
          num=num+1;
          if ps(p1)~=ps(p2)
            x(num,:)=interp1([ps(p1); ps(p2)],[px(p1); px(p2)],distribution(e));
            y(num,:)=interp1([ps(p1); ps(p2)],[py(p1); py(p2)],distribution(e));
          else
            x(num,:)=mean([px(p1) px(p2)]);
            y(num,:)=mean([py(p1) py(p2)]);
          end
        end
      end
      if (num==2)
        store_x=[store_x x(1:2,:)];
        store_y=[store_y y(1:2,:)];
      end
    end
  end
end
hdl=line(store_x,store_y,'Color',options.color);
hold off
axis('equal');
axis('off');

