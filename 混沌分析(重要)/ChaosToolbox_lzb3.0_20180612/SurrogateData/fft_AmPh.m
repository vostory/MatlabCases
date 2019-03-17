function [f_am,f_ph] = fft_AmPh(x)

f = fft(x);

f_am = abs(f);
f_re = real(f);
f_im = imag(f);

f_ph1 = acos(f_re./f_am);
f_ph2 = 2*pi-acos(f_re./f_am);

f_ph = zeros(size(x));  

i = find(f_im>=0);
f_ph(i) = f_ph1(i);

j = find(f_im<0);
f_ph(j) = f_ph2(j);