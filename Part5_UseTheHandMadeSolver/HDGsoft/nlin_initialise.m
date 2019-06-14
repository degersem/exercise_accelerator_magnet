function nlin=nlin_initialise(Bchar,Hchar)

% function nlin=NLIN_INITIALISE(Bchar,Hchar)
% initialises the data for further use when evaluating nonlinear material characteristics
% possible material models are
%      H = nu B                   (used e.g. for successive substitution)
%      H = Hc + nud * B           (used e.g. for Newton)
%
% input parameters
%       Bchar       : [T]    : B-values of the B-H characteristic
%       Hchar       : [A/m]  : H-values of the B-H characteristic
%
% output parameters
%       nlin        : data for further use when evaluating nonlinear material characteristics
%
% see also NLIN_EVALUATE

% E.1. Registrate the material data
nlin.B=sort(abs(Bchar));                                      % [T]    : B-values of the B-H characteristic
nlin.H=sort(abs(Hchar));                                      % [A/m]  : H-values of the B-H characteristic
% E.2. Discard the first data point when zero
if nlin.B(1)==0
  nlin.B=nlin.B(2:end);
  nlin.H=nlin.H(2:end);
end
% E.3. Determine the range of the characteristic
nlin.Bmin=min(nlin.B);
nlin.Bmax=max(nlin.B);
nlin.Hmin=min(nlin.H);
nlin.Hmax=max(nlin.H);
% E.4. Determine initial slope
nlin.initialslope=nlin.H(1)/nlin.B(1);
% E.5. Determine final slope
nlin.finalslope=diff(nlin.H(end-1:end))/diff(nlin.B(end-1:end));
% E.6. Create a spline representation of the B-H characteristic
nlin.finalcoercitivity=nlin.H(end)-nlin.B(end)*nlin.finalslope;             % coercitivity at the point of maximum saturation
nlin.finalremanence=nlin.B(end)-nlin.H(end)/nlin.finalslope;                % remanence at the point of maximum saturation
nlin.spline=spline(nlin.B,[nlin.initialslope nlin.H' nlin.finalslope]);     % cubic spline interpolation of the characteristic
nlin.splineder=ppder(nlin.spline);                                          % cubic spline interpolation of the first derivative of the characteristic
nlin.splineint=ppint(nlin.spline);                                          % cubic spline interpolation of the integral of the characteristic
nlin.finalWmagn=ppval(nlin.splineint,nlin.B(end));                          % magnetic energy density of the final point