function [gmy wrs bcs] = wire_bdrycond_initialise_from_pointprop(femmdata,gmy,wrs,bcs)
    % function [gmy wrs bcs] = wire_bdrycond_initialise_from_pointprop(femmdata,gmy,wrs,bcs)
    %   carries over all information of point properties to the wire and boundary-condition structures and reconnects the point-2-pointproperty list
    %
    % Inputs
    %    femmdata            : FEMM data
    %    gmy                 :       : 2D geometry
    %    wrs                 : wire data structure
    %    bcs                 : boundary-conditions data structure
    %
    % Outputs
    %    gmy                 :       : 2D geometry
    %    wrs                 : wire data structure
    %    bcs                 : boundary-conditions data structure
    %
    % Author
    %   Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    gmy.points=[gmy.points zeros(size(gmy.points,1),2)];
    if isfield(femmdata,'PointProps')
      for pp=1:length(femmdata.PointProps)
        pt=find(gmy.points(:,3)==pp);                                          % [@]   : indices of the points with point property pp
        lb=femmdata.PointProps(pp).PointName(2:end-1);                         % []    : label
        wr=findlab({wrs.label},lb);
        if ~isnan(wr)
          fprintf('Point property %s merged with wire property %s\n',lb,lb);
          gmy.points(pt,5)=wr;
        else
          bd=findlab({bcs.name},lb);
          if ~isnan(bd)
            fprintf('Point property %s merged with boundary condition %s\n',lb,lb);
            gmy.points(pt,6)=bd;
          else
            Ire=sscanf(femmdata.PointProps(pp).I_re,'%f');
            Iim=sscanf(femmdata.PointProps(pp).I_im,'%f');
            if (Ire~=0) | (Iim~=0)
              fprintf('Point property %s replaced by wire property %s\n',lb,lb);
              wr=length(wrs)+1;
              gmy.points(pt,5)=wr;
              wrs(wr).label=lb;
              wrs(wr).type=1;    % series connected circuit
              % following line: division by sqrt(2) because FEMM works with peak values instead of rms values (preferred)
              warning('change to rms values should only happen for time-harmonic models!!\n');
              wrs(wr).NtI=(Ire+sqrt(-1)*Iim)/sqrt(2);
              wrs(wr).k=[];
              wrs(wr).point=find(gmy.points(:,3)==pp);                         % []     : indices of the points of the wire
            else
              fprintf('Point property %s replaced by Dirichlet boundary condition %s\n',lb,lb);
              bd=length(bcs)+1;
              gmy.points(pt,6)=bd;
              bcs(bd).name=lb;
              bcs(bd).type='dirichlet';
              Are=sscanf(femmdata.PointProps(pp).A_re,'%f');
              Aim=sscanf(femmdata.PointProps(pp).A_im,'%f');
              warning('rms or magnitude\n');
              bcs(bd).value=(Are+sqrt(-1)*Aim)*femmdata.Depth;
              bcs(bd).expression=[];
            end
          end
        end
      end
      
end