parfor i = 1:1000
    disp(['pas: ' num2str(i)])
    A = rand(1000);
    B = rand(1000);
    A\B*B/A;
end