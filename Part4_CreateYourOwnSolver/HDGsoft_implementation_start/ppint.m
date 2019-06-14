function ds=ppint(cs,intct)

% function ds=PPINT(cs)
% computes the integral of a piecewise polynomial
%
% input parameters
%       cs                 : piecewise polynomial (created by spline)
%       intct              : integration constant (optional; default: 0)
%
% output parameters
%       ds                 : piecewise polynomial of one order higher (to be evaluated by ppval)
%
% see also SPLINE, PPVAL, MKPP, UNMKPP, PPDER
%
% (c) This software is intended for didactical purposes. It comes without any warranty.
%     It may not be used for commercial purposes without notice to the authors.
%     It may be distributed freely in the KU Leuven, TU Darmstadt, TU Graz, Univ. Lille 1,
%     BU Wuppertal and RWTH Aachen. Any copy should include this message.
%
% Example
%   x = 0:10;
%   y = sin(x);
%   xx = 0:.25:10;
%   yy = spline(x,y,xx);
%   plot(x,y,'o',xx,yy);
%   cs = spline(x,y);
%   [breaks,coefs,l,k,d] = unmkpp(cs);
%   ds = ppint(cs);
%   figure(1); clf; plot(x,y,'o',xx,ppval(cs,xx));
%   figure(2); clf; plot(xx,ppval(ppder(cs),xx));
%   figure(3); clf; plot(xx,ppval(ds,xx));

if nargin<2
  intct=0;
end
ds.form = 'pp';
ds.breaks = cs.breaks;
ds.coefs = zeros(cs.pieces,cs.order+1);
ds.pieces = cs.pieces;
ds.order = cs.order+1;
ds.dim = cs.dim;

% compute the coefficients
for i=1:cs.pieces
  di = polyint(cs.coefs(i,:));
  ds.coefs(i,ds.order-length(di)+1:ds.order) = di;
end

% propagate the integration constant
ct = intct;
for i=1:ds.pieces
  ds.coefs(i,end) = ds.coefs(i,end)+ct;
  ct = polyval(ds.coefs(i,:),ds.breaks(i+1)-ds.breaks(i));
end
