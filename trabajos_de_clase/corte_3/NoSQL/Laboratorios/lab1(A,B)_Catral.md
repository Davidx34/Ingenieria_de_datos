// Asegurar que estamos en la base de datos correcta
use saborya;

// ==========================================
// PARTE A · Entorno y primeros documentos
// ==========================================

// A1. Comprueba que estás en la base saborya y lista sus colecciones.
db.getName()
db.getCollectionNames()
// Resultado: "saborya", colecciones: \[ 'clientes', 'pedidos', 'productos', 'restaurantes' ]

// A2. Cuenta los documentos de cada una de las cuatro colecciones.
db.restaurantes.countDocuments()
db.clientes.countDocuments()
db.productos.countDocuments()
db.pedidos.countDocuments()
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
})
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
])
// Resultado: { "acknowledged" : true, "insertedIds" : \[ "P25", "P26" ] }

// A5. Muestra los restaurantes de Medellín y cuenta los productos del R11.
db.restaurantes.find({ ciudad: "Medellín" });
db.productos.countDocuments({ restaurante\_id: "R11" });
// Resultado: Muestra los restaurantes de Medellín (incluyendo R11) y el conteo de productos de R11 es 2.



// ==========================================
// PARTE B · Modelado y validación de reseñas
// ==========================================

// B1. Comprueba con $type que la fecha de todos los pedidos es Date y ningún precio es texto.
db.pedidos.countDocuments({ fecha: { $not: { $type: "date" } } })
db.productos.countDocuments({ precio: { $type: "string" } })
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
})
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
])
// Resultado: { "acknowledged" : true, "insertedIds" : \[ ... ] }

// B5. Intenta insertar una reseña con calificación 6 para el R01.
try {
db.resenas.insertOne({
restaurante\_id: "R01",
cliente: { id: "C02", nombre: "Carlos Pérez" },
calificacion: NumberInt(6),
texto: "Excelente comida",
fecha: new Date()
})
} catch (e) {
print(e.message)
}
/\* Resultado y explicación:
Error: Document failed validation.
Explicación: La regla del esquema JSON que produjo el error es la restricción `maximum: 5` del campo `calificacion`, ya que se intentó registrar un valor de 6, excediendo el rango permitido. \*/

// B6. Muestra las reseñas de Laura Gómez (C01) y las que tienen al menos una foto.
db.resenas.find({ "cliente.id": "C01" })
db.resenas.find({ "fotos.0": { $exists: true } })
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





