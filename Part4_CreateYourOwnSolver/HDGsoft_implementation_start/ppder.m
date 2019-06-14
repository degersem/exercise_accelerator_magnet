function ds=ppder(cs);

% function ds=PPDER(cs)
% computes the derivative of a piecewise polynomial
%
% input parameters
%       cs                 : piecewise polynomial (created by spline)
%
% output parameters
%       ds                 : piecewise polynomial of one order lower (to be evaluated by ppval)
%
% see also SPLINE, PPVAL, MKPP, UNMKPP
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
%   [breaks,coefs,l,k,d] = unmkpp(cs)
%   figure(1); clf; plot(x,y,'o',xx,ppval(cs,xx));
%   figure(2); clf; plot(xx,ppval(ppder(cs),xx));

ds.form = 'pp';
ds.breaks = cs.breaks;
ds.coefs = zeros(cs.pieces,cs.order-1);
ds.pieces = cs.pieces;
ds.order = cs.order-1;
ds.dim = cs.dim;
for i=1:cs.pieces
  dr = polyder(cs.coefs(i,:));
  ds.coefs(i,ds.order-length(dr)+1:ds.order) = dr;
end
