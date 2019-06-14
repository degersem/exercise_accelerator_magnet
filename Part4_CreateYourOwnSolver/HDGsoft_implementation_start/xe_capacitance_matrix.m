function C=xe_capacitance_matrix(peclabel)

% function C=xe_capacitance_matrix(peclabel)
% computes the capacitance matrix
%
% input parameters
%    peclabel    : []     : generic electrode label (optional; default: 'C')
%
% output parameters
%    C           : [F]    : capacitance matrix

numpec=length(peclabel);                                                   % [#]    : number of electrodes in the model
for pc=1:numpec
  % A. Modify model
  Uapppeak=1;     % [A] : applied voltage
  for cl=1:numpec
    if cl==pc
      ei_modifyconductorprop(peclabel{cl},1,Uapppeak);                     % [V] : applied voltage (FEMM WORKS WITH PEAK VALUES)
    else
      ei_modifyconductorprop(peclabel{cl},1,0);
    end
  end
  % B. Solve problem
  ei_analyze(0);
  ei_loadsolution;
  % C. Post-process for the inductances
  C(:,pc)=xe_charge(peclabel)/Uapppeak;                                    % [F]    : capacitance (FEMM WORKS WITH PEAK VOLTAGES)
end
