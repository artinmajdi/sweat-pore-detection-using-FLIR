function [fitresult, gof] = show_the_manual_filter(L, L2)
    % L = 3;
    d = floor(L/3);
    h1 = -(L^2-8*(d^2))*ones(L,L);

    l = (L - d)/2;
    h1(l+1:end-l,l+1:end-l) = 8;
    % [X1,Y1] = meshgrid(1:L , 1:L);


    h2 = ones(L,L)/(L^2);    
    h12 = conv2(h2, h1);   
    
    % L2 = 11;
    [X3,Y3] = meshgrid(1:L2 , 1:L2);
    h3 = zeros(L2,L2);

    l = (L2 - (2*L-1))/2;
    h3(l+1:end-l,l+1:end-l) = h12;


    [fitresult, gof] = createFit1(X3, Y3, h3);

end