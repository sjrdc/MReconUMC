function res = mtimes(gg,data) 
% Simple 12D NUFFT operator
% Data, kspace and weights come in as cells. 
% Cells represent different data chunks

% Set parameters
num_data=numel(gg.k);
eps=gg.precision; 


% Loop over the data chunks
for n=1:num_data;
    
    % Check what dimensions require new trajectory coordinates
    Id=gg.Id{n};
    Kd=gg.Kd{n};
%     pos=find(size(gg.k)>1);
%     
%     % Predefine the string for indexing
%     varlist={'z','coil','dyn','ph','ech','loc','mix','ex1','ex2','avg'};
%     cnt=1;
%     base='';
%     for j=1:12-2;if sum(pos(pos==j))>0;base(cnt:cnt+numel(varlist{j}))=[varlist{j},','];cnt=cnt+numel(varlist{j})+1; else base(cnt:cnt+1)='1,';cnt=cnt+2;end;end;base(end)=[];
    
 
    if gg.adjoint==-1 % NUFFT^(-1)

        % non-Cartesian k-space to Cartesian image domain || type 1
        data{n}=reshape(data{n},[Kd(1)*Kd(2) Kd(3:end)]);
        Id(4)=0;
        res=zeros(Id);
        nj=gg.nj{n};

        % Loop over all dimensions and update kpos if required
        % For now I assumed that different Z always have the same trajectory
        for avg=1:Kd(12)
        for ex2=1:Kd(11)
        for ex1=1:Kd(10)
        for mix=1:Kd(9)
        for loc=1:Kd(8)
        for ech=1:Kd(7)
        for ph=1:Kd(6)
        for dyn=1:Kd(5)
        for z=1:Kd(3)
            data_tmp=double(data{n}(:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg));
            k_tmp=gg.k{n}(:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);
            parfor coil=1:Kd(4)
                res_tmp(:,:,coil)=single(nufft2d1(nj,real(k_tmp),...
                        imag(k_tmp),data_tmp(:,:,coil),-1,eps,Id(1),Id(2)));
            end
            res{n}(:,:,z,:,dyn,ph,ech,loc,mix,ex1,ex2,avg)=res_tmp;
        end
        end
        end
        end
        end
        end
        end
        end
        end

    else
        % Cartesian image domain to non-Cartesian k-space || type 2
        Kd(4)=0;
        res=zeros(Kd{n});
        
        % Loop over all dimensions and update kpos if required
        % For now I assumed that different Z always have the same trajectory
        for avg=1:Id(12)
        for ex2=1:Id(11)
        for ex1=1:Id(10)
        for mix=1:Id(9)
        for loc=1:Id(8)
        for ech=1:Id(7)
        for ph=1:Id(6)
        for dyn=1:Id(5)
        for coil=1:Id(4)
        for z=1:Id(3)
                    res{n}(:,:,z,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=single(reshape(nufft2d2(gg.nj{n},real(gg.k{n}(:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg)),...
                        imag(gg.k{n}(:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg)),1,eps,Id(1),Id(2),double(data{n}(:,:,z,c,dyn,ph,ech,loc,mix,ex1,ex2,avg))),[Kd(1),Kd(2)]));
        end
        end
        end
        end
        end
        end
        end
        end
        end
        end
    end
end

% END  
end  

