function [H,nu,nud,dnudB2,wmagn,wmagnco]=nlin_evaluate(nlin,B)

% function [H,nu,nud,dnudB2]=NLIN_EVALUATE(nlin,B)
% evaluates a nonlinear material characteristic for a given abscis input determining the working point
% possible material models are
%      H = nu B                   (used e.g. for successive substitution)
%      H = Hc + nud * B           (used e.g. for Newton)
%
% input parameters
%       nlin        : [--]     : nonlinear material characteristic
%       B           : [T]      : abscis input value determine the working point
%
% output parameters
%       H           : [A/m]    : ordinate output value
%       nu          : [A/mT]   : chord reluctivity        : slope between the (0,0) data point and the working point
%       nud         : [A/mT]   : differential reluctivity : slope of the line tangential to the nonlinear characteristic at the working point
%       dnudB2      : [A/mT^3] : derivative of the reluctivity with respect to the square of the magnetic flux density
%       wmagn       : [J/m^3]  : magnetic energy density
%       wmagnco     : [J/m^3]  : magnetic co-energy density
%
% see also NONL_INITIALISE

% A. Initialisation
[num,dim]=size(B);                                    % number of material cells and dimension
[Bm,Bangle]=pyth(B);                                  % magnitude and angles
idxleft=find(Bm<nlin.Bmin);                           % indices of the points in the initial part of the characteristic
idxright=find(Bm>nlin.Bmax);                          % indices of the points in the extrapolated part of the characteristic
% B. Determine the ordinate values
Hm=ppval(nlin.spline,Bm);
Hm(idxleft)=nlin.initialslope*Bm(idxleft);
Hm(idxright)=nlin.finalcoercitivity+nlin.finalslope*Bm(idxright);
H=Bangle.*(Hm*ones(1,dim));
% C. Determine the chord reluctivity (slope between the (0,0) data point and the working point)
if nargout>=2
  nu=savedivide(Hm,Bm,nlin.initialslope);
end
% D. Determine the differential reluctivity (slope of the line tangential to the nonlinear characteristic at the working point)
if nargout>=3
  nud=ppval(nlin.splineder,Bm);
  nud(idxleft)=nlin.initialslope;
  nud(idxright)=nlin.finalslope;
end
if nargout>=4
  dnudB2=savedivide(nud-nu,2*Bm.^2);
end
if nargout>=5
  wmagn=ppval(nlin.splineint,Bm);
  wmagn(idxleft)=Hm(idxleft).*Bm(idxleft)/2;
  wmagn(idxright)=nlin.finalWmagn+(Bm(idxright)-nlin.Bmax).*(Hm(idxright)+nlin.Hmax)/2;
  wmagnco=Hm.*Bm-wmagn;
end
