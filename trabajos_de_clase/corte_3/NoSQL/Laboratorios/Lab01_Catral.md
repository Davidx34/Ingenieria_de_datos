use saborya;

// ==========================================
// PARTE A · Entorno y primeros documentos
// ==========================================

// A1. Comprueba que estás en la base saborya y lista sus colecciones.
db.getName();
db.getCollectionNames();
// Resultado: "saborya", colecciones: \[ 'clientes', 'pedidos', 'productos', 'restaurantes' ]

// A2. Cuenta los documentos de cada una de las cuatro colecciones.
db.restaurantes.countDocuments();
db.clientes.countDocuments();
db.productos.countDocuments();
db.pedidos.countDocuments();
// Resultado: restaurantes: 10, clientes: 8, productos: 24, pedidos: 18.

// A3. Inserta el restaurante con \_id "R11": Café Arriero.
db.restaurantes.insertOne({
\_id: "R11",
nombre: "Café Arriero",
categoria: "Cafetería",
ciudad: "Medellín",
barrio: "Laureles",
calificacion: 4.5,
domicilio: true,
ubicacion: {
type: "Point",
coordinates: \[-75.5925, 6.2442]
},
etiquetas: \["café", "postres"]
});
// Resultado: { "acknowledged" : true, "insertedId" : "R11" }

// A4. Inserta dos productos del R11 en una sola operación.
db.productos.insertMany(\[
{
\_id: "P25",
restaurante\_id: "R11",
nombre: "Tinto campesino",
tipo: "bebida",
precio: 3500,
stock: 100,
disponible: true,
volumen\_ml: 200
},
{
\_id: "P26",
restaurante\_id: "R11",
nombre: "Torta de zanahoria",
tipo: "postre",
precio: 9000,
stock: 20,
disponible: true
}
]);
// Resultado: { "acknowledged" : true, "insertedIds" : \[ "P25", "P26" ] }

// A5. Muestra los restaurantes de Medellín y cuenta los productos del R11.
db.restaurantes.find({ ciudad: "Medellín" });
db.productos.countDocuments({ restaurante\_id: "R11" });
// Resultado: Muestra los restaurantes de Medellín (incluyendo R11) y el conteo de productos de R11 es 2.



// ==========================================
// PARTE B · Modelado y validación de reseñas
// ==========================================

// B1. Comprueba con $type que la fecha de todos los pedidos es Date y ningún precio es texto.
db.pedidos.countDocuments({ fecha: { $not: { $type: "date" } } });
db.productos.countDocuments({ precio: { $type: "string" } });
// Resultado: 0 para ambas consultas, confirmando que las fechas son tipo Date y los precios son numéricos.

/\* B2. Respuesta sobre modelado de reseñas:
Las reseñas se deben almacenar en una colección propia (colección independiente) y no embebidas dentro del documento del restaurante.
Justificación:

1. Límite de 16 MB de MongoDB: Un restaurante popular puede recibir miles de reseñas con el tiempo. Si se embeben, el documento del restaurante superaría rápidamente el límite de 16 MB por documento.
2. Patrón de acceso: La interfaz del restaurante muestra un resumen (promedio y total) y un conjunto paginado de reseñas recientes. Una colección separada permite indexar por restaurante\_id y fecha, ordenar y limitar eficientemente.
3. Datos del cliente copiados: Se copia el \_id y el nombre del cliente para evitar $lookups innecesarios al listar las reseñas, optimizando las lecturas (desnormalización por rendimiento de lectura), ya que el nombre del usuario rara vez cambia. \*/

// B3. Crea la colección resenas con una regla $jsonSchema.
db.createCollection("resenas", {
validator: {
$jsonSchema: {
bsonType: "object",
required: \["restaurante\_id", "cliente", "calificacion", "texto", "fecha"],
properties: {
restaurante\_id: { bsonType: "string" },
cliente: {
bsonType: "object",
required: \["id", "nombre"],
properties: {
id: { bsonType: "string" },
nombre: { bsonType: "string" }
}
},
calificacion: {
bsonType: "int",
minimum: 1,
maximum: 5
},
texto: {
bsonType: "string",
minLength: 5
},
fecha: { bsonType: "date" },
fotos: {
bsonType: "array",
maxItems: 4,
items: { bsonType: "string" }
}
}
}
}
});
// Resultado: { "ok" : 1 }

// B4. Inserta cuatro reseñas válidas con zona horaria de Colombia (-05:00).
db.resenas.insertMany(\[
{
restaurante\_id: "R02",
cliente: { id: "C01", nombre: "Laura Gómez" },
calificacion: NumberInt(5),
texto: "El ramen llegó caliente y bien empacado",
fecha: new Date("2026-10-15T20:10:00-05:00")
},
{
restaurante\_id: "R02",
cliente: { id: "C08", nombre: "Julián Castro" },
calificacion: NumberInt(4),
texto: "Buen sushi, pero tardó 50 minutos",
fecha: new Date("2026-10-16T21:30:00-05:00")
},
{
restaurante\_id: "R10",
cliente: { id: "C07", nombre: "Daniela Martínez" },
calificacion: NumberInt(5),
texto: "La cazuela es abundante",
fotos: \[
"https://cdn.saborya.co/r/301.jpg",
"https://cdn.saborya.co/r/302.jpg"
],
fecha: new Date("2026-10-17T13:45:00-05:00")
},
{
restaurante\_id: "R04",
cliente: { id: "C03", nombre: "Valentina Ríos" },
calificacion: NumberInt(2),
texto: "Las papas llegaron frías",
fecha: new Date("2026-10-18T19:05:00-05:00")
}
]);
// Resultado: { "acknowledged" : true, "insertedIds" : \[ ... ] }

// B5. Intenta insertar una reseña con calificación 6 para el R01.
try {
db.resenas.insertOne({
restaurante\_id: "R01",
cliente: { id: "C02", nombre: "Carlos Pérez" },
calificacion: NumberInt(6),
texto: "Excelente comida",
fecha: new Date()
});
} catch (e) {
print(e.message);
}
/\* Resultado y explicación:
Error: Document failed validation.
Explicación: La regla del esquema JSON que produjo el error es la restricción `maximum: 5` del campo `calificacion`, ya que se intentó registrar un valor de 6, excediendo el rango permitido. \*/

// B6. Muestra las reseñas de Laura Gómez (C01) y las que tienen al menos una foto.
db.resenas.find({ "cliente.id": "C01" });
db.resenas.find({ "fotos.0": { $exists: true } });
// Resultado: Se muestra 1 reseña de Laura Gómez y 1 reseña con fotos (Daniela Martínez en R10).

// B7. Denormalización en el restaurante R02 (promedio 4.5, total de reseñas 2).
db.restaurantes.updateOne(
{ \_id: "R02" },
{
$set: {
resumen\_resenas: {
promedio: 4.5,
total: 2
}
}
}
);
// Resultado: { "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }

// B8. Obtén la lista de restaurantes distintos que tienen reseñas.
db.resenas.distinct("restaurante\_id");
// Resultado: \[ "R02", "R10", "R04" ]



// ==========================================
// PARTE C · Consultas MQL
// ==========================================

// C1. Platos disponibles con stock menor a 20 unidades (nombre y stock, sin \_id, orden ascendente de stock).
db.productos.find(
{ tipo: "plato", disponible: true, stock: { $lt: 20 } },
{ nombre: 1, stock: 1, \_id: 0 }
).sort({ stock: 1 });
// Resultado: \[ ... ] (conteo documentado según base actual).

// C2. Pedidos con total entre 50.000 y 80.000 pagados en efectivo o nequi (total y método de pago).
db.pedidos.find(
{
total: { $gte: 50000, $lte: 80000 },
metodo\_pago: { $in: \["efectivo", "nequi"] }
},
{ total: 1, metodo\_pago: 1, \_id: 0 }
);
// Resultado: \[ ... ]

// C3. Los 3 restaurantes de Bogotá con mejor calificación (nombre y calificación).
db.restaurantes.find(
{ ciudad: "Bogotá" },
{ nombre: 1, calificacion: 1, \_id: 0 }
).sort({ calificacion: -1 }).limit(3);
// Resultado: \[ ... ]

// C4. Clientes de Bogotá con más de 100 puntos.
db.clientes.find({
ciudad: "Bogotá",
puntos: { $gt: 100 }
});
// Resultado: \[ ... ]

// C5. Pedidos hechos entre el 12 y el 14 de octubre de 2026 que no estén entregados.
db.pedidos.find({
fecha: {
$gte: new Date("2026-10-12T00:00:00-05:00"),
$lte: new Date("2026-10-14T23:59:59-05:00")
},
estado: { $ne: "entregado" }
});
// Resultado: \[ ... ]

// C6. Versión con $elemMatch vs sin $elemMatch
db.pedidos.find({
items: {
$elemMatch: {
precio: { $lt: 10000 },
cantidad: { $gte: 2 }
}
}
});

db.pedidos.find({
"items.precio": { $lt: 10000 },
"items.cantidad": { $gte: 2 }
});
/\* Explicación de C6:
Con $elemMatch se exige que ambas condiciones (precio < 10000 y cantidad >= 2) se cumplan simultáneamente en el MISMO elemento del arreglo 'items'.
Sin $elemMatch, la consulta evalúa a nivel de documento, buscando que exista algún ítem con precio < 10000 y algún ítem con cantidad >= 2 (pueden ser ítems diferentes dentro del mismo pedido), lo cual genera falsos positivos y un conteo mayor. \*/

// C7. Catálogo de productos ordenados del más caro al más barato, página 2 (6 por página, paginación estable).
db.productos.find({})
.sort({ precio: -1, \_id: 1 })
.skip(6)
.limit(6);
// Resultado: \[ ... ]

// C8. Restaurantes que tienen el campo horario o el campo menu\_vegano.
db.restaurantes.find({
$or: \[
{ horario: { $exists: true } },
{ menu\_vegano: { $exists: true } }
]
});
// Resultado: \[ ... ]



// ==========================================
// PARTE D · Actualizaciones, upsert y eliminaciones
// ==========================================

// D1. Sube 1.000 pesos a todos los productos de tipo plato del restaurante R07.
db.productos.updateOne(
{ restaurante\_id: "R07", tipo: "plato" },
{ $inc: { precio: 1000 } }
);
/\* Resultado y explicación:
Matched: 1, Modified: 1.
Explicación: Se usó updateOne. Aunque R07 tiene dos platos, updateOne se detiene y actualiza únicamente el primer documento que coincide con el filtro. Para afectar ambos se debió usar updateMany. \*/

// D2. El pedido PD018 sale a reparto: cámbialo a en\_camino solo si está pendiente (Ejecución 1 y 2).
db.pedidos.updateOne(
{ \_id: "PD018", estado: "pendiente" },
{ $set: { estado: "en\_camino" } }
);
db.pedidos.updateOne(
{ \_id: "PD018", estado: "pendiente" },
{ $set: { estado: "en\_camino" } }
);
/\* Explicación de D2:

* Primera ejecución: matchedCount: 1, modifiedCount: 1 (el pedido cumplía el filtro y cambió a "en\_camino").
* Segunda ejecución: matchedCount: 0, modifiedCount: 0 (el pedido ya no está en estado "pendiente", por lo que el filtro ya no coincide con el documento). \*/

// D3. Agrega "japonesa" a las preferencias de Valentina Ríos (C03) sin repetir (Ejecución 1 y 2).
db.clientes.updateOne(
{ nombre: "Valentina Ríos" },
{ $addToSet: { preferencias: "japonesa" } }
);
db.clientes.updateOne(
{ nombre: "Valentina Ríos" },
{ $addToSet: { preferencias: "japonesa" } }
);
/\* Explicación de D3:

* Primera ejecución: matchedCount: 1, modifiedCount: 1 (añadió "japonesa" al array).
* Segunda ejecución: matchedCount: 1, modifiedCount: 0 ($addToSet detecta que el elemento ya existe, evitando duplicados y sin realizar cambios). \*/

// D4. Registra a Natalia Suárez mediante upsert buscando por email.
db.clientes.updateOne(
{ email: "natalia.suarez@example.com" },
{
$setOnInsert: {
\_id: "C09",
nombre: "Natalia Suárez",
ciudad: "Medellín",
puntos: 0,
direcciones: \[]
}
},
{ upsert: true }
);
// Resultado: matchedCount/modifiedCount o upsertedId según la existencia previa.

// D5. Elimina el campo volumen\_ml del Té verde (P06).
db.productos.updateOne(
{ \_id: "P06" },
{ $unset: { volumen\_ml: "" } }
);
// Resultado: { "acknowledged" : true, "matchedCount" : 1, "modifiedCount" : 1 }

// D6. Elimina las reseñas con calificación menor a 3.
db.resenas.countDocuments({ calificacion: { $lt: 3 } });
db.resenas.deleteMany({ calificacion: { $lt: 3 } });
// Resultado: deletedCount: X (según conteo previo).

// D7. Elimina los pedidos cancelados de Medellín.
let medellinRestIds = db.restaurantes.find({ ciudad: "Medellín" }, { \_id: 1 }).toArray().map(r => r.\_id);
db.pedidos.countDocuments({ estado: "cancelado", restaurante\_id: { $in: medellinRestIds } });
db.pedidos.deleteMany({ estado: "cancelado", restaurante\_id: { $in: medellinRestIds } });
// Resultado: deletedCount: X.

// D8. Verificación final: cuenta los documentos de cada colección.
print("Restaurantes:", db.restaurantes.countDocuments());
print("Clientes:", db.clientes.countDocuments());
print("Productos:", db.productos.countDocuments());
print("Pedidos:", db.pedidos.countDocuments());
print("Reseñas:", db.resenas.countDocuments());
// Resultado: Impresión de los 5 conteos finales de la base saborya.

