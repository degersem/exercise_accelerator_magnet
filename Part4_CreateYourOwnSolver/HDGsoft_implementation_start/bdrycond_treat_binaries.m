function [bdrycond,gmy] = bdrycond_treat_binaries(bdrycond,gmy,plotflag)
% function [bdrycond,gmy] = bdrycond_treat_binaries(bdrycond,gmy,plotflag)
%   updates the boundary-condition information according to the given geometry (to be invoked ONLY ONCE after reading the data from file)
%
% Inputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    gmy                :       : 2D geometry
%    plotflag           : 1/0   : plot figures (optional; default: 0)
%
% Outputs
%    bdrycond           :       : data for boundary conditions (BCs)
%    gmy                :       : 2D geometry
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
numpoint=size(gmy.points,1);
numsegment=size(gmy.segments,1);
numarcsegment=size(gmy.arcsegments,1);
ptmark.('periodic')=zeros(numpoint,1);
ptmark.('antiperiodic')=zeros(numpoint,1);
%mirror=repmat(struct('point',zeros(0,2),'segment',zeros(0,2),'arcsegment',
%zeros(0,2)),5,1);
for bd=1:numbdrycond
  tp=bdrytype{bd};
  switch tp
    case {'periodic','antiperiodic'} % binary boundary conditions
      pt=find(gmy.points(:,6)==bd)';
      sg=find(gmy.segments(:,4)==bd)';
      asg=find(gmy.arcsegments(:,5)==bd)';
      if ~any(pt) & ~any(sg) & ~any(asg)
        warning('Boundary condition %d not found in the mesh\n',bd);
      elseif ~xor(length(pt)==2,xor(length(sg)==2,length(asg)==2))
        error('Binary boundary/interface condition %d should apply to exactly 2 points, 2 line segments or 2 arc segments\n',bd);
      elseif length(pt)==2                                                 % binary condition applied to two points
        ptmark.(tp)=add2ptmark(ptmark.(tp),pt(1),pt(2));
      elseif length(sg)==2                                                 % binary condition applied to two line segments
%         figure(132); hold on; geometry_plot(gmy,struct('geometry',0,'segments',sg(1)),'r');
%         geometry_plot(gmy,struct('geometry',0,'segments',sg(2)),'b');
        ptmark.(tp)=add2ptmark(ptmark.(tp),gmy.segments(sg(1),1:2),gmy.segments(sg(2),1:2));
      elseif length(asg)==2                                                % binary condition applied to two arc segments
        ptmark.(tp)=add2ptmark(ptmark.(tp),gmy.arcsegments(asg(1),1:2),gmy.arcsegments(asg(2),1:2));
      end
  end
end
if plotflag
  figure(35); clf; geometry_plot(gmy,struct('points',find(ptmark.('periodic')>0))); title('slave points (periodic BC)');
  figure(36); clf; geometry_plot(gmy,struct('points',find(ptmark.('periodic')<0))); title('master points (periodic BC)');
  figure(37); clf; geometry_plot(gmy,struct('points',find(ptmark.('antiperiodic')>0))); title('slave points (anti-periodic BC)');
  figure(38); clf; geometry_plot(gmy,struct('points',find(ptmark.('antiperiodic')<0))); title('master points (anti-periodic BC)');
end
% go through the binary boundary conditions once more and possibly swap slave and master side
for bd=1:numbdrycond
  tp=bdrytype{bd};
  switch tp
    case {'periodic','antiperiodic'} % binary boundary conditions
      pt=find(gmy.points(:,6)==bd)';
      sg=find(gmy.segments(:,4)==bd)';
      asg=find(gmy.arcsegments(:,5)==bd)';
      if length(pt)==2                                                     % binary condition applied to two points
        if ptmark.(tp)(pt(1),1)<0
          pt=fliplr(pt);
        end
        gmy.points(pt(2),6)=0;                                             % discard BC at the second point (this is not allowed because this routine is passed through multiple times)
        bdrycond(bd).mirror.point=pt;                                      % [@,@] : connection list for points
      elseif length(sg)==2                                                 % binary condition applied to two line segments
        if ptmark.(tp)(gmy.segments(sg(1),1),1)<0
          sg=fliplr(sg);
        end
        gmy.segments(sg(2),4)=0;                                           % discard BC at the second line segment (this is not allowed because this routine is passed through multiple times)
        bdrycond(bd).mirror.segment=sg;                                    % [@,@] : connection list for line segments
      elseif length(asg)==2                                                % binary condition applied to two arc segments
        if ptmark.(tp)(gmy.arcsegments(asg(1),1),1)<0
          asg=fliplr(asg);
        end
        gmy.arcsegments(asg(2),5)=0;                                       % discard BC at the second arc segment (this is not allowed because this routine is passed through multiple times)
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
%     bdrycond(bd).mirror.arcsegment=asg;
%     gmy.points(pt(:,1),6)=bd;         gmy.points(pt(:,2),6)=0;
%     gmy.segments(sg(:,1),4)=bd;       gmy.segments(sg(:,2),4)=0;
%     gmy.arcsegments(asg(:,1),5)=bd;   gmy.arcsegments(asg(:,2),5)=0;
%   end
% end
