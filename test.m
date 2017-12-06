%clear and close everything
clc; clear all; close all;

%set folders to choose from
set1folder = fullfile(pwd,'att_faces\s1');
set2folder = fullfile(pwd,'att_faces\s2');
set3folder = fullfile(pwd,'att_faces\s3');
set4folder = fullfile(pwd,'att_faces\s4');
set5folder = fullfile(pwd,'att_faces\s5');
set6folder = fullfile(pwd,'att_faces\s6');
set7folder = fullfile(pwd,'att_faces\s7');
set8folder = fullfile(pwd,'att_faces\s8');
set9folder = fullfile(pwd,'att_faces\s9');
set10folder = fullfile(pwd,'att_faces\s10');
set11folder = fullfile(pwd,'att_faces\s11');
set12folder = fullfile(pwd,'att_faces\s12');

%set number of people amd quantity of pictures per person
persons = 4; %how many rows of data of different people
quantity = 5; %how many columns of the same person

%check if folders exist
for i = 1:persons
  checkfiles = strcat('set',num2str(i),'folder');
  if ~isdir(eval(checkfiles))
    errorMessage = sprintf('Error: The following folder does not exist:\n%s', checkfiles);
    uiwait(warndlg(errorMessage));
    return;
  end
 
%make a matrix of pictures
  filepattern = fullfile(eval(checkfiles), '*.pgm');
  srcFile=dir(filepattern);
  for j = 1:quantity
    basefile = srcFile(j).name;
    filename=fullfile(eval(checkfiles), basefile);
    A{j+(5*(i-1))}=double(imread(filename));
    j+(5*(i-1))
  end
end 

%set # of rows and # of columns from image matrix
[r c] = size(A);

%display all images in a subplot
figure(111)
for i = 1:c
  subplot(c/quantity, c/persons, i);
  pcolor(flipud(A{i})), shading interp, colormap(gray)
  axis off;
end  

%get sum of rows 
for i = 1:quantity
  if(i==1)
    avg1=A{i};
    avg2=A{i+5};
    avg3=A{i+10};
    avg4=A{i+15};
    %avg5=A{i+20};
  else  
    avg1=avg1+A{i};
    avg2=avg2+A{i+5};
    avg3=avg3+A{i+10};
    avg4=avg4+A{i+15};
    %avg5=avg5+A{i+20};
  end
end

%get average of rows/ average of each person
avg1=avg1/quantity;
avg2=avg2/quantity;
avg3=avg3/quantity;
avg4=avg4/quantity;
%avg5=avg5/quantity;
%{
%plot the average faces
figure(222)
subplot(persons/2,persons/2,1)
pcolor(flipud(avg1)), shading interp, colormap(gray), axis off;  
subplot(persons/2,persons/2,2)
pcolor(flipud(avg2)), shading interp, colormap(gray), axis off;   
subplot(persons/2,persons/2,3)
pcolor(flipud(avg3)), shading interp, colormap(gray), axis off;   
subplot(persons/2,persons/2,4)
pcolor(flipud(avg4)), shading interp, colormap(gray), axis off;   
%}

%new image matrix with lower dimension
%image represented as a row of Data
for i=1:c
  Data(i,:) = [reshape(A{i},1,112*92)];
end
%calculate correlation matrix from Data
Corr = Data.' * Data;
%find the eigen values and vectors from correlation matrix
[V, D] = eigs(Corr, 20, 'lm');
%{
%plot eigen faces
figure(333);
subplot(2,2,1),face1=reshape(V(:,1),112,92); 
pcolor(flipud(face1)), shading interp, colormap(gray), axis off;  
subplot(2,2,2),face1=reshape(V(:,2),112,92); 
pcolor(flipud(face1)), shading interp, colormap(gray), axis off;  
subplot(2,2,3),face1=reshape(V(:,3),112,92); 
pcolor(flipud(face1)), shading interp, colormap(gray), axis off;
 %}
%make array of projection vectors
for i = 1:c
  proj(i,:)=Data(i,:)*V;
end

while(1)
  %user choose a picture 
  [fname path] = uigetfile('Open a face to recognize', '.pgm');
  fname = strcat(path, fname);
  im = double(imread(fname));
  %display picture
  figure(444)
  pcolor(flipud(im)), shading interp, colormap(gray)
  title('image to recognize')

  %reshape user selected picture to match a row of Data matrix
  Vec=reshape(im,1,112,92);
  %calulate projection vector of user selected picture
  projrec=Vec*V;

  %calculate error from projection array and user projection
  for i = 1:c
    error(i,:)=abs(proj(i,:)-projrec);
  end

  index = -1;
  image = -1;
  %sum the elements of error matrix 
  for i = 1:c
    thesum(i,:)=sum(error(i,:));
    thesum(i,:)/c
  end
  %find min element of sum array
  [M, I] = min(thesum/c)
  myset = detectSet(index);

  %check if user selected picture is in the dataset
  thresh = 0;
  if persons == 4
    thresh = 450;
  elseif persons == 5
    thresh = 370;
  else
    thresh = 450
  end
  if(M < thresh)
    myset = detectSet(I);
    if(M == 0)
      image = mod(I,quantity);
      if(image == 0)
        image = quantity
      end 
      msgbox(sprintf('image %d form set %s', image,myset));
    else
      msgbox(sprintf('detected %s', myset));
    end
  else
    msgbox(sprintf('detected %s', myset));
  end  
  choice = menu('Continue','Yes','no');
  if choice == 2 | choice == 0
    break;
  end
end
