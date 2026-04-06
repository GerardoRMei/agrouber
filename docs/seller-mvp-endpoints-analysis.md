# Analisis MVP Seller: CRUD vs Endpoints Custom

## Contexto actual

Hoy el proyecto ya tiene una base funcional para el seller onboarding en frontend Flutter y una base de dominio suficiente en backend Strapi.

### Ya implementado en frontend

- Login y sesion basica
- Flujo de registro seller
- Pantalla de estado del seller
- Integracion con:
  - `POST /api/auth/local`
  - `POST /api/public-auth/register/seller`
  - lectura de estado via `GET /api/users/me?populate=seller`

### Ya existente en backend

El modelo `Seller` ya soporta:

- `storeName`
- `description`
- `contactPhone`
- `isVerified`
- `status: pending | approved | rejected`
- relacion 1:1 con usuario
- relacion 1:N con productos

El modelo `Product` ya soporta:

- `name`
- `description`
- `sku`
- `price`
- `unit`
- `minOrderQty`
- `isActive`
- relacion con `seller`
- relacion con `category`

Actualmente `Product` usa router y controller core de Strapi, es decir, hoy esta expuesto como CRUD generico.

## Lo que falta para el MVP seller

Para que el seller realmente pueda operar dentro del MVP faltan estos desarrollos:

### 1. Alta de producto

Se necesita:

- formulario de producto en Flutter
- modelo frontend especifico para producto del seller
- servicio API para crear producto
- validaciones de campos
- feedback de exito y error

### 2. Mis productos

Se necesita:

- pantalla con listado de productos del seller autenticado
- estado vacio
- refresh
- acciones minimas del MVP

Acciones recomendadas:

- ver productos
- crear producto
- editar producto
- activar o desactivar producto

### 3. Gate por estatus del seller

No cualquier seller deberia operar productos.

Regla recomendada:

- `pending`: no puede crear productos
- `rejected`: no puede crear productos
- `approved`: puede operar su catalogo

### 4. Resolucion confiable de identidad seller

El frontend necesita conocer con claridad:

- si el usuario autenticado tiene seller
- cual es su `sellerId`
- cual es su `status`

## Que puede salir con CRUD puro

Tecnica y rapidamente, estas operaciones podrian salir usando CRUD generico de Strapi:

- `GET /api/products?filters[seller][id][$eq]=...`
- `POST /api/products`
- `PUT /api/products/:id`
- `GET /api/categories`

Eso puede funcionar para pruebas internas o un MVP muy temprano, pero tiene varias debilidades:

- el frontend necesita conocer el `sellerId`
- el frontend termina controlando filtros sensibles
- la seguridad depende demasiado de permisos y configuracion de Strapi
- la logica de negocio queda dispersa

## Que deberia manejarse con endpoints custom

Para el MVP serio de seller, estas operaciones deberian ir por endpoints custom y no por CRUD generico.

### 1. `GET /api/sellers/me`

Este endpoint deberia devolver la identidad seller del usuario autenticado.

#### Por que custom

- evita que el frontend dependa de `users/me?populate=seller`
- oculta detalles internos de Strapi
- deja un contrato limpio y estable para la app

#### Respuesta sugerida

```json
{
  "userId": 12,
  "seller": {
    "id": 5,
    "storeName": "Mi tienda",
    "status": "approved",
    "isVerified": true
  }
}
```

### 2. `GET /api/sellers/products`

Este endpoint deberia listar solo los productos del seller autenticado.

#### Por que custom

- el backend resuelve el seller a partir del JWT
- el frontend no necesita mandar `sellerId`
- se evita exponer filtros de ownership desde cliente
- permite devolver shape optimizado para la app

### 3. `POST /api/sellers/products`

Este endpoint deberia crear un producto para el seller autenticado.

#### Por que custom

- valida que el usuario tenga seller
- valida que el seller este `approved`
- fuerza la relacion `seller` desde backend
- evita confiar en un `sellerId` enviado por cliente

### 4. `PATCH /api/sellers/products/:id`

Este endpoint deberia editar solo productos del seller autenticado.

#### Por que custom

- valida ownership
- evita que un seller edite productos ajenos
- permite restringir campos editables

### 5. `PATCH /api/sellers/products/:id/toggle-active`

Este endpoint deberia activar o desactivar un producto.

#### Por que custom

- modela una accion de negocio clara
- evita mandar el objeto completo solo para cambiar `isActive`
- permite validar ownership y estado seller

## Que no urge customizar

Para el MVP, estas partes pueden mantenerse en CRUD o lectura generica:

- categorias publicas si solo son lectura
- catalogo publico para compradores
- lectura publica de productos activos

## Frontera recomendada para el MVP

### CRUD o lectura generica

- categorias
- catalogo comprador

### Endpoints custom seller

- `GET /api/sellers/me`
- `GET /api/sellers/products`
- `POST /api/sellers/products`
- `PATCH /api/sellers/products/:id`
- `PATCH /api/sellers/products/:id/toggle-active`

## Reglas de negocio que no deberian vivir en frontend

Estas reglas deben quedar encapsuladas en backend:

- identidad real del seller autenticado
- ownership del producto
- permiso para operar productos solo si `status == approved`

## Orden recomendado de implementacion

### Fase 1

- `GET /api/sellers/me`
- validacion de estado seller

### Fase 2

- `GET /api/sellers/products`
- pantalla "Mis productos"

### Fase 3

- `POST /api/sellers/products`
- pantalla "Alta de producto"

### Fase 4

- `PATCH /api/sellers/products/:id`
- `PATCH /api/sellers/products/:id/toggle-active`

## Conclusion

Si el objetivo es sacar un MVP de seller bien armado, el onboarding puede convivir con endpoints parcialmente genericos, pero la operacion de productos ya deberia pasar por endpoints custom.

La razon principal no es tecnica sino de negocio y seguridad:

- el seller debe operar solo sobre sus propios productos
- solo un seller aprobado debe poder publicar
- el frontend no deberia ser quien decida o resuelva ownership

La mejor siguiente fase es construir el bloque `seller products` alrededor de endpoints custom y no alrededor del CRUD generico de Strapi.
