function [myset] = detectSet(i)
  if(i <= 5 && i > 0)
    myset = 'set1';
  elseif(i <= 10 && i > 5)
    myset = 'set2';
  elseif(i <= 15 && i > 10)
    myset = 'set3';
  elseif(i <= 20 && i > 15)
    myset = 'set4';
  else
    myset = 'no set';
  end    
