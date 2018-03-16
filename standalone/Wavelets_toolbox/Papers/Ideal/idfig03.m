% idfig03 -- Ideal Figure 03: Noisy Versions of Four Signals
%
% The four objects of Figure 1 with white noise superposed.
% The noise is normally distributed with variance 1.
%
% 

global yblocks ybumps yheavi yDoppler
global t
%
	%clf;
	versaplot(221,t,yblocks, [],' 3 (a) Noisy Blocks '   ,[],[])
	versaplot(222,t,ybumps,  [],' 3 (b) Noisy Bumps '    ,[],[])
	versaplot(223,t,yheavi,  [],' 3 (c) Noisy HeaviSine ',[],[])
	versaplot(224,t,yDoppler,[],' 3 (d) Noisy Doppler '  ,[],[])
 
    
    
 
 
%
%  Part of Wavelab Version 850
%  Built Tue Jan  3 13:20:41 EST 2006
%  This is Copyrighted Material
%  For Copying permissions see COPYING.m
%  Comments? e-mail wavelab@stat.stanford.edu 
