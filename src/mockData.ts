export interface Listing {
  id: string;
  title: string;
  description: string;
  price: number;
  currency: string;
  category: string;
  subcategory?: string;
  location: string;
  phone: string;
  date: string;
  image: string; // Will hold category or custom illustration representation
  views: number;
  sellerName: string;
  sellerType: 'Individual' | 'Company';
  status: 'active' | 'expired';
}

export interface Category {
  id: string;
  name: string;
  uzName: string;
  icon: string;
  subcategories?: { id: string; name: string; uzName: string }[];
}

export const CATEGORIES: Category[] = [
  {
    id: 'real-estate',
    name: 'Real Estate',
    uzName: 'Uy-joy sotuvi',
    icon: 'home',
    subcategories: [
      { id: 'apartments', name: 'Apartments', uzName: 'Kvartiralar' },
      { id: 'houses', name: 'Houses & Villas', uzName: 'Hovli va Dacha' },
      { id: 'land', name: 'Land Plots', uzName: 'Er uchastkalari' }
    ]
  },
  {
    id: 'electronics',
    name: 'Electronics & Tech',
    uzName: 'Elektronika va Texnika',
    icon: 'laptop',
    subcategories: [
      { id: 'smartphones', name: 'Smartphones', uzName: 'Telefonlar' },
      { id: 'laptops', name: 'Laptops & Computers', uzName: 'Noutbuklar' },
      { id: 'accessories', name: 'Accessories', uzName: 'Aksessuarlar' }
    ]
  },
  {
    id: 'commercial-farming',
    name: 'Commercial Farming',
    uzName: 'Firma Xo\'jaligi',
    icon: 'tractor',
    subcategories: [
      { id: 'machinery', name: 'Heavy Machinery', uzName: 'Og\'ir Texnika' },
      { id: 'irrigation', name: 'Irrigation Systems', uzName: 'Sug\'orish Tizimlari' },
      { id: 'wholesale-goods', name: 'Wholesale Goods', uzName: 'Ulgurji Mahsulotlar' }
    ]
  },
  {
    id: 'local-farming',
    name: 'Local Farming & Livestock',
    uzName: 'Dehqon Xo\'jaligi',
    icon: 'sprout',
    subcategories: [
      { id: 'grains', name: 'Grains & Crops', uzName: 'Don mahsulotlari' },
      { id: 'livestock', name: 'Livestock', uzName: 'Mol, qo\'y, quyon' },
      { id: 'poultry', name: 'Poultry & Produce', uzName: 'Tovuq, tuxum, parrandalar' }
    ]
  }
];

export const INITIAL_LISTINGS: Listing[] = [
  {
    id: '1',
    title: 'Modern 3-room Apartment in Tashkent City',
    description: 'High-end fully furnished apartment located in the prestigious Tashkent City complex. 4th floor, 88 sqm. Smart home features, underground parking, and 24/7 security included. Great investment opportunity.',
    price: 125000,
    currency: 'USD',
    category: 'real-estate',
    subcategory: 'apartments',
    location: 'Tashkent City, Tashkent',
    phone: '+998 90 123 45 67',
    date: 'Bugun, 14:20',
    image: 'apartment',
    views: 142,
    sellerName: 'Tashkent Real Estate LLC',
    sellerType: 'Company',
    status: 'active'
  },
  {
    id: '2',
    title: 'DJI Agras T40 Agriculture Spraying Drone',
    description: 'Brand new DJI Agras T40 agricultural drone for precision pesticide spraying and fertilizer spreading. Tank capacity 40L, payload capacity 50kg. Equipped with radar and smart avoidance system. Covers up to 21 hectares per hour.',
    price: 16200,
    currency: 'USD',
    category: 'electronics',
    subcategory: 'accessories',
    location: 'Yunusobod, Tashkent',
    phone: '+998 94 987 65 43',
    date: 'Bugun, 09:15',
    image: 'drone',
    views: 389,
    sellerName: 'Smart Agrotech Tashkent',
    sellerType: 'Company',
    status: 'active'
  },
  {
    id: '3',
    title: 'John Deere 6140M Tractor (2022)',
    description: 'Excellent condition tractor, only 1,200 operating hours. 140 horsepower. Serviced regularly by official dealer. Ideal for medium to large scale plowing, harvesting, and sowing operations. Includes dual rear wheels.',
    price: 78000,
    currency: 'USD',
    category: 'commercial-farming',
    subcategory: 'machinery',
    location: 'Jizzakh Region',
    phone: '+998 93 456 78 90',
    date: 'Kecha, 18:30',
    image: 'tractor',
    views: 520,
    sellerName: 'Jizzax Agro Cluster',
    sellerType: 'Company',
    status: 'active'
  },
  {
    id: '4',
    title: 'Pedigree Holstein Dairy Cow',
    description: 'Highly productive Holstein dairy cow, currently in 2nd lactation. Produces 28-32 liters of milk daily. Vaccinated, healthy, and certified by regional veterinary service. Price is slightly negotiable.',
    price: 1800,
    currency: 'USD',
    category: 'local-farming',
    subcategory: 'livestock',
    location: 'Samarkand District, Samarkand',
    phone: '+998 97 111 22 33',
    date: 'Kecha, 11:05',
    image: 'cow',
    views: 245,
    sellerName: 'Sherzod Aka',
    sellerType: 'Individual',
    status: 'active'
  },
  {
    id: '5',
    title: 'Premium Rice "Alanga" (Wholesale, 1.5 Tons)',
    description: 'Freshly harvested Alanga rice from Khorezm region. Cleaned, double polished, premium grade. Perfect for restaurants and retail packaging. Minimum order 500kg. Wholesale discount applies.',
    price: 1200, // per ton or total
    currency: 'USD',
    category: 'local-farming',
    subcategory: 'grains',
    location: 'Gurlan, Khorezm',
    phone: '+998 99 888 77 66',
    date: '15-Iyun, 16:45',
    image: 'rice',
    views: 112,
    sellerName: 'Xorazm Don Agro',
    sellerType: 'Individual',
    status: 'active'
  },
  {
    id: '6',
    title: 'MacBook Pro 16" M3 Max (36GB RAM / 1TB SSD)',
    description: 'Perfect condition, Space Black color. battery cycle count: 28, health 99%. Used for iOS development for 3 months only. Complete box with 140W fast charger. Global warranty active.',
    price: 2650,
    currency: 'USD',
    category: 'electronics',
    subcategory: 'laptops',
    location: 'Mirzo Ulugbek, Tashkent',
    phone: '+998 90 777 55 44',
    date: '14-Iyun, 10:00',
    image: 'macbook',
    views: 405,
    sellerName: 'Jahongir',
    sellerType: 'Individual',
    status: 'active'
  },
  {
    id: '7',
    title: 'Incubator Chicks (Lohmann Brown) - 500 pcs',
    description: '1-day old healthy Lohmann Brown egg-laying breed chicks. Vaccinated against Marek\'s and Gumboro disease. Excellent survival rate (98%+). Ideal for starting a local egg farm.',
    price: 450,
    currency: 'USD',
    category: 'local-farming',
    subcategory: 'poultry',
    location: 'Quva, Fergana',
    phone: '+998 91 654 32 10',
    date: '13-Iyun, 08:30',
    image: 'poultry',
    views: 187,
    sellerName: 'Farg\'ona Parranda',
    sellerType: 'Company',
    status: 'active'
  },
  {
    id: '8',
    title: 'Large-scale Drip Irrigation System (10 Hectares)',
    description: 'Complete professional drip irrigation package. Includes high-capacity water filters, electric water pumps (15kW), main distribution pipes, drip lines (compensating, 1.6L/h flow rate), and valves. Setup assistance available.',
    price: 11500,
    currency: 'USD',
    category: 'commercial-farming',
    subcategory: 'irrigation',
    location: 'Namangan District, Namangan',
    phone: '+998 95 333 44 55',
    date: '12-Iyun, 15:10',
    image: 'irrigation',
    views: 312,
    sellerName: 'Vodiiy Agrotex Xizmat',
    sellerType: 'Company',
    status: 'active'
  },
  {
    id: '9',
    title: 'Hisor Breed Breeding Sheep (Male, 95kg)',
    description: 'Purebred Hisor sheep (Hisori qo\'chqor). 1.5 years old, weight 95kg. Excellent genetics for herd breeding. Healthy, active, fed with natural pasture and grain mix. Perfect for local shepherds.',
    price: 380,
    currency: 'USD',
    category: 'local-farming',
    subcategory: 'livestock',
    location: 'Parkent, Tashkent Region',
    phone: '+998 98 444 55 66',
    date: '12-Iyun, 11:20',
    image: 'sheep',
    views: 298,
    sellerName: 'Zokirjon Aka',
    sellerType: 'Individual',
    status: 'active'
  }
];
