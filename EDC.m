function [ EDC ] = EDC( h )
%%
% function EDC = EDC( h )
%
% Takes a IR and calculates the "energy decay curve"
%
% Input:
%  h                -       impuls response
%
% Output:
%  EDC              -       Energy Decay Curve
%%

    % square-product of every entry in IR
    h2 = h.^2;
    % flip vector for integration
    h2 = fliplr(h2);
    % discretised integration
    EDC = cumsum(h2);
    % flip back
    EDC = fliplr(EDC);
    % normalise EDC
    EDC = EDC./max(EDC);

end

