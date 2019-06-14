function L=xe_inductance_matrix(coillabel)

% function L=xe_inductance_matrix(coillabel)
% computes the inductance matrix for a set of coils
%
% input parameters
%    coillabel   : []     : coil labels
%
% output parameters
%    L           : [H]    : inductance matrix
%
% example
%    L=xe_inductance_matrix(cellstr(num2str((1:3)','C%d')));
%    returns a 3-by-3 inductance matrix for the coils C1, C2 and C3

numcoil=length(coillabel);
for q=1:numcoil
  % A. Modify model
  Iapppeak=1;     % [A] : applied current
  for cl=1:numcoil
    if cl==q
      mi_modifycircprop(coillabel{cl},1,Iapppeak);                         % [A] : applied current (FEMM WORKS WITH PEAK CURRENTS)
    else
      mi_modifycircprop(coillabel{cl},1,0);
    end
  end
  % B. Solve problem
  mi_analyze(0);
  mi_loadsolution;
  % C. Post-process for the inductances
  L(:,q)=xe_fluxlinkage(coillabel)/Iapppeak;                               % [H]    : inductance (FEMM WORKS WITH PEAK CURRENTS)
end
