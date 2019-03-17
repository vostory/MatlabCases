function sita=heaviside(r,d)
%the function is used to calculate the value of the Heaviside function
%sita:the value of the Heaviside function
%r:the radius in the Heaviside function,sigma/2<r<2sigma
%d:the distance of two points
%skyhawk
if (r-d)<0
    sita=0;
else sita=1;
end