function a = mat2gray(x,limits) 
%MAT2GRAY Convert matrix to intensity image. 
%   I = MAT2GRAY(A,[AMIN AMAX]) converts the matrix A to the 
%   intensity image I.  The returned matrix I contains values in  
%   the range 0.0 (black) to 1.0 (full intensity or white). 
%   AMIN and AMAX are the values in A that correspond to 0.0 and 
%   1.0 in I. 
% 
%   I = MAT2GRAY(A) sets the values of AMIN and AMAX to the 
%   minimum and maximum values in A. 
% 
%   Class Support 
%   ------------- 
%   The input array A and the output image I are of class 
%   double. 
% 
%   Example 
%   ------- 
%       I = imread('rice.tif'); 
%       J = filter2(fspecial('sobel'), I); 
%       K = mat2gray(J); 
%       imshow(I), figure, imshow(K) 
% 
%   See also GRAY2IND. 
 
%   Clay M. Thompson 10-5-92 
%   Copyright 1993-1998 The MathWorks, Inc.  All Rights Reserved. 
%   $Revision: 5.6 $  $Date: 1997/11/24 15:35:52 $ 
 
if (~isa(x,'double')) 
   error('A must be double'); 
end 
 
if nargin==1, 
   limits = [min(x(:)) max(x(:))]; 
end 
 
if limits(2)==limits(1)   % Constant Image 
   a = max(0,min(x,1)); 
else                       
   a = max(0,min((x-limits(1))/(limits(2)-limits(1)),1)); 
end 