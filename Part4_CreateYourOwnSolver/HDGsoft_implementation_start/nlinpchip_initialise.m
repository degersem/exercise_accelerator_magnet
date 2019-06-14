function nlin=nlinpchip_initialise(Bchar,Hchar,options)

% function nlin=NLINPCHIP_INITIALISE(Bchar,Hchar,options)
% initialises the data for further use when evaluating nonlinear material characteristics
% possible material models are
%      H = nu B                   (used e.g. for successive substitution)
%      H = Hc + nud * B           (used e.g. for Newton)
%
% input parameters
%       Bchar       : [T]    : B-values of the B-H characteristic
%       Hchar       : [A/m]  : H-values of the B-H characteristic
%       options     : options for curve approximation
%           extend_curve (optional)
%               factor                      : []    : factor with which the last abscissa point is multiplied
%           final_slope (optional)
%               factor                      : []    : factor with which the last abscissa point is multiplied
%               vale                        : [m/H] : final slope
%           smooth_differential_reluctivity (optional)
%
% output parameters
%       nlin        : data for further use when evaluating nonlinear material characteristics
%
% see also NLINPCHIP_EVALUATE

if ~exist('options','var')
  options=struct();
end

% E.1. Registrate the material data
nlin.B=sort(abs(Bchar));                                      % [T]    : B-values of the B-H characteristic
nlin.H=sort(abs(Hchar));                                      % [A/m]  : H-values of the B-H characteristic
% E.2. Add a (0,0) data point when missing
if nlin.B(1)~=0
  nlin.B=[ 0 ; nlin.B ];
  nlin.H=[ 0 ; nlin.H ];
end
% E.3. Determine initial slope
nlin.initialslope=nlin.H(1)/nlin.B(1);
% E.4. Determine final slope
nlin.finalslope=diff(nlin.H(end-1:end))/diff(nlin.B(end-1:end));
nlin.finalcoercitivity=nlin.H(end)-nlin.B(end)*nlin.finalslope;             % coercitivity at the point of maximum saturation
nlin.finalremanence=nlin.B(end)-nlin.H(end)/nlin.finalslope;                % remanence at the point of maximum saturation
% E.5. Extend the curve
if isfield(options,'extend_curve')
  Bnew=nlin.B(end)*options.extend_curve.factor;
  nlin.B=[ nlin.B ; Bnew ];
  nlin.H=[ nlin.H ; nlin.finalcoercitivity+nlin.finalslope*Bnew ];
end
% E.6. Apply a final slope
if isfield(options,'final_slope')
  Bnew=nlin.B(end)*options.final_slope.factor;
  Hnew=nlin.H(end)+options.final_slope.value*(Bnew-nlin.B(end));
  nlin.B=[ nlin.B ; Bnew ];
  nlin.H=[ nlin.H ; Hnew ];
  nlin.finalslope=diff(nlin.H(end-1:end))/diff(nlin.B(end-1:end));
  nlin.finalcoercitivity=nlin.H(end)-nlin.B(end)*nlin.finalslope;             % coercitivity at the point of maximum saturation
  nlin.finalremanence=nlin.B(end)-nlin.H(end)/nlin.finalslope;                % remanence at the point of maximum saturation
end
% E.3. Determine the range of the characteristic
nlin.Bmax=max(nlin.B);
nlin.Hmax=max(nlin.H);
% E.6. Create a spline representation of the B-H characteristic
nlin.spline=pchip(nlin.B,nlin.H);                                          % cubic spline interpolation of the characteristic
nlin.splineder=ppder(nlin.spline);                                         % cubic spline interpolation of the first derivative of the characteristic
nlin.splineint=ppint(nlin.spline);                                         % cubic spline interpolation of the integral of the characteristic
if isfield(options,'smooth_differential_reluctivity')
  mu0=4*pi*1e-7;
  nud=ppval(nlin.splineder,nlin.B);
  nud(find(nud>1/mu0))=1/mu0;
  Bm=[nlin.B;[2;4]*nlin.B(end)];
  nud=[nud;1/mu0;1/mu0];
  nud(2:end-1)=(nud(1:end-2)+2*nud(2:end-1)+nud(3:end))/4;
  nlin.splineder=pchip(Bm,nud);
end

