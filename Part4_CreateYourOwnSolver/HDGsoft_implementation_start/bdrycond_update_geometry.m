function [bdrycond prb] = bdrycond_update_geometry(bdrycond,prb,plotflag)
% function [bdrycond prb] = bdrycond_update_geometry(bdrycond,prb,plotflag)
%   updates the boundary-condition information according to the given geometry (to be invoked ONLY ONCE after reading the data from file)
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    prb                :       : 2D FE problem
%    plotflag           : 1/0   : plot figures (optional; default: 0)
%
% Outputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    prb                :       : 2D FE problem
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

% A. Parameter control
if ~exist('plotflag','var')
  plotflag=0;
end
reltol=1e-3;

% B. Detect mirror line segments and mirror arc segments for binary boundary conditions
%    Make one of both (arc)segments to master (remove BC identifier)
bdrytype={bdrycond.type};
numbdrycond=length(bdrycond);                                              % [#]   : number of boundary conditions
numpoint=size(prb.points,1);
numsegment=size(prb.segments,1);
numarcsegment=size(prb.arcsegments,1);
ptmark=zeros(numpoint,5);
%mirror=repmat(struct('point',zeros(0,2),'segment',zeros(0,2),'arcsegment',zeros(0,2)),5,1);
for bd=1:numbdrycond
  tp=bdrytype{bd};
  switch tp
    case {'airgap','periodic','antiperiodic'} % binary boundary conditions
      pt=find(prb.points(:,3)==bd)';
      sg=find(prb.segments(:,4)==bd)';
      asg=find(prb.arcsegments(:,5)==bd)';
      if ~any(pt) & ~any(sg) & ~any(asg)
        warning('Boundary condition %d not found in the mesh\n',bd);
      elseif ~xor(length(pt)==2,xor(length(sg)==2,length(asg)==2))
        error('Binary boundary/interface condition %d should apply to exactly 2 points, 2 line segments or 2 arc segments\n',bd);
      elseif length(pt)==2                                                 % binary condition applied to two points
        ptmark(:,tp)=add2ptmark(ptmark(:,tp),pt(1),pt(2));
      elseif length(sg)==2                                                 % binary condition applied to two line segments
        ptmark(:,tp)=add2ptmark(ptmark(:,tp),prb.segments(sg(1),1:2),prb.segments(sg(2),1:2));
      elseif length(asg)==2                                                % binary condition applied to two arc segments
        ptmark(:,tp)=add2ptmark(ptmark(:,tp),prb.arcsegments(asg(1),1:2),prb.arcsegments(asg(2),1:2));
      end
  end
end
if 1
  figure(37); clf; mesh_plot(prb,struct('point',find(ptmark(:,5)>0))); title('slave points (anti-periodic BC)');
  figure(38); clf; mesh_plot(prb,struct('point',find(ptmark(:,5)<0))); title('master points (anti-periodic BC)');
end
% go through the binary boundary conditions once more and possibly swap slave and master side
for bd=1:numbdrycond
  tp=bdrytype{bd};
  switch tp
    case {'airgap','periodic','antiperiodic'} % binary boundary conditions
      pt=find(prb.points(:,3)==bd)';
      sg=find(prb.segments(:,4)==bd)';
      asg=find(prb.arcsegments(:,5)==bd)';
      if length(pt)==2                                                     % binary condition applied to two points
        if ptmark(pt(1),tp)<0
          pt=fliplr(pt);
        end
        prb.points(pt(2),3)=0;                                             % discard BC at the second point (this is not allowed because this routine is passed through multiple times)
        bdrycond(bd).mirror.point=pt;                                      % [@,@] : connection list for points
      elseif length(sg)==2                                                 % binary condition applied to two line segments
        if ptmark(prb.segments(sg(1),1),tp)<0
          sg=fliplr(sg);
        end
        prb.segments(sg(2),4)=0;                                           % discard BC at the second line segment (this is not allowed because this routine is passed through multiple times)
        bdrycond(bd).mirror.segment=sg;                                    % [@,@] : connection list for line segments
      elseif length(asg)==2                                                % binary condition applied to two arc segments
        if ptmark(prb.arcsegments(asg(1),1),tp)<0
          asg=fliplr(asg);
        end
        prb.arcsegments(asg(2),5)=0;                                       % discard BC at the second arc segment (this is not allowed because this routine is passed through multiple times)
        bdrycond(bd).mirror.arcsegment=asg;                                % [@,@] : connection list for arc segments
      end
  end

end

% the following implementation was (only) an intention to order the line/arc-segments of a binary BC
% for tp=3:5
%   bdlist=find(strcmp(bdrytype,tp));
%   if any(bdlist)
%     bd=bdlist(1);
%     [pt,sg,asg]=binary_swap_and_order(prb,mirror(tp).point,mirror(tp).segment,mirror(tp).arcsegment);
%     bdrycond(bd).mirror.point=pt;
%     bdrycond(bd).mirror.segment=sg;
%     drycond(bd).mirror.arcsegment=asg;
%     prb.points(pt(:,1),3)=bd;         prb.points(pt(:,2),3)=0;
%     prb.segments(sg(:,1),4)=bd;       prb.segments(sg(:,2),4)=0;
%     prb.arcsegments(asg(:,1),5)=bd;   prb.arcsegments(asg(:,2),5)=0;
%   end
% end
