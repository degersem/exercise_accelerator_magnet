function y=block(t,t1,t2)

% function y=block(t,t1,t2)
% returns 1 for t1<t<t2 and 0.5 for t==t1 and t==t2

y=((t>t1)&(t<t2))+0.5*((t==t1)|(t==t2));
