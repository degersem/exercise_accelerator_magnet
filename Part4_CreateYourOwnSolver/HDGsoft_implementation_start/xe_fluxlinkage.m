function psi=xe_fluxlinkage(coillabel)

% function psi=xe_fluxlinkage(coillabel)
% postprocesses for the flux linkages
%
% input parameters
%    coillabel   : []     : coil labels
%
% output parameters
%    psi         : [Wb]   : flux linkages

for cl=1:length(coillabel)
  res=mo_getcircuitproperties(coillabel{cl});                              % res = [ total_current voltage_drop flux_linkage ]
  psi(cl,1)=res(:,3);                                                      % [Wb]   : flux linkage
end
