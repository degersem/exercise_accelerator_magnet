function xi_addcircle(cd,r,blockname,prpblock,prparcsegment)

% function xi_addcircle(cd,r,blockname,prpblock,prparcsegment)
% adds a circle to the FEMM drawing
%
% input parameters
%    cd        : [m,m]  : coordinate of the center point
%    r         : [m]    : radius
%    blockname :        : block name (optional; default '#')
%                       : use '#' for suppressing the definition of a block
%                       : use '<No Mesh>' for making a mesh hole
%    prpblock           : properties for the block (optional; default [])
%    prparcsegment      : properties for the arc segments (optional; default [])
%
% output parameters
%    none
%
% incorporates
%    xi_addnode
%    xi_addarc
%    xi_addblocklabel
%
% replacement for
%    mi_setarcsegmentprop(maxsegdeg,propname,hide,group)
%        Set the selected arc segments to:
%        – Meshed with elements that span at most maxsegdeg degrees per element
%        – Boundary property ’propname’
%        – hide: 0 = not hidden in post-processor, 1 == hidden in post processor
%        – A member of group number group
%    ei_setarcsegmentprop(maxsegdeg,propname,hide,group,inconductor)
%        Set the selected arc segments to:
%        - Meshed with elements that span at most maxsegdeg degrees per element
%        - Boundary property ’propname’
%        - hide: 0 = not hidden in post-processor, 1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string ’inconductor’. If the segment is not
%          part of a conductor, this parameter can be specified as ’<None>’.
%    hi_setarcsegmentprop(maxsegdeg,propname,hide,group,inconductor)
%        Set the selected arc segments to:
%        - Meshed with elements that span at most maxsegdeg degrees per element
%        - Boundary property ’propname’
%        - hide: 0 = not hidden in post-processor, 1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string ’inconductor’. If the segment is not
%          part of a conductor, this parameter can be specified as ’<None>’.
%    ci_setarcsegmentprop(maxsegdeg,propname,hide,group,inconductor)
%        Set the selected arc segments to:
%        - Meshed with elements that span at most maxsegdeg degrees per element
%        - Boundary property ’propname’
%        - hide: 0 = not hidden in post-processor, 1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string ’inconductor’. If the segment is not
%          part of a conductor, this parameter can be specified as ’<None>’.

if ~exist('blockname','var')
  blockname='#';
end
if ~exist('prpblock','var')
  prpblock=[];
end
if ~exist('prparcsegment','var')
  prparcsegment=[];
end
if size(cd,1)==1
  if length(r)~=1
    cd=ones(length(r),1)*cd;
  end
elseif length(r)==1
  r=ones(size(cd,1))*r;
elseif length(r)~=size(cd,1)
  error('number of centre coordinates does not match the number of radii\n');
end

for q=1:length(r)
  xi_addnode(cd(q,:)+[r(q) 0]);
  xi_addnode(cd(q,:)-[r(q) 0]);
  xi_addarc(cd(q,:)+[r(q) 0],cd(q,:)-[r(q) 0],180,prparcsegment);
  xi_addarc(cd(q,:)-[r(q) 0],cd(q,:)+[r(q) 0],180,prparcsegment);
  if ~strcmp(blockname,'#')
    xi_addblocklabel(cd(q,:),blockname,prpblock);
  end
end
