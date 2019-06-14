function elemprop = prb_mate2elem(prb,mateprop)
    % function elemprop = prb_mate2elem(prb,mateprop)
    %   translates a material-wise property into an element-wise property
    %
    % Inputs
    %    prb             :      : problem data structure
    %    mateprop        :      : material-wise property  (nummate-by-xx)
    %
    % Outputs
    %    elemprop        :      : element-wise property   (numelem-by-xx)
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

    if ischar(mateprop)
      property=mateprop;
      clear mateprop;
      for mt=1:length(prb.material)
        mateprop(mt,:)=prb.material(mt).(property);
      end
    end
    if size(mateprop,1)==size(prb.mesh.elem,1)                                 % the given properties seem already to be element-wise
      warning('depreciated use of prb_mate2elem');
      elemprop=mateprop;                                                       % [@]  : element-wise property (numelem-by-xx)
    else
      rg=prb.mesh.elem(:,4);                                                   % [@]  : region identifiers
      mt=prb.region(rg,3);                                                     % [@]  : material identifiers
      elemprop=mateprop(mt,:);                                                 % [@]  : element-wise property (numelem-by-xx)
    end
    
end
