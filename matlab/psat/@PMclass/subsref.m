function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
 case 'store'
    if length(index) == 2
      b = a.store(index(2).subs{:});
    else
      b = a.store;
    end

   case 'con'
    if length(index) == 2
      b = a.con(index(2).subs{:});
    else
      b = a.con;
    end
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'bus'
    b = a.bus;
   case 'n'
    b = a.n;
   case 'dat'
    b = a.dat;
   case 'vm'
    b = a.vm;
   case 'thetam'
    b = a.thetam;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
