function gmy = geometry_propagate_bdrycond_segment2point(gmy,bdrycond,plotflag)
% function gmy = geometry_propagate_bdrycond_segment2point(gmy,bdrycond,plotflag)
%   propagates boundary information from line/arc segments to points accounting for priority rules (to be invoked ONLY ONCE after reading the data from file)
%
% Inputs
%    gmy             :       : 2D geometry
%    bdrycond        :       : data for boundary conditions (BCs)
%    plotflag        : 1/0   : plot figures (optional; default: 0)
%
% Outputs
%    gmy             :       : 2D geometry
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

if ~exist('plotflag','var')
  plotflag=0;
end
rule(1)=struct('treat','airgap','allow_coincidence','no');
rule(2)=struct('treat',{{'periodic','antiperiodic'}},'allow_coincidence','of_same_type');
rule(3)=struct('treat','robin','allow_coincidence','no');
rule(4)=struct('treat','dirichlet','allow_coincidence','no');
bdrytype={bdrycond.type};
for rl=1:length(rule)
  bdlist=find(ismember(bdrytype,rule(rl).treat));
  ptassigned=[];
  for ii=1:length(bdlist)
    bd=bdlist(ii);
    pt=find(gmy.points(:,6)==bd);
    sg=find(gmy.segments(:,4)==bd);
    asg=find(gmy.arcsegments(:,5)==bd);
    ptfound=union(reshape([gmy.segments(sg,1:2);gmy.arcsegments(asg,1:2)],[],1),pt);
    ptviolating=intersect(ptfound,ptassigned);
    if any(ptviolating)
      switch rule(rl).allow_coincidence
        case 'no'
          fprintf('Boundary conditions of types ['); fprintf(' %d',rule(rl).treat);
          fprintf(' ] coincide at points ['); fprintf(' %d',ptviolating);
          fprintf(' with already assigned boundary conditions\n'); warning(' ]\n');
        case 'of_same_type'
          ii=find(~strcmp(bdrytype(gmy.points(ptviolating,6)),bdrytype(bd)));
          if any(ii)
            fprintf('Two binary boundary conditions of different type coincide at the points ');
            fprintf(' %d',ptviolating(ii)); error('\n');
          end
      end
    end
    gmy.points(ptfound,6)=bd;
    ptassigned=union(ptassigned,ptfound);
  end
end

% D. Make consistent slave (primary) and master (secondary) sides for binary boundary conditions
%    This is necessary to avoid the situation where a point bcomes slave due to the binary boundary condition


% % The following implementation was a try to make a fully consistent treatment of primary and secondary side of binary boundary conditions
% % be aware that here, air-gap interface conditions are prioritary w.r.t. (anti-)periodic BCs, whereas in the previous implementation, it is otherwise
% % this change necessitates the additional treatment of fftsize+1 situations in airgap_operators
% % C.1. Create a point-2-boundary-condition incidence matrix
% for bd=1:numbdrycond
%   pt=find(gmy.points(:,6)==bd);
%   sg=find(gmy.segments(:,4)==bd);
%   asg=find(gmy.arcsegments(:,5)==bd);
%   ptfound=union(reshape([gmy.segments(sg,1:2);gmy.arcsegments(asg,1:2)],[],1),pt);
%   pt2bd(ptfound,bd)=1;
% end
% % C.2. Assign boundary/interface conditions to the points and resolve for ambiguities
% for pt=1:numpoint
%   bd_assigned=0;
%   for bd=1:numbdrycond
%     if pt2bd(pt,bd)
%       if ~bd_assigned               % assign the boundary condition
%         bd_assigned=bd;
%       else                          % resolve the ambiguity
%         switch bdrytype(bd_assigned)
%           case 0                    % Prescribed A (Dirichlet)
%             switch bdrytype(bd)
%               case 0                % Dirichlet against Dirichlet, unacceptable collision
%                 error('Unacceptable collision of two different Dirichlet boundary conditions\n');
%               otherwise             % all other boundary condition have a lower priority, keep the assigned boundary condition
%             end
%           case 1                    % Small Skin Depth
%             switch bdrytype(bd)
%               case 0                % small-skin depth against Dirichlet, Dirichlet wins
%                 bd_assigned=bd;
%               case 1                % small-skin depth against small-skin depth
%                 error('Unacceptable collision of two different small-skin-depth boundary conditions\n');
%               otherwise             % all other boundary conditions have a lower priority, keep the assigned boundary condition
%             end
%           case 2                    % Mixed (Robin)
%             switch bdrytype(bd)
%               case 0                % Robin against Dirichlet, Dirichlet wins
%                 bd_assigned=bd;
%               case 1                % Robin against small-skin-depth, small-skin-depth wins
%                 bd_assigned=bd;
%               case 2                % Robin against Robin
%                 error('Unacceptable collision of two different Robin boundary conditions\n');
%               otherwise             % all other boundary conditions have a lower priority, keep the assigned boundary condition
%             end
%           case 3                    % Strategic dual image (here use as the air-gap interface condition)
%             switch bdrytype(bd)
%               case 0                % air-gap BC against Dirichlet, Dirichlet wins
%                 bd_assigned=bd;
%               case 1                % air-gap BC against small-skin-depth BC, small-skin-depth BC wins
%                 bd_assigned=bd;
%               case 2                % air-gap BC against Robin BC, Robin BC wins
%                 bd_assigned=bd;
%               case 3                % two different air-gap interface conditions
%                 error('Unacceptable collision of two different air-gap interface conditions\n');
%               case 4                % air-gap BC against periodic BC, air-gap BC wins
%               case 5                % air-gap BC against anti-periodic BC, air-gap BC wins
%             end
%           case 4                    % Periodic boundary condition
%             switch bdrytype(bd)
%               case 0                % periodic BC against Dirichlet BC, Dirichlet BC wins
%                 bd_assigned=bd;
%               case 1                % periodic BC against small-skin-depth BC, small-skin-depth BC wins
%                 bd_assigned=bd;
%               case 2                % periodic BC against mixed BC, mixed BC wins
%                 bd_assigned=bd;
%               case 3                % periodic BC against air-gap interface condition, air-gap BC wins
%                 bd_assigned=bd;
%               case 4                % periodic BC against another periodic BC, merge both periodic BCs
%
%               case 5                % periodic BC against anti-periodic BC
%                 error('Unacceptable collision of a periodic and an anti-periodic BC\n');
%             end
%           case 5              % Anti-periodic boundary condition
%             switch bdrytype(bd)
%               case 0                % anti-periodic BC against Dirichlet BC, Dirichlet BC wins
%                 bd_assigned=bd;
%               case 1                % anti-periodic BC against small-skin-depth BC, small-skin-depth BC wins
%                 bd_assigned=bd;
%               case 2                % anti-periodic BC against mixed BC, mixed BC wins
%                 bd_assigned=bd;
%               case 3                % anti-periodic BC against air-gap interface condition, air-gap BC wins
%                 bd_assigned=bd;
%               case 4                % anti-periodic BC against another periodic BC
%                 error('Unacceptable collision of a periodic and an anti-periodic BC\n');
%               case 5                % anti-periodic BC against anti-periodic BC, merge both anti-periodic BCs
%             end
%       end
%     end
%   end
% end