use liwi_flor_eterna;
-- Cambiar nombre
update Usuario set nombre='Carolina Soto' where idUsuario=5;
select * from Usuario where nombre='Carolina Soto'

-- Error esperado duplicate entry
update Usuario set correo= 'david.pardo5@liwifloreterna.co' where idUsuario=4;

-- Error esperado: CONSTRAINT `chk_usuario_pv` failed for `liwi_flor_eterna`.`Usuario`
update Usuario set rol = 'Socio' where idUsuario = 6;

-- Hacerlo bien: rol y local a la vez
update Usuario set rol = 'Socio', idPuntoVenta = null where idUsuario = 6;
select idUsuario, rol, idPuntoVenta from Usuario where idUsuario = 6;