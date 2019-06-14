function q=xe_charge(peclabel)

% function q=xe_charge(peclabel)
% postprocesses for the charges at all electrodes
%
% input parameters
%    peclabel    : []     : generic electrode label (optional; default: 'C')
%
% output parameters
%    q           : [C]    : charge

numpec=length(peclabel);                                                   % [#]    : number of electrodes in the model
for cl=1:numpec
  res=eo_getconductorproperties(peclabel{cl});                             % res = [ voltage charge ]
  q(cl,1)=res(:,2);                                                        % [C]    : charge
end
