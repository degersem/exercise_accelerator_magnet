function femmdata=bdrycond_reconnect(bdrycond,femmdata)

% function femmdata=bdrycond_reconnect(prb.bdrycond,femmdata)
% reconnects the binary boundary conditions
% (each binary boundary condition should be assigned to both slave and master sides)
% (whereas the own implementation makes a distinction between slave and master sides)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

for bd=1:length(bdrycond)
  switch bdrycond(bd).type
    case {'periodic','antiperiodic'} % binary boundary conditions
      if isfield(bdrycond(bd).mirror,'point')
        pt=bdrycond(bd).mirror.point(:);                                   % [@,@] : connection list for points
        femmdata.points(pt,6)=bd;
      end
      if isfield(bdrycond(bd).mirror,'segment')
        sg=bdrycond(bd).mirror.segment(:);                                 % [@,@] : connection list for line segments
        femmdata.segments(sg,4)=bd;
      end
      if isfield(bdrycond(bd).mirror,'arcsegment')
        asg=bdrycond(bd).mirror.arcsegment(:);                             % [@,@] : connection list for arc segments
        femmdata.arcsegments(asg,5)=bd;
      end
  end
end
