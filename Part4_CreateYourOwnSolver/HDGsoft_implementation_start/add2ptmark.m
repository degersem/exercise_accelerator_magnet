function ptmark=add2ptmark(ptmark,pt1,pt2)

% function ptmark=add2ptmark(ptmark,pt1,pt2)
% keeps a list of marks for all points. The marks indicate sets of points that are connected to each other
%
% input parameters
%    ptmark             : []   : marks for all points
%    pt1                : [@]  : newly encountered points at the slave side
%    pt2                : [@]  : newly encountered points at the master side
%
% output parameters
%    ptmark             : []   : updated marks
%
% entire point mark list 'ptmark'
%    * initially all zero
%    * a point gets a nonzero mark when it is encountered as end point
%      of a line or arc segment affected by binary boundary conditions
%
% partial point mark lists 'mark1' and 'mark2'
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

mark1=ptmark(pt1);
% if min(mark1)<0       % interchange pt1 and pt2
%   mark2=mark1;
%   mark1=ptmark(pt2);
%   pt3=pt2; pt2=pt1; pt1=pt3;
%   if min(mark1)<0
%     error('3 possibly binary condition coinciding at a single node, change in dirichlet or neumann');
%   end
% else
  mark2=ptmark(pt2);
%   if min(mark2)>0
%     error('3 possibly binary condition coinciding at a single node, change in dirichlet or neumann');
%   end
% end
if length(mark1)~=length(mark2)
  error('1');
end
if nnz(mark1)~=nnz(mark2)
  error('2');
end
% HDG, 19.09.2012, debugging for DVO
% if any(mark1~=-mark2)
%   error('3 possibly binary condition coinciding at a single node, change in dirichlet or neumann');
% end
idx=find(mark1);
if isempty(idx)                   % no slave or master points have been marked yet
  mk=max(ptmark)+1;               % [$]   : new and unique marker
  ptmark(pt1)=+mk;
  ptmark(pt2)=-mk;
else                              % at least one point marked at both sides, choose a reference marker and propagate
  mk=mark1(idx(1));               % [$]   : reference marker
%   if (mk>0) & any(mark2>0)
%     error('5');
%   elseif (mk<0) & any(mark2<0)
%     error('6');
%   end
  ptmark(pt1)=+mk;
  ptmark(pt2)=-mk;
  for qq=2:length(idx)
    if mark1(idx(qq))~=mk
      i=find(ptmark==mark1(idx(qq)));
      ptmark(i)=+mk;
      i=find(ptmark==mark2(idx(qq)));
      ptmark(i)=-mk;
    end
  end
end
