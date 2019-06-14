function BlockProps = material_store_in_femmdata(mtl)
% function BlockProps = material_store_in_femmdata(mtl)
%   stores the material data structure in FEMM data
%
% Inputs
%    mtl                : material data structure
%
% Outputs
%    femmdata           : FEMM data
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

mu0=4*pi*1e-7;                                                             % [H/m]  : permeability of vacuum
eps0=8.85e-12;                                                             % [F/m]  : permittivity of vacuum
BlockProps=repmat(struct('BlockName','"AIR"','Mu_x','1','Mu_y','1',...
  'H_c','0','H_cAngle','0','J_re','0','J_im','0','Sigma','0',...
  'd_lam','0','Phi_h','0','Phi_hx','0','Phi_hy','0',...
  'LamType','0','LamFill','1','NStrands','0','WireD','0',...
  'BHPoints','0'),1,length(mtl));                                          % standard FEMM block property
for mt=1:length(mtl)
  BlockProps(mt).BlockName=['"' mtl(mt).label '"'];                        % []     : material name
  %mtl(mt).epsilon;                                                        % [F/m]  : permittivity
  BlockProps(mt).Mu_x=sprintf('%13.6e',1.0/mtl(mt).nu(1,1)/mu0);
  BlockProps(mt).Mu_y=sprintf('%13.6e',1.0/mtl(mt).nu(1,2)/mu0);           % [A/mT] : reluctivities
  BlockProps(mt).Sigma=sprintf('%13.6e',mtl(mt).sigma/1e6);                % [S/m]  : conductivities (SCALING BY 1e6 (FEMM uses MS/m))
  BlockProps(mt).J_re=sprintf('%13.6e',mtl(mt).Jz/1e6);                    % [A/m^2]: applied current densities (SCALING BY 1e6 (FEMM uses MA/m^2))
  BlockProps(mt).H_c=sprintf('%13.6e',mtl(mt).Hc);                         % [A/m]  : coercitivity
end

end
