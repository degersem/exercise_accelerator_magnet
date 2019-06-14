function L=xe_inductance_matrixHF(coillabel,lz)

% function L=xe_inductance_matrixHF(coillabel)
% computes the inductance matrix for a high-frequency wire model
%
% input parameters
%    coillabel   : []     : generic coil label (optional; default: 'C')
%
% output parameters
%    L           : [H]    : inductance matrix

numcoil=length(coillabel);                                                 % [#]   : number of coils
Rm=zeros(numcoil,numcoil);                                                 % [1/H] : reluctance matrix
Phiapppeak=1;                                                              % [Wb]  : applied flux

%% 1. Compute diagonal entries of the reluctance matrix
for q=1:numcoil
  % A. Modify model
  for cl=1:numcoil
    if cl==q
      mi_modifyboundprop(coillabel{cl},1,Phiapppeak/lz);                   % [Wb] : applied flux (FEMM WORKS WITH PEAK VALUES)
    else
      mi_modifyboundprop(coillabel{cl},1,0);
    end
  end
  % B. Solve problem
  mi_analyze(0);
  mi_loadsolution;
  % C. Post-process for the inductances
  mo_groupselectblock; Wmagn=mo_blockintegral(2); mo_clearblock;           % [J]   : stored magnetic energy
  Rm(q,q)=(2*Wmagn)/Phiapppeak^2;                                          % [1/H] : diagonal entry of the reluctance matrix (FEMM WORKS WITH PEAK CURRENTS)
end

%% 2. Compute off-diagonal entries of the reluctance matrix
for p=1:numcoil
  for q=p+1:numcoil
    % A. Modify model
    for cl=1:numcoil
      if ismember(cl,[p q])
        mi_modifyboundprop(coillabel{cl},1,Phiapppeak/lz);                 % [Wb] : applied flux (FEMM WORKS WITH PEAK VALUES)
      else
        mi_modifyboundprop(coillabel{cl},1,0);
      end
    end
    % B. Solve problem
    mi_analyze(0);
    mi_loadsolution;
    % C. Post-process for the inductances
    mo_groupselectblock; Wmagn=mo_blockintegral(2); mo_clearblock;         % [J]   : stored magnetic energy
    Rm(p,q)=(2*Wmagn)/Phiapppeak^2-(Rm(p,p)+Rm(q,q))/2;                    % [1/H] : off-diagonal entry of the reluctance matrix (FEMM WORKS WITH PEAK CURRENTS)
    Rm(q,p)=Rm(p,q);
  end
end

warning('Numerically instable matrix inversion\n');
L=inv(Rm);                                                                 % [H]   : inductance matrix
