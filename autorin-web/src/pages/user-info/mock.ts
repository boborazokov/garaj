import type { Part, UserRow } from "./types";

const MOCK_USERS: Record<
  string,
  UserRow & { region?: string; rating?: string }
> = {
  "mock-user-aziz": {
    _id: "mock-user-aziz",
    name: "Aziz Motors",
    phone: "+998901112233",
    role: "USER",
    verified: true,
    createdAt: "2025-03-12T10:00:00.000Z",
    region: "Toshkent",
    rating: "4.8 / 5.0",
  },
  "mock-user-dilnoza": {
    _id: "mock-user-dilnoza",
    name: "Dilnoza Spare Parts",
    phone: "+998907774455",
    role: "USER",
    verified: false,
    createdAt: "2025-06-01T10:00:00.000Z",
    region: "Samarqand",
    rating: "4.5 / 5.0",
  },
  "mock-user-sarvar": {
    _id: "mock-user-sarvar",
    name: "Sarvar Auto",
    phone: "+998935551122",
    role: "USER",
    verified: true,
    createdAt: "2024-11-20T10:00:00.000Z",
    region: "Andijon",
    rating: "4.9 / 5.0",
  },
  "mock-user-jamshid": {
    _id: "mock-user-jamshid",
    name: "Jamshid Oil & Filters",
    phone: "+998941234567",
    role: "USER",
    verified: false,
    createdAt: "2025-01-08T10:00:00.000Z",
    region: "Buxoro",
    rating: "4.2 / 5.0",
  },
  "mock-user-nodira": {
    _id: "mock-user-nodira",
    name: "Nodira Car Care",
    phone: "+998998887766",
    role: "USER",
    verified: false,
    createdAt: "2025-08-14T10:00:00.000Z",
    region: "Namangan",
    rating: "4.6 / 5.0",
  },
};

function part(
  id: string,
  sellerId: string,
  name: string,
  price: number,
  status: Part["status"],
  views: number,
  categoryUz: string,
): Part {
  return {
    _id: id,
    name,
    description: "",
    price,
    currency: "UZS",
    quantity: 1,
    viewsCount: views,
    status,
    images: [],
    createdAt: new Date(Date.now() - views * 36_000_000).toISOString(),
    category: {
      _id: `cat-${id}`,
      name: categoryUz,
      names: { uz: categoryUz, ru: categoryUz, en: categoryUz },
    },
    seller: {
      _id: sellerId,
      name: MOCK_USERS[sellerId]?.name ?? "Seller",
      phone: MOCK_USERS[sellerId]?.phone ?? "",
    },
  };
}

const MOCK_PRODUCTS: Record<string, Part[]> = {
  "mock-user-aziz": [
    part("mock-part-aziz-1", "mock-user-aziz", "Toyota Camry 2018 old farasi (LED)", 1_850_000, "ACTIVE", 342, "Yoritish"),
    part("mock-part-aziz-2", "mock-user-aziz", "Cobalt tormoz kolodkalari Bosch", 420_000, "ACTIVE", 198, "Tormoz tizimi"),
    part("mock-part-aziz-3", "mock-user-aziz", "Spark 2015 radiator", 780_000, "PENDING_MODERATION", 54, "Sovutish"),
    part("mock-part-aziz-4", "mock-user-aziz", "Nexia 3 orqa bamper", 1_100_000, "ARCHIVED", 89, "Kuzov"),
  ],
  "mock-user-dilnoza": [
    part("mock-part-dil-1", "mock-user-dilnoza", "Lacetti moy filtri", 65_000, "ACTIVE", 120, "Filtrlar"),
    part("mock-part-dil-2", "mock-user-dilnoza", "Malibu 2 havo filtri", 95_000, "ACTIVE", 76, "Filtrlar"),
  ],
  "mock-user-sarvar": [
    part("mock-part-sar-1", "mock-user-sarvar", "Gentra generatori", 2_400_000, "ACTIVE", 210, "Elektr"),
    part("mock-part-sar-2", "mock-user-sarvar", "Damas starter", 980_000, "ACTIVE", 133, "Elektr"),
    part("mock-part-sar-3", "mock-user-sarvar", "Matiz amortizator (juft)", 560_000, "REJECTED", 41, "Podveska"),
  ],
  "mock-user-jamshid": [
    part("mock-part-jam-1", "mock-user-jamshid", "Shell Helix 5W-40 4L", 310_000, "ACTIVE", 450, "Moylar"),
    part("mock-part-jam-2", "mock-user-jamshid", "Mann yog‘ filtri W 712/75", 85_000, "ACTIVE", 260, "Filtrlar"),
  ],
  "mock-user-nodira": [
    part("mock-part-nod-1", "mock-user-nodira", "Salon gilami universal", 180_000, "ACTIVE", 67, "Aksessuarlar"),
  ],
};

export function isMockUserId(userId: string): boolean {
  return userId.startsWith("mock-user-");
}

export function getMockUser(userId: string) {
  return MOCK_USERS[userId] ?? null;
}

export function getMockProducts(userId: string): Part[] {
  return MOCK_PRODUCTS[userId] ?? [];
}

export function getMockRating(userId: string): string {
  return MOCK_USERS[userId]?.rating ?? "—";
}
