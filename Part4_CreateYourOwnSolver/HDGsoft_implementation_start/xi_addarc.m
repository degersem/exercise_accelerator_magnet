function xi_addarc(cd1,cd2,angle,prp0,varargin)

% function XI_ADDARC(cd1,cd2,angle,prp0,varargin)
% adds arc segments and attaches properties to the arc segments
%
% input parameters
%    cd1               : [m,m]   : begin coordinates
%    cd2               : [m,m]   : end coordinates
%    angle     UNIT !! : [deg]   : angles
%    prp0              :         : properties independent of the problem type
%    varargin          :         : additional properties dependent on the problem type
%
% replacement for
%    mi_addarc(x1,y1,x2,y2,angle,maxseg)
%    ei_addarc(x1,y1,x2,y2,angle,maxseg)
%    hi_addarc(x1,y1,x2,y2,angle,maxseg)
%    ci_addarc(x1,y1,x2,y2,angle,maxseg)
%        Add a new arc segment from the nearest node
%        to (x1,y1) to the nearest node to (x2,y2) with angle ‘angle’ divided into ‘maxseg’ segments.
% and
%    mi_setarcsegmentprop(maxsegdeg,propname,hide,group)
%        Set the selected arc segments to:
%        – Meshed with elements that span at most maxsegdeg degrees per element
%        – Boundary property ’propname’
%        – hide: 0 = not hidden in post-processor, 1 == hidden in post processor
%        – A member of group number group
%    ei_setarcsegmentprop(maxsegdeg,propname,hide,group,inconductor)
%    hi_setarcsegmentprop(maxsegdeg,propname,hide,group,inconductor)
%    ci_setarcsegmentprop(maxsegdeg,propname,hide,group,inconductor)
%        Set the selected arc segments to:
%        - Meshed with elements that span at most maxsegdeg degrees per element
%        - Boundary property ’propname’
%        - hide: 0 = not hidden in post-processor, 1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string ’inconductor’. If the segment is not
%          part of a conductor, this parameter can be specified as ’<None>’.

if ~exist('prp0','var')
  prp0=[];
end
if size(cd1,1)~=size(cd2,1)
  error('unequal number of arc coordinates');
end
if length(angle)==1
  angle=angle*ones(size(cd1,1),1);
end
[center,R,a1,a2,selcd]=convert_arc_info(cd1,cd2,angle/180*pi);
global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'maxsegdeg',30),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.maxsegdeg=min(30,prp.hmesh./(2*pi*R)*360);
    elseif length(prp.maxsegdeg)==1
      prp.maxsegdeg=prp.maxsegdeg*ones(size(R));
    end
    for asg=1:size(cd1,1)
      mi_addarc(cd1(asg,1),cd1(asg,2),cd2(asg,1),cd2(asg,2),angle(asg),max(2,round(angle/30)));
      mi_selectarcsegment(selcd(asg,1),selcd(asg,2));
      mi_setarcsegmentprop(prp.maxsegdeg(asg),prp.propname,prp.hide,prp.groupno);
      mi_clearselected;
    end
  case {'electric','thermal','electrokinetic'}
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'maxsegdeg',30,'inconductor',0),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.maxsegdeg=min(30,prp.hmesh./(2*pi*R)*360);
    elseif length(prp.maxsegdeg)==1
      prp.maxsegdeg=prp.maxsegdeg*ones(size(R));
    end
    for asg=1:size(cd1,1)
      xi_wrap('addarc',cd1(asg,1),cd1(asg,2),cd2(asg,1),cd2(asg,2),angle(asg),max(2,round(angle/30)));
      xi_wrap('selectarcsegment',selcd(asg,1),selcd(asg,2));
      xi_wrap('setarcsegmentprop',prp.maxsegdeg(asg),prp.propname,prp.hide,prp.groupno,prp.inconductor);
      xi_clearselected;
    end
  otherwise
    error('Unknown problem type');
end
