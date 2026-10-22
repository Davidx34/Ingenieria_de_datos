-- motor: mysql 8.0
-- parcial practico 2 - cicloverde s.a.s. (operacion pedal)

-- R2 DDL
drop database if exists cicloverde;
create database cicloverde character set utf8mb4;
use cicloverde;

create table estaciones (
    id_estacion int not null auto_increment,
    nombre      varchar(50) not null,
    barrio      varchar(50) not null,
    capacidad   int not null,
    activa      boolean not null default true,
    constraint pk_estaciones primary key (id_estacion),
    constraint uq_estaciones_nombre unique (nombre),
    constraint chk_estaciones_capacidad check (capacidad > 0)
);

create table bicicletas (
    id_bici       int not null auto_increment,
    codigo        varchar(10) not null,
    modelo        varchar(40) not null,
    estado        varchar(10) not null default 'ACTIVA',
    km_recorridos decimal(7,1) not null default 0,
    id_estacion   int not null,
    constraint pk_bicicletas primary key (id_bici),
    constraint uq_bicicletas_codigo unique (codigo),
    constraint chk_bicicletas_estado check (estado in ('ACTIVA','TALLER','BAJA')),
    constraint chk_bicicletas_km check (km_recorridos >= 0),
    constraint fk_bicicletas_estacion foreign key (id_estacion) references estaciones (id_estacion)
);

create table usuarios (
    id_usuario     int not null auto_increment,
    documento      varchar(15) not null,
    nombres        varchar(50) not null,
    apellidos      varchar(50) not null,
    email          varchar(80) null,
    telefono       varchar(15) null,
    plan           varchar(10) not null default 'BASICO',
    fecha_registro date not null,
    id_referidor   int null,
    constraint pk_usuarios primary key (id_usuario),
    constraint uq_usuarios_documento unique (documento),
    constraint uq_usuarios_email unique (email),
    constraint chk_usuarios_plan check (plan in ('BASICO','PREMIUM'))
);

create table accesorios (
    id_accesorio int not null auto_increment,
    nombre       varchar(40) not null,
    precio       decimal(8,2) not null,
    constraint pk_accesorios primary key (id_accesorio),
    constraint uq_accesorios_nombre unique (nombre),
    constraint chk_accesorios_precio check (precio > 0)
);

create table viajes (
    id_viaje            int not null auto_increment,
    id_usuario          int not null,
    id_bici             int not null,
    id_estacion_origen  int not null,
    id_estacion_destino int null,
    fecha_inicio        datetime not null,
    fecha_fin           datetime null,
    km                  decimal(5,1) not null default 0,
    estado              varchar(12) not null default 'EN_CURSO',
    calificacion        smallint null,
    constraint pk_viajes primary key (id_viaje),
    constraint chk_viajes_km check (km >= 0),
    constraint chk_viajes_estado check (estado in ('EN_CURSO','FINALIZADO','CANCELADO')),
    constraint chk_viajes_calificacion check (calificacion between 1 and 5),
    constraint fk_viajes_usuario foreign key (id_usuario) references usuarios (id_usuario),
    constraint fk_viajes_bici foreign key (id_bici) references bicicletas (id_bici),
    constraint fk_viajes_origen foreign key (id_estacion_origen) references estaciones (id_estacion),
    constraint fk_viajes_destino foreign key (id_estacion_destino) references estaciones (id_estacion)
);

-- clave compuesta: un accesorio no se repite en el mismo viaje (RN-04)
create table viaje_accesorio (
    id_viaje     int not null,
    id_accesorio int not null,
    cantidad     int not null default 1,
    constraint pk_viaje_accesorio primary key (id_viaje, id_accesorio),
    constraint chk_viaje_accesorio_cantidad check (cantidad > 0),
    constraint fk_va_viaje foreign key (id_viaje) references viajes (id_viaje),
    constraint fk_va_accesorio foreign key (id_accesorio) references accesorios (id_accesorio)
);

create table historial_bicicletas (
    id_historial    int not null auto_increment,
    id_bici         int not null,
    estado_anterior varchar(10) not null,
    estado_nuevo    varchar(10) not null,
    fecha_cambio    datetime not null default current_timestamp,
    constraint pk_historial primary key (id_historial),
    constraint fk_historial_bici foreign key (id_bici) references bicicletas (id_bici)
);

-- DATOS INICIALES
insert into estaciones (id_estacion, nombre, barrio, capacidad, activa) values
(1, 'Estación Las Aguas',       'La Candelaria', 12, true),
(2, 'Estación Parque 93',       'Chapinero',     15, true),
(3, 'Estación Usaquén',         'Usaquén',       10, true),
(4, 'Estación Kennedy',         'Kennedy',        8, false);

insert into bicicletas (id_bici, codigo, modelo, estado, km_recorridos, id_estacion)
values
(1, 'CV-E01',   'Volta E2',          'ACTIVA', 1350.5, 1),
(2, 'CV-E02',   'Volta E2',          'ACTIVA', 820.0, 1),
(3, 'CV-M01',   'Urbana M1',         'ACTIVA', 240.0, 1),
(4, 'CV-E03',   'Volta E3',          'ACTIVA', 1620.0, 2),
(5, 'CV-M02',   'Urbana M1',         'TALLER',    95.5, 2),
(6, 'CV-E04',   'Volta E3',          'ACTIVA', 410.0, 3),
(7, 'CV-M03',   'Urbana M2',         'BAJA',   2100.0, 3),
(8, 'CV-E-PRO', 'Prototipo Volta X', 'ACTIVA',   60.0, 3);

-- Los usuarios que refieren se insertan antes que sus referidos.
insert into usuarios (id_usuario, documento, nombres, apellidos, email, telefono,
plan, fecha_registro, id_referidor) values
(1, '1036101001', 'Valentina', 'Ríos Mejía',    'vale.rios@gmail.com',
'3001234567', 'PREMIUM', '2025-11-03', null),
(2, '1036101002', 'Santiago', 'Gómez Ruiz',     'sgomez@urosario.edu.co',
'3012223344', 'BASICO', '2026-01-15', 1),
(3, '1036101003', 'Isabella', 'Torres Cano',    'isa.torres@hotmail.com', null,
'PREMIUM', '2026-02-20', 1),
(4, '1036101004', 'Mateo',     'Herrera Díaz', null,
'312456789', 'BASICO', '2026-03-31', 2),
(5, '1036101005', 'Camila',    'Ortiz León',    'camila.ortiz@urosario.edu.co',
'3157654321', 'BASICO', '2026-05-10', null),
(6, '1036101006', 'Sebastián', 'Vargas Pino',   'sebas.vargas@gmail.com',
'3209876543', 'PREMIUM', '2026-07-01', 3),
(7, '1036101007', 'Daniela',   'Cruz Mora',     'DCRUZ@UROSARIO.EDU.CO',
'3104445566', 'BASICO', '2026-09-12', null),
(8, '1036101008', 'Andrés',    'Patiño Gil',    null,                      null,
'BASICO', '2026-10-01', 5);

insert into accesorios (id_accesorio, nombre, precio) values
(1, 'Casco',          2500),
(2, 'Candado',        1500),
(3, 'Canasta',        1000),
(4, 'Luz recargable', 2000);

insert into viajes (id_viaje, id_usuario, id_bici, id_estacion_origen,
id_estacion_destino, fecha_inicio, fecha_fin, km, estado, calificacion) values
(1, 1, 1, 1, 2,     '2026-10-01 07:10:00', '2026-10-01 07:32:00', 5.2, 'FINALIZADO',
5),
(2, 2, 3, 1, 3,     '2026-10-01 08:00:00', '2026-10-01 08:25:00', 3.8, 'FINALIZADO',
4),
(3, 3, 4, 2, 1,     '2026-10-02 18:05:00', '2026-10-02 18:40:00', 6.0, 'FINALIZADO',
2),
(4, 1, 2, 1, 1,     '2026-10-03 12:00:00', '2026-10-03 12:15:00', 2.1, 'FINALIZADO',
null),
(5, 3, 6, 3, 2,     '2026-10-04 09:30:00', '2026-10-04 09:58:00', 4.4, 'FINALIZADO',
3),
(6, 5, 1, 2, null, '2026-10-05 10:00:00', null,                    0.0, 'CANCELADO',
null),
(7, 6, 4, 2, 3,     '2026-10-06 17:20:00', '2026-10-06 18:05:00', 11.0, 'FINALIZADO',
5),
(8, 2, 2, 1, 2,     '2026-10-08 07:45:00', '2026-10-08 08:05:00', 4.9, 'FINALIZADO',
1),
(9, 3, 6, 3, null, '2026-10-09 14:00:00', null,                    0.8, 'CANCELADO',
null),
(10, 1, 6, 3, 1,    '2026-10-11 06:50:00', '2026-10-11 07:20:00', 6.0, 'FINALIZADO',
4),
(11, 5, 3, 1, 3,    '2026-10-12 16:00:00', '2026-10-12 16:18:00', 2.7, 'FINALIZADO',
5),
(12, 6, 8, 3, null, '2026-10-14 11:00:00', null,                   0.0, 'CANCELADO',
null),
(13, 4, 2, 1, null, '2026-10-15 19:30:00', null,                   1.2, 'EN_CURSO',
null),
(14, 2, 6, 3, null, '2026-10-15 19:45:00', null,                                    0.0, 'EN_CURSO',
null);

insert into viaje_accesorio (id_viaje, id_accesorio, cantidad) values
(1, 1, 1), (1, 2, 1),
(3, 1, 1),
(5, 3, 1),
(7, 1, 1), (7, 3, 1),
(8, 2, 1),
(10, 1, 1),
(11, 2, 1),
(13, 1, 1);

-- R3 ALTER TABLE
-- R3.a
alter table usuarios
    add constraint fk_usuarios_referidor foreign key (id_referidor) references usuarios (id_usuario);

-- R3.b
alter table viajes
    add constraint chk_viajes_fechas check (fecha_fin is null or fecha_fin >= fecha_inicio);

-- R4.a un solo insert, sin escribir el id
insert into usuarios (documento, nombres, apellidos, email, telefono, plan, fecha_registro, id_referidor) values
('1036101009', 'Lucía',      'Arango Vélez',     'lucia.arango@gmail.com', '3165551234', 'PREMIUM', '2026-10-14', 2),
('1036101010', 'Juan Pablo', 'Restrepo Sierra',  'jp.restrepo@unal.edu.co', '3001112222', 'BASICO',  '2026-10-15', null);

-- R4.b RN-06: activas con mas de 1.500 km pasan a taller (la que esta en baja no cambia)
update bicicletas set estado = 'TALLER' where estado = 'ACTIVA' and km_recorridos > 1500;

-- R4.c viajes cancelados con 0 km (pruebas del sistema)
delete from viajes where estado = 'CANCELADO' and km = 0;

-- R4.d
select (select count(*) from usuarios) as usuarios,
       (select count(*) from viajes) as viajes,
       (select count(*) from bicicletas where estado = 'TALLER') as bicis_en_taller;

-- R5.a
select id_viaje, id_estacion_origen, km, calificacion
from viajes
where estado = 'FINALIZADO' and km between 2 and 6 and id_estacion_origen in (1, 2)
order by km desc;

-- R5.b
select codigo, modelo, estado, km_recorridos
from bicicletas
where estado != 'BAJA' and (km_recorridos < 300 or km_recorridos >= 1200)
order by codigo;

-- R5.c
select id_viaje, id_usuario, estado, fecha_inicio
from viajes
where fecha_fin is null and estado not in ('CANCELADO')
order by fecha_inicio;

-- R5.d
select nombres, apellidos, plan, fecha_registro
from usuarios
where not plan = 'PREMIUM' and fecha_registro <= '2026-03-31'
order by fecha_registro;

-- R6.a
select concat(nombres, ' ', apellidos) as usuario, lower(email) as correo
from usuarios
where email is not null
  and email not like '%@gmail.com'
  and email not like '%@hotmail.com'
order by usuario;

-- R6.b electricas de serie: CV-E + exactamente dos caracteres
select codigo, upper(modelo) as modelo, km_recorridos,
       round(km_recorridos / 1500 * 100, 1) as pct_revision
from bicicletas
where codigo like 'CV-E__'
order by km_recorridos desc;

-- R6.c
select concat(nombres, ' ', apellidos) as usuario,
       coalesce(telefono, 'SIN TELÉFONO') as telefono,
       length(telefono) as digitos
from usuarios
where telefono is null or length(telefono) <> 10
order by usuario;

-- R7.a
select e.nombre as estacion,
       count(*) as viajes,
       sum(v.km) as km_totales,
       round(avg(v.km), 2) as km_promedio,
       min(v.km) as km_minimo,
       max(v.km) as km_maximo
from viajes v
join estaciones e on e.id_estacion = v.id_estacion_origen
where v.estado = 'FINALIZADO'
group by e.id_estacion, e.nombre
order by km_totales desc;

-- R7.b
select concat(u.nombres, ' ', u.apellidos) as usuario,
       count(*) as viajes,
       sum(v.km) as km_totales
from viajes v
join usuarios u on u.id_usuario = v.id_usuario
where v.estado = 'FINALIZADO'
group by u.id_usuario, u.nombres, u.apellidos
having count(*) >= 2 and sum(v.km) > 10
order by km_totales desc;

-- R8.a
select v.id_viaje,
       concat(u.nombres, ' ', u.apellidos) as usuario,
       b.codigo as bicicleta,
       e.nombre as origen,
       v.km,
       timestampdiff(minute, v.fecha_inicio, v.fecha_fin) as minutos
from viajes v
inner join usuarios u on u.id_usuario = v.id_usuario
inner join bicicletas b on b.id_bici = v.id_bici
inner join estaciones e on e.id_estacion = v.id_estacion_origen
where v.estado = 'FINALIZADO' and u.plan = 'PREMIUM'
order by v.id_viaje;

-- R8.b
select e.nombre as estacion,
       e.capacidad,
       count(b.id_bici) as bicicletas,
       e.capacidad - count(b.id_bici) as cupos_libres
from estaciones e
left join bicicletas b on b.id_estacion = e.id_estacion
group by e.id_estacion, e.nombre, e.capacidad
order by e.id_estacion;

-- R8.c
select u.id_usuario,
       concat(u.nombres, ' ', u.apellidos) as usuario,
       coalesce(concat(r.nombres, ' ', r.apellidos), 'SIN REFERIDOR') as referido_por
from usuarios u
left join usuarios r on r.id_usuario = u.id_referidor
order by u.id_usuario;

-- R8.d
select v.id_viaje, a.nombre as accesorio, va.cantidad,
       va.cantidad * a.precio as subtotal
from viaje_accesorio va
join viajes v on v.id_viaje = va.id_viaje
join accesorios a on a.id_accesorio = va.id_accesorio
where v.estado = 'FINALIZADO'
order by v.id_viaje, a.nombre;

-- R9.a
select id_viaje, km
from viajes
where estado = 'FINALIZADO'
  and km > (select avg(km) from viajes where estado = 'FINALIZADO')
order by km desc;

-- R9.b
select nombres, apellidos, fecha_registro
from usuarios
where id_usuario not in (select id_usuario from viajes)
order by fecha_registro;

-- R9.c subconsulta correlacionada
select b.codigo, b.id_estacion, b.km_recorridos
from bicicletas b
where b.km_recorridos > (select avg(b2.km_recorridos)
                         from bicicletas b2
                         where b2.id_estacion = b.id_estacion)
order by b.codigo;

-- R9.d
select a.nombre, a.precio
from accesorios a
where not exists (select 1 from viaje_accesorio va where va.id_accesorio = a.id_accesorio);

-- R10.a VISTA
create view vw_actividad_usuarios as
select u.id_usuario,
       concat(u.nombres, ' ', u.apellidos) as usuario,
       u.plan,
       count(v.id_viaje) as total_viajes,
       coalesce(sum(v.km), 0) as km_totales
from usuarios u
left join viajes v on v.id_usuario = u.id_usuario and v.estado = 'FINALIZADO'
group by u.id_usuario, u.nombres, u.apellidos, u.plan;

select usuario, plan, total_viajes, km_totales
from vw_actividad_usuarios
order by km_totales desc, usuario;

-- R10.b ÍNDICES
-- primero el estado (igualdad) y luego la fecha (rango): el motor filtra por estado y recorre el rango ordenado.
create index idx_viajes_estado_fecha on viajes (estado, fecha_inicio);
-- las busquedas por apellido evitan recorrer toda la tabla de usuarios.
create index idx_usuarios_apellidos on usuarios (apellidos);

-- R11 FUNCIÓN
delimiter //
create function fn_costo_viaje(p_km decimal(5,1), p_plan varchar(10))
returns decimal(10,2)
deterministic
begin
    declare v_costo decimal(10,2);
    set v_costo = 1800 + 700 * p_km;
    if p_plan = 'PREMIUM' then
        set v_costo = v_costo * 0.75;
    end if;
    return round(v_costo, 2);
end //
delimiter ;

select fn_costo_viaje(10, 'BASICO'), fn_costo_viaje(10, 'PREMIUM');

select v.id_viaje, u.plan, v.km, fn_costo_viaje(v.km, u.plan) as costo
from viajes v
join usuarios u on u.id_usuario = v.id_usuario
where v.estado = 'FINALIZADO' and v.id_estacion_origen = 1
order by costo desc;

-- R12 TRIGGER
delimiter //
create trigger trg_bicicletas_estado
after update on bicicletas
for each row
begin
    if old.estado <> new.estado then
        insert into historial_bicicletas (id_bici, estado_anterior, estado_nuevo)
        values (old.id_bici, old.estado, new.estado);
    end if;
end //
delimiter ;

update bicicletas set estado = 'ACTIVA' where codigo = 'CV-M02';
update bicicletas set estado = 'BAJA'   where codigo = 'CV-E03';
update bicicletas set km_recorridos = km_recorridos + 5 where codigo = 'CV-E01';

select b.codigo, h.estado_anterior, h.estado_nuevo, h.fecha_cambio
from historial_bicicletas h
join bicicletas b on b.id_bici = h.id_bici
order by h.id_historial;

-- R13 PROCEDIMIENTO
delimiter //
create procedure sp_iniciar_viaje(in p_id_usuario int, in p_id_bici int, in p_fecha datetime)
begin
    declare v_estado varchar(10);
    declare v_estacion int;
    declare v_en_curso int;

    select estado, id_estacion into v_estado, v_estacion
    from bicicletas where id_bici = p_id_bici;

    if v_estado is null or v_estado <> 'ACTIVA' then
        signal sqlstate '45000' set message_text = 'La bicicleta no esta ACTIVA: no puede iniciar un viaje';
    end if;

    select count(*) into v_en_curso
    from viajes where id_usuario = p_id_usuario and estado = 'EN_CURSO';

    if v_en_curso > 0 then
        signal sqlstate '45000' set message_text = 'El usuario ya tiene un viaje EN_CURSO';
    end if;

    insert into viajes (id_usuario, id_bici, id_estacion_origen, fecha_inicio)
    values (p_id_usuario, p_id_bici, v_estacion, p_fecha);

    select last_insert_id() as id_viaje;
end //
delimiter ;

call sp_iniciar_viaje(7, 3, '2026-10-16 08:00:00');
call sp_iniciar_viaje(8, 4, '2026-10-16 08:05:00');
call sp_iniciar_viaje(2, 1, '2026-10-16 08:10:00');

select * from viajes where id_usuario in (2, 7, 8) order by id_viaje;