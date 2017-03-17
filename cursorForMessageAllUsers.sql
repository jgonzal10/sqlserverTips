--SQL procedure using cursor to send a message to all users from a system when the user dont
--select the user group. The user paramenter can be null or the list of ids separated
--by a , example '1,2,3,45,69'
--By JGO 2017
CREATE PROCEDURE [dbo].[spSendToAllUsers] 
  @acao as char(1),
  @codigo as int=null,
  @segmento as varchar(50)=null,
  @grupo as int=null,
  @usuario as varchar(8000)=null,
  @assunto as varchar(50)=null,
  @mensagem as varchar(800)=null,
  @cadastrante as int
AS 
declare @codigou int

declare @pos int
declare @user varchar(10)

declare @tablemensagens table(segmento varchar(50), grupo int, usuario int, tipo varchar(5), assunto varchar(50), mensagem varchar (50), data_mensagem datetime, cadastrante int)

declare @tbusuarios table(codigo int)

if @usuario is not null
	begin
		set @pos = CHARINDEX(',', @usuario, 1)
		if @pos=0
			begin
				insert into @tbusuarios (codigo) values(@usuario)
			end
		else
			begin
				while @pos > 0
					begin
						SET @user = substring(@usuario,1,@pos-1)
						insert into @tbusuarios (codigo) values(@user)
						set @usuario = substring(@usuario, @pos+1, len(@usuario))
						SET @pos = CHARINDEX(',', @usuario, 1)
					end

				insert into @tbusuarios (codigo) values(@usuario)
			end
	end
if @usuario is null
	begin
		declare cursor1 CURSOR FOR 
		select codigo from usuarios
		where segmento=case when @segmento is null then segmento else @segmento end
		and grupo=case when @grupo is null then grupo else @grupo end
	end
else
	begin
		declare cursor1 CURSOR FOR 
		select codigo from usuarios
		where segmento=case when @segmento is null then segmento else @segmento end
		and grupo=case when @grupo is null then grupo else @grupo end
		and codigo in (select codigo from @tbusuarios)
	end

open cursor1 
fetch cursor1 into 
@codigou
while (@@fetch_status=0) 
begin
	
					insert into @tablemensagens (segmento, grupo, usuario, tipo, assunto, mensagem, data_mensagem, cadastrante) 
					select @segmento, @grupo, @codigou,'N',@assunto, @mensagem, getdate(), @cadastrante from usuarios where codigo = @codigo

	fetch cursor1 into 
	@codigo
end
close cursor1 
DEALLOCATE cursor1 

select 
	*
from
	@tablemensagens t1
