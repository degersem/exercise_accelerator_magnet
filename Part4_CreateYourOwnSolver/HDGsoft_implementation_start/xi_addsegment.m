function xi_addsegment(cd1,cd2,prp0,varargin)

% function XI_ADDSEGMENT(cd1,cd2,prp0,varargin)
% adds segments and attaches properties to the segments
%
% input parameters
%    cd1               : [m,m]   : begin coordinates
%    cd2               : [m,m]   : end coordinates
%    prp0              :         : properties independent of the problem type
%    varargin          :         : additional properties dependent on the problem type
%
% replacement for
%    mi_addsegment(x1,y1,x2,y2)
%        Add a new line segment from node closest to (x1,y1) to node closest to (x2,y2)
%    ei_addsegment(x1,y1,x2,y2)
%        Add a new line segment from node closest to (x1,y1) to node closest to (x2,y2)
%    hi_addsegment(x1,y1,x2,y2)
%        Add a new line segment from node closest to (x1,y1) to node closest to (x2,y2)
%    ci_addsegment(x1,y1,x2,y2)
%        Add a new line segment from node closest to (x1,y1) to node closest to (x2,y2)
% and
%    mi_setsegmentprop(propname,hmesh,automesh,hide,groupno)
%        Set the selected segments to have:
%        – Boundary property propname
%        – Local element size along segment no greater than hmesh
%        – automesh: 0 = mesher defers to the element constraint defined by elementsize,
%                    1 = mesher automatically chooses mesh size along the selected segments
%        – hide:     0 = not hidden in post-processor,
%                    1 == hidden in post processor
%        – A member of group number group
%    ei_setsegmentprop(propname,hmesh,automesh,hide,groupno,inconductor)
%        Set the select segments to have:
%        - Boundary property propname
%        - Local element size along segment no greater than hmesh
%        - automesh: 0 = mesher defers to the element constraint defined by elementsize,
%                    1 = mesher automatically chooses mesh size along the selected segments
%        - hide:     0 = not hidden in post-processor,
%                    1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string ’inconductor’. If the segment is not
%          part of a conductor, this parameter can be specified as ’<None>’.
%     hi_setsegmentprop(propname,elementsize,automesh,hide,group,inconductor)
%        Set the select segments to have:
%        - Boundary property "propname"
%        - Local element size along segment no greater than elementsize
%        - automesh: 0 = mesher defers to the element constraint defined by elementsize,
%                    1 = mesher automatically chooses mesh size along the selected segments
%        - hide:     0 = not hidden in post-processor,
%                    1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string "inconductor". If the segment is not
%          part of a conductor, this parameter can be specified as "<None>".
%     ci_setsegmentprop(propname,elementsize,automesh,hide,group,inconductor)
%        Set the select segments to have:
%        - Boundary property "propname"
%        - Local element size along segment no greater than elementsize
%        - automesh: 0 = mesher defers to the element constraint defined by elementsize,
%                    1 = mesher automatically chooses mesh size along the selected segments
%        - hide:     0 = not hidden in post-processor,
%                    1 == hidden in post processor
%        - A member of group number group
%        - A member of the conductor specified by the string "inconductor". If the segment is not
%          part of a conductor, this parameter can be specified as "<None>".

if ~exist('prp0','var')
  prp0=[];
end
if (size(cd1,1)~=size(cd2,1))
  error('unequal number of line end points');
end
selcd=(cd1+cd2)/2;                                                         % [m,m]  : coordinates for selecting the line segments
global xa_formulation;
switch xa_formulation.problemtype
  case 'magnetic'
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.automesh=0;
    else
      prp.automesh=1;
      prp.hmesh=0;
    end
    for sg=1:size(cd1,1)
      mi_addsegment(cd1(sg,1),cd1(sg,2),cd2(sg,1),cd2(sg,2));
      mi_selectsegment(selcd(sg,1),selcd(sg,2));
      mi_setsegmentprop(prp.propname,prp.hmesh,prp.automesh,prp.hide,prp.groupno);
      mi_clearselected;
    end
  case 'electric'
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'inconductor',0),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.automesh=0;
    else
      prp.automesh=1;
      prp.hmesh=0;
    end
    for sg=1:size(cd1,1)
      ei_addsegment(cd1(sg,1),cd1(sg,2),cd2(sg,1),cd2(sg,2));
      ei_selectsegment(selcd(sg,1),selcd(sg,2));
      ei_setsegmentprop(prp.propname,prp.hmesh,prp.automesh,prp.hide,prp.groupno,prp.inconductor);
      ei_clearselected;
    end
  case 'thermal'
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'inconductor',0),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.automesh=0;
    else
      prp.automesh=1;
      prp.hmesh=0;
    end
    for sg=1:size(cd1,1)
      hi_addsegment(cd1(sg,1),cd1(sg,2),cd2(sg,1),cd2(sg,2));
      hi_selectsegment(selcd(sg,1),selcd(sg,2));
      hi_setsegmentprop(prp.propname,prp.hmesh,prp.automesh,prp.hide,prp.groupno,prp.inconductor);
      hi_clearselected;
    end
  case 'electrokinetic'
    prp=xa_gatherprop(struct('propname',0,'groupno',0,'hide',0,'inconductor',0),prp0,varargin{:});
    if isfield(prp,'hmesh')
      prp.automesh=0;
    else
      prp.automesh=1;
      prp.hmesh=0;
    end
    for sg=1:size(cd1,1)
      ci_addsegment(cd1(sg,1),cd1(sg,2),cd2(sg,1),cd2(sg,2));
      ci_selectsegment(selcd(sg,1),selcd(sg,2));
      ci_setsegmentprop(prp.propname,prp.hmesh,prp.automesh,prp.hide,prp.groupno,prp.inconductor);
      ci_clearselected;
    end
  otherwise
    error('Unknown problem type');
end
