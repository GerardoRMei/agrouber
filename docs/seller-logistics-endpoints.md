# Seller Logistics Endpoints

## Objetivo

Definir los endpoints custom necesarios para que el modulo seller de `Agrorun` cubra:

- informacion comercial del vendedor
- direccion operativa
- cantidad de productos publicados
- asignacion de almacen
- instrucciones de entrega
- dashboard seller para frontend mobile

La idea es evitar que Flutter arme reglas de negocio sensibles en cliente y concentrar la logica en backend.

## Principios

- El seller nunca elige libremente el almacen.
- El backend resuelve identidad del seller a partir del JWT.
- El frontend no manda `sellerId`, `userId` ni `warehouseId` para operar su cuenta.
- La cantidad de productos debe venir calculada por backend.
- La asignacion de almacen debe estar gobernada por operaciones o admin.

## Campos de dominio recomendados

### Seller

```json
{
  "storeName": "Campo Lindo",
  "contactPhone": "229972474",
  "approvalStatus": "approved",
  "address": {
    "addressLine1": "Calle 1",
    "addressLine2": "Interior 2",
    "city": "Veracruz",
    "state": "Veracruz",
    "postalCode": "91700",
    "reference": "Frente al mercado"
  },
  "productCount": 8,
  "assignedWarehouse": {
    "id": 4,
    "name": "Almacen Norte"
  },
  "warehouseAssignmentStatus": "assigned",
  "deliveryInstructions": "Entrega de lunes a viernes de 8:00 a 14:00"
}
```

## Endpoints para seller autenticado

### 1. `GET /api/sellers/me`

Devuelve el perfil operativo del seller autenticado.

Uso:
- cargar la pantalla de perfil seller
- leer direccion actual
- conocer si ya tiene almacen asignado
- mostrar cantidad de productos

Response sugerido:

```json
{
  "seller": {
    "id": 12,
    "storeName": "Campo Lindo",
    "approvalStatus": "approved",
    "contactPhone": "229972474",
    "address": {
      "addressLine1": "Calle 1",
      "addressLine2": "Interior 2",
      "city": "Veracruz",
      "state": "Veracruz",
      "postalCode": "91700",
      "reference": "Frente al mercado"
    },
    "productCount": 8,
    "assignedWarehouse": {
      "id": 4,
      "name": "Almacen Norte"
    },
    "warehouseAssignmentStatus": "assigned",
    "deliveryInstructions": "Entrega de lunes a viernes de 8:00 a 14:00"
  }
}
```

Reglas:
- requiere JWT
- role `seller`
- resuelve seller por usuario autenticado

### 2. `PATCH /api/sellers/me/profile`

Actualiza informacion comercial y direccion del seller autenticado.

Uso:
- editar nombre comercial
- editar telefono de contacto
- editar direccion operativa

Request sugerido:

```json
{
  "storeName": "Campo Lindo",
  "contactPhone": "229972474",
  "address": {
    "addressLine1": "Calle 1",
    "addressLine2": "Interior 2",
    "city": "Veracruz",
    "state": "Veracruz",
    "postalCode": "91700",
    "reference": "Frente al mercado"
  }
}
```

Response sugerido:

```json
{
  "message": "Perfil actualizado correctamente",
  "seller": {
    "id": 12,
    "storeName": "Campo Lindo",
    "contactPhone": "229972474",
    "approvalStatus": "approved",
    "address": {
      "addressLine1": "Calle 1",
      "addressLine2": "Interior 2",
      "city": "Veracruz",
      "state": "Veracruz",
      "postalCode": "91700",
      "reference": "Frente al mercado"
    }
  }
}
```

Reglas:
- no permite modificar `approvalStatus`
- no permite modificar `assignedWarehouse`
- no permite modificar `warehouseAssignmentStatus`

### 3. `GET /api/sellers/me/dashboard`

Endpoint agregado para poblar la home seller de forma directa.

Uso:
- home seller mobile
- tarjetas de estado
- indicadores operativos
- CTA habilitados o bloqueados

Response sugerido:

```json
{
  "seller": {
    "storeName": "Campo Lindo",
    "approvalStatus": "approved",
    "productCount": 8
  },
  "warehouse": {
    "assignmentStatus": "pending",
    "name": null,
    "deliveryInstructions": "Nuestro equipo te contactara para indicarte a que almacen entregar"
  },
  "actions": {
    "canCreateProducts": true,
    "canDeliverToWarehouse": false,
    "canEditProfile": true
  }
}
```

Ventaja:
- Flutter no tiene que orquestar `me + products + warehouse`
- deja la home seller mas estable y mas simple de mantener

### 4. `GET /api/sellers/products`

Lista los productos del seller autenticado.

Uso:
- pantalla `Mis productos`
- mostrar conteo real
- renderizar tarjetas y estados

Response sugerido:

```json
{
  "items": [
    {
      "id": 1,
      "name": "Tomate saladette",
      "price": 28,
      "unit": "kg",
      "isActive": true
    },
    {
      "id": 2,
      "name": "Cebolla blanca",
      "price": 19,
      "unit": "kg",
      "isActive": false
    }
  ],
  "meta": {
    "total": 2
  }
}
```

Reglas:
- requiere JWT
- role `seller`
- ownership resuelto por backend

### 5. `GET /api/sellers/warehouse-assignment`

Devuelve el estado logístico actual del seller.

Uso:
- pantalla de estado logístico
- banner en home seller
- CTA de “espera instrucciones”

Response cuando sigue pendiente:

```json
{
  "status": "pending",
  "warehouse": null,
  "message": "Estamos validando el punto de recepcion ideal para tu zona"
}
```

Response cuando ya fue asignado:

```json
{
  "status": "assigned",
  "warehouse": {
    "id": 4,
    "name": "Almacen Norte",
    "address": "Av. Industrial 20, Veracruz"
  },
  "deliveryInstructions": "Entrega de lunes a viernes de 8:00 a 14:00"
}
```

Reglas:
- el seller solo consulta
- no decide el almacen

### 6. `POST /api/sellers/delivery-request`

Permite que el seller notifique que esta listo para comenzar entregas o que necesita seguimiento.

Uso:
- disparar flujo interno para operaciones
- dejar trazabilidad sin exponer admin

Request sugerido:

```json
{
  "notes": "Estoy listo para comenzar entregas"
}
```

Response sugerido:

```json
{
  "message": "Tu solicitud fue enviada al equipo de operaciones",
  "status": "received"
}
```

Reglas:
- no asigna almacen
- solo crea una solicitud operativa

## Endpoints internos para admin u operaciones

### 7. `GET /api/admin/sellers/:id/logistics`

Uso interno para revisar:
- direccion del seller
- estado de aprobacion
- zona operativa
- almacen sugerido o asignado

Response sugerido:

```json
{
  "seller": {
    "id": 12,
    "storeName": "Campo Lindo",
    "approvalStatus": "approved",
    "address": {
      "addressLine1": "Calle 1",
      "addressLine2": "Interior 2",
      "city": "Veracruz",
      "state": "Veracruz",
      "postalCode": "91700",
      "reference": "Frente al mercado"
    }
  },
  "warehouseAssignmentStatus": "pending",
  "suggestedWarehouse": {
    "id": 4,
    "name": "Almacen Norte"
  }
}
```

### 8. `PATCH /api/admin/sellers/:id/assign-warehouse`

Permite que el equipo interno asigne el almacen e instrucciones.

Request sugerido:

```json
{
  "warehouseId": 4,
  "deliveryInstructions": "Presentarte con identificacion y folio de alta"
}
```

Response sugerido:

```json
{
  "message": "Almacen asignado correctamente",
  "assignment": {
    "status": "assigned",
    "warehouse": {
      "id": 4,
      "name": "Almacen Norte"
    },
    "deliveryInstructions": "Presentarte con identificacion y folio de alta"
  }
}
```

Reglas:
- solo admin u operaciones
- no accesible desde app seller

## Permisos recomendados

### Role `seller`

Permitir:
- `GET /api/sellers/me`
- `PATCH /api/sellers/me/profile`
- `GET /api/sellers/me/dashboard`
- `GET /api/sellers/products`
- `POST /api/sellers/products`
- `PATCH /api/sellers/products/:id`
- `PATCH /api/sellers/products/:id/toggle-active`
- `GET /api/sellers/warehouse-assignment`
- `POST /api/sellers/delivery-request`

No permitir:
- CRUD generico de `sellers`
- CRUD generico de `warehouses`
- elegir `warehouseId`
- modificar `approvalStatus`

### Admin / operaciones

Permitir:
- `GET /api/admin/sellers/:id/logistics`
- `PATCH /api/admin/sellers/:id/assign-warehouse`

## Recomendacion para Flutter

Para el frontend mobile seller, la base ideal seria:

- home seller:
  - `GET /api/sellers/me/dashboard`
- pantalla perfil:
  - `GET /api/sellers/me`
  - `PATCH /api/sellers/me/profile`
- pantalla productos:
  - `GET /api/sellers/products`
- pantalla logistica:
  - `GET /api/sellers/warehouse-assignment`

Con eso Flutter evita:
- calcular `productCount`
- reconstruir estado de almacen
- decidir permisos de negocio sensibles

## Decision recomendada

Para este MVP, la frontera correcta es:

- lectura y edicion simple del perfil seller por endpoint custom
- dashboard seller agregado por endpoint custom
- logistica y almacen por endpoint custom
- asignacion de almacen solo en backend interno

Eso deja a `Agrorun` listo para crecer sin exponer reglas operativas delicadas al cliente mobile.
