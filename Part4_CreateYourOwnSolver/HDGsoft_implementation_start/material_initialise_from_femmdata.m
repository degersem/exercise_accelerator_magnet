function mtl = material_initialise_from_femmdata(femmdata,physics_type)

% function mtl = material_initialise_from_femmdata(femmdata,physics_type)
%   initialise the material data structure
%
% Inputs
%    femmdata           : FEMM data
%    physics_type       : magnetic/electric/thermal/electrokinetic
%
% Outputs
%    mtl                : material data structure
%
% author: Herbert De Gersem
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.

mu0=4*pi*1e-7;                                                             % [H/m]  : permeability of vacuum
eps0=8.854187817e-12;                                                      % [F/m]  : permittivity of vacuum
for mt=1:length(femmdata.BlockProps)
  mtl(mt).label=femmdata.BlockProps(mt).BlockName(2:end-1);                % []     : material name
  switch physics_type
    case 'magnetic'
      %mtl(mt).epsilon=eps0;                                                    % [F/m]  : permittivity
      mtl(mt).nu(1,1:2)=[
        1/(mu0*sscanf(femmdata.BlockProps(mt).Mu_x,'%f')) ...
        1/(mu0*sscanf(femmdata.BlockProps(mt).Mu_y,'%f'))
        ];                                                                     % [A/mT] : reluctivities
      mtl(mt).Hc=sscanf(femmdata.BlockProps(mt).H_c,'%f');                     % [A/m]  : coercitivity
      mtl(mt).Hcangle=sscanf(femmdata.BlockProps(mt).H_cAngle,'%f')/180*pi;    % [rad]  : some angle corresponding to the coercitivity
      mtl(mt).Jz=1e6*(sscanf(femmdata.BlockProps(mt).J_re,'%f') ...
        +complex(0,1)*sscanf(femmdata.BlockProps(mt).J_im,'%f'));              % [A/m^2]: applied current densities (SCALING BY 1e6 (FEMM uses MA/m^2))
      mtl(mt).sigma=1e6*sscanf(femmdata.BlockProps(mt).Sigma,'%f');            % [S/m]  : conductivities (SCALING BY 1e6 (FEMM uses MS/m))
      mtl(mt).dlam=sscanf(femmdata.BlockProps(mt).d_lam,'%f');                 % [m]    : lamination thickness
      mtl(mt).phih=sscanf(femmdata.BlockProps(mt).Phi_h,'%f');                 % ?
      mtl(mt).phihx=sscanf(femmdata.BlockProps(mt).Phi_hx,'%f');               % ?
      mtl(mt).phihy=sscanf(femmdata.BlockProps(mt).Phi_hy,'%f');               % ?
      mtl(mt).lamtype=sscanf(femmdata.BlockProps(mt).LamType,'%d');            % []     : lamination type of conductor model
      mtl(mt).lamfill=sscanf(femmdata.BlockProps(mt).LamFill,'%f');            % [?]    : lamination fill ?
      mtl(mt).Nstrands=sscanf(femmdata.BlockProps(mt).NStrands,'%d');          % [#]    : number of strands (do NOT use this for stranded conductors, use the information in the region structure instead)
      mtl(mt).wireD=sscanf(femmdata.BlockProps(mt).WireD,'%f')/1000;           % [m]    : wire diameter (SCALING BY 1000 BECAUSE WIRE DIAMETER in MM)
    case 'electric'
      mtl(mt).epsilon(1,1:2)=[
        eps0*sscanf(femmdata.BlockProps(mt).ex,'%f') ...
        eps0*sscanf(femmdata.BlockProps(mt).ey,'%f')
        ];                                                                 % [F/m]   : permittivities
      mtl(mt).rho=sscanf(femmdata.BlockProps(mt).qv,'%f');                 % [C/m^3] : charge density
    otherwise
      error('to be implemented');
  end
end
