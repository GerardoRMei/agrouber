import '../models/product.dart';
import '../models/seller.dart';

final List<Seller> mockSellers = [
  Seller(
    name: 'Rancho Los Álamos',
    address: 'Carretera Federal Km 12, Ejido San Pedro',
    description: 'Productores de hortalizas orgánicas con más de 20 años de experiencia.',
    email: 'contacto@alamos.com',
    phone: '4491234567',
    socialMedia: const SocialMedia(
      facebook: 'facebook.com/rancholosalamos',
      instagram: '@rancho_alamos',
    ),
    products: [
      const Product(name: 'Saladette Tomato', producer: 'Rancho Los Álamos', price: '\$18', unit: '/kg', image: '🍅', tag: 'Today', category: 'Veggies'),
      const Product(name: 'Organic Carrots', producer: 'Rancho Los Álamos', price: '\$15', unit: '/kg', image: '🥕', tag: 'Today', category: 'Veggies'),
      const Product(name: 'White Onion', producer: 'Rancho Los Álamos', price: '\$12', unit: '/kg', image: '🧅', tag: 'Fresh', category: 'Veggies'),
    ],
  ),
  Seller(
    name: 'Finca Morales',
    address: 'Calle Juárez #45, Centro',
    description: 'Especialistas en frutos tropicales y cítricos.',
    email: 'info@fincamorales.mx',
    phone: '4497654321',
    socialMedia: const SocialMedia(
      instagram: '@fincamorales_fresh',
      tiktok: '@fincamorales',
    ),
    products: [
      const Product(name: 'Saladette Tomato', producer: 'Finca Morales', price: '\$25', unit: '/kg', image: '🍅', tag: 'Fresh', category: 'Veggies'),
      const Product(name: 'Banana', producer: 'Finca Morales', price: '\$20', unit: '/kg', image: '🍌', tag: 'Fresh', category: 'Fruits'),
      const Product(name: 'Mango', producer: 'Finca Morales', price: '\$35', unit: '/kg', image: '🥭', tag: '2 days', category: 'Fruits'),
    ],
  ),
  Seller(
    name: 'Granja Verde',
    address: 'Valle de las Huertas #10',
    description: 'Dedicados al cultivo sustentable de vegetales de hoja verde.',
    email: 'ventas@granjaverde.com',
    phone: '4490001122',
    socialMedia: const SocialMedia(facebook: 'facebook.com/granjaverde'),
    products: [
      const Product(name: 'Broccoli', producer: 'Granja Verde', price: '\$22', unit: '/unit', image: '🥦', tag: 'Today', category: 'Veggies'),
      const Product(name: 'Organic Carrots', producer: 'Granja Verde', price: '\$20', unit: '/kg', image: '🥕', tag: 'Today', category: 'Veggies'),
      const Product(name: 'Lettuce', producer: 'Granja Verde', price: '\$15', unit: '/unit', image: '🥬', tag: 'Today', category: 'Veggies'),
    ],
  ),
  Seller(
    name: 'Huertas de la Montaña',
    address: 'Camino al Nevado Km 5',
    description: 'Frutos de clima frío, cultivados a más de 2000 metros de altura.',
    email: 'hola@huertasmontana.com',
    phone: '5559998877',
    socialMedia: const SocialMedia(
      instagram: '@huertas_montana',
    ),
    products: [
      const Product(name: 'Apple', producer: 'Huertas de la Montaña', price: '\$30', unit: '/kg', image: '🍎', tag: 'Fresh', category: 'Fruits'),
      const Product(name: 'Pear', producer: 'Huertas de la Montaña', price: '\$28', unit: '/kg', image: '🍐', tag: 'Fresh', category: 'Fruits'),
      const Product(name: 'Strawberry', producer: 'Huertas de la Montaña', price: '\$45', unit: '/box', image: '🍓', tag: 'Today', category: 'Fruits'),
    ],
  ),
  Seller(
    name: 'Lácteos El Prado',
    address: 'Ex-hacienda El Prado s/n',
    description: 'Productos lácteos frescos de vacas de libre pastoreo.',
    email: 'pedidos@lacteoselprado.com',
    phone: '4423334455',
    socialMedia: const SocialMedia(
      facebook: 'facebook.com/lacteoselprado',
      tiktok: '@elprado_mx',
    ),
    products: [
      const Product(name: 'Fresh Milk', producer: 'Lácteos El Prado', price: '\$22', unit: '/L', image: '🥛', tag: 'Today', category: 'Dairy'),
      const Product(name: 'Artisan Cheese', producer: 'Lácteos El Prado', price: '\$120', unit: '/kg', image: '🧀', tag: 'Fresh', category: 'Dairy'),
    ],
  ),
  Seller(
    name: 'Carnes San Juan',
    address: 'Av. Revolución #300',
    description: 'Cortes de primera calidad, pollo y cerdo de granjas locales.',
    email: 'contacto@carnessanjuan.com',
    phone: '8112223344',
    socialMedia: const SocialMedia(
      facebook: 'facebook.com/sanjuan.carnes',
      instagram: '@carnes_sanjuan',
    ),
    products: [
      const Product(name: 'Chicken Breast', producer: 'Carnes San Juan', price: '\$85', unit: '/kg', image: '🍗', tag: 'Fresh', category: 'Protein'),
      const Product(name: 'Beef Cut', producer: 'Carnes San Juan', price: '\$180', unit: '/kg', image: '🥩', tag: 'Today', category: 'Protein'),
    ],
  ),
  Seller(
    name: 'Granos del Valle',
    address: 'Zona Industrial Agrícola Lote 4',
    description: 'Venta de granos y semillas a granel directo del campo.',
    email: 'ventas@granosdelvalle.com',
    phone: '3334445566',
    socialMedia: const SocialMedia(),
    products: [
      const Product(name: 'Corn', producer: 'Granos del Valle', price: '\$12', unit: '/kg', image: '🌽', tag: 'Dry', category: 'Grains'),
      const Product(name: 'White Rice', producer: 'Granos del Valle', price: '\$25', unit: '/kg', image: '🍚', tag: 'Dry', category: 'Grains'),
    ],
  ),
  Seller(
    name: 'El Huerto Familiar',
    address: 'Callejón de las Flores #2',
    description: 'Pequeña cooperativa familiar cultivando lo mejor de la temporada.',
    email: 'coop@huertofamiliar.org',
    phone: '4495556677',
    socialMedia: const SocialMedia(
      instagram: '@huertofamiliar.ags',
    ),
    products: [
      const Product(name: 'Saladette Tomato', producer: 'El Huerto Familiar', price: '\$21', unit: '/kg', image: '🍅', tag: 'Today', category: 'Veggies'),
      const Product(name: 'Broccoli', producer: 'El Huerto Familiar', price: '\$18', unit: '/unit', image: '🥦', tag: 'Fresh', category: 'Veggies'),
      const Product(name: 'Banana', producer: 'El Huerto Familiar', price: '\$18', unit: '/kg', image: '🍌', tag: '2 days', category: 'Fruits'),
      const Product(name: 'Apple', producer: 'El Huerto Familiar', price: '\$35', unit: '/kg', image: '🍎', tag: 'Today', category: 'Fruits'),
    ],
  ),
];