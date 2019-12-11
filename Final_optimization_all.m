clear;
close all;
clc;

tx = tic;
%% Open the files
matrice=xlsread('.\abc.xlsx');

%% Randomly dataset
indice=1;
for i=1:5
    while((indice<size(matrice,1))&&(matrice(indice,1)==i))
        if indice<size(matrice,1)
            indice= indice+1;
        end
    end
    if i==1
        indicead=indice-1;
        AD=matrice(1:indicead,2:end);
    else
        if i==2
            indicecn=indice-1;
            CN=matrice(indicead+1:indicecn,2:end);
        else
            if i==3
                indiceemci=indice-1;
                EMCI=matrice(indicecn+1:indiceemci,2:end);
            else
                if i==4
                    indicelmci=indice-1;
                    LMCI=matrice(indiceemci+1:indicelmci,2:end);
                else
                    MCI=matrice(indicelmci+1:end,2:end);
                end
            end
        end
    end
end

rand_numAD = randperm(size(AD,1));
rand_numCN = randperm(size(CN,1));
rand_numEMCI = randperm(size(EMCI,1));
rand_numLMCI = randperm(size(LMCI,1));
rand_numMCI = randperm(size(MCI,1));

%% Extract the validation dataset
train=[AD(rand_numAD(1:50),:);CN(rand_numCN(1:50),:);EMCI(rand_numEMCI(1:50),:);LMCI(rand_numLMCI(1:50),:);MCI(rand_numMCI(1:50),:)];
test=[AD(rand_numAD(51:75),:);CN(rand_numCN(51:75),:);EMCI(rand_numEMCI(51:75),:);LMCI(rand_numLMCI(51:75),:);MCI(rand_numMCI(51:75),:)];
validation=[AD(rand_numAD(76:100),:);CN(rand_numCN(76:100),:);EMCI(rand_numEMCI(76:100),:);LMCI(rand_numLMCI(76:100),:);MCI(rand_numMCI(76:100),:)];

X_train=train(:,2:end);
Y_train=train(:,1);

X_test=test(:,2:end);
Y_test=test(:,1);

rand_num_test = randperm(size(X_test,1));

X_test=X_test(rand_num_test,:);
Y_test=Y_test(rand_num_test,:);

X_validation=validation(:,2:end);
Y_validation=validation(:,1);

rand_num_validation = randperm(size(X_validation,1));

X_validationt=X_validation(rand_num_validation,:);
Y_validation=Y_validation(rand_num_validation,:);

toc(tx)
disp('Data is ready')
%% 1er essai
tx = tic;
tab378=zeros(378,2);
best40=zeros(80,2);

k=1;
for i=0:25
    for j=i+1:26
        fs=or(de2bi(2^i,27),de2bi(2^j,27));
        %%% Best hyperparameter + Predection
        Mdl = fitcecoc(X_train(:,fs),Y_train);
        %%% Predection
        label = predict(Mdl,X_test(:,fs));
        tab378(k,1) = sum((label == Y_test))/length(Y_test)*100;
        tab378(k,2) = bi2de(fs);
        k=k+1;
    end
end
tab378=sortrows(tab378,'descend');
ALL=sortrows(tab378(:,1),'ascend');
best40=tab378(1:40,:);
toc(tx)
disp('1st test is done')

%% 2éme essai
tx = tic;
for n=1:4
    tab780=zeros(780,2);
    k=1;
    for i=1:40
        for j=i+1:40
            fs=or(de2bi(best40(i,2),28),de2bi(best40(j,2),28));
            %%% Best hyperparameter + Predection
            Mdl = fitcecoc(X_train(:,fs),Y_train);
            
            %%% Predection
            label = predict(Mdl,X_test(:,fs));
            tab780(k,1) = sum((label == Y_test))/length(Y_test)*100;
            tab780(k,2) = bi2de(fs);
            k=k+1;
        end
    end
    tab780=sortrows(tab780,'descend');
    
    best40(41:80,:)=tab780(1:40,:);
    
    best40=sortrows(best40,'descend');
    ALL=[ALL;sortrows(best40(:,1),'ascend')];
    toc(tx)
    disp(['2nd test N°',num2str(n),' is done'])
end

tx = tic;
fs=or(de2bi(best40(1,2),28),28);
Mdl = fitcecoc(X_train,Y_train)


label = predict(Mdl,X_validation(:,fs));


table(Y_validation,label,'VariableNames',...
    {'TrueLabel','PredictedLabel'})

toc(tx)
disp('Validation is done')

Final = sum((label == Y_validation))/length(Y_validation)*100
%     plot(ALL)
