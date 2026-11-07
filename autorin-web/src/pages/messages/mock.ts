import type { ChatConversation, ChatMessage, ChatParticipant } from "./types";

export const MOCK_ID_PREFIX = "mock-";

export function isMockConversationId(id: string): boolean {
  return id.startsWith(MOCK_ID_PREFIX);
}

function hoursAgo(hours: number): string {
  return new Date(Date.now() - hours * 3_600_000).toISOString();
}

function minutesAgo(minutes: number): string {
  return new Date(Date.now() - minutes * 60_000).toISOString();
}

function daysAgo(days: number, hour = 14, minute = 20): string {
  const d = new Date();
  d.setDate(d.getDate() - days);
  d.setHours(hour, minute, 0, 0);
  return d.toISOString();
}

function seller(
  id: string,
  name: string,
  phone: string,
  verified = false,
): ChatParticipant {
  return { _id: id, name, phone, verified };
}

function adminParticipant(adminId: string): ChatParticipant {
  return {
    _id: adminId,
    name: "AutoRin Admin",
    phone: "+998900000000",
    verified: true,
  };
}

/** Demo conversations — auto-parts support threads. */
export function buildMockConversations(adminId: string): ChatConversation[] {
  const admin = adminParticipant(adminId);
  const a = seller("mock-user-aziz", "Aziz Motors", "+998901112233", true);
  const b = seller("mock-user-dilnoza", "Dilnoza Spare Parts", "+998907774455");
  const c = seller("mock-user-sarvar", "Sarvar Auto", "+998935551122", true);
  const d = seller("mock-user-jamshid", "Jamshid Oil & Filters", "+998941234567");
  const e = seller("mock-user-nodira", "Nodira Car Care", "+998998887766");

  return [
    {
      _id: `${MOCK_ID_PREFIX}conv-aziz`,
      participants: [admin, a],
      lastMessageText: "Toyota Camry 2018 uchun old faralar bormi?",
      lastMessageSender: a._id,
      lastMessageAt: minutesAgo(12),
      unread: 2,
      createdAt: daysAgo(3),
      updatedAt: minutesAgo(12),
    },
    {
      _id: `${MOCK_ID_PREFIX}conv-dilnoza`,
      participants: [admin, b],
      lastMessageText: "Buyurtma #4821 — yetkazib berish manzilini yangilang.",
      lastMessageSender: adminId,
      lastMessageAt: hoursAgo(2),
      unread: 0,
      createdAt: daysAgo(5),
      updatedAt: hoursAgo(2),
    },
    {
      _id: `${MOCK_ID_PREFIX}conv-sarvar`,
      participants: [admin, c],
      lastMessageText: "Tasdiqlash uchun do‘kon hujjatlarini yubordim.",
      lastMessageSender: c._id,
      lastMessageAt: hoursAgo(5),
      unread: 1,
      createdAt: daysAgo(8),
      updatedAt: hoursAgo(5),
    },
    {
      _id: `${MOCK_ID_PREFIX}conv-jamshid`,
      participants: [admin, d],
      lastMessageText: "[photo]",
      lastMessageSender: d._id,
      lastMessageAt: daysAgo(1, 16, 40),
      unread: 0,
      createdAt: daysAgo(10),
      updatedAt: daysAgo(1, 16, 40),
    },
    {
      _id: `${MOCK_ID_PREFIX}conv-nodira`,
      participants: [admin, e],
      lastMessageText: "Rahmat, muammo hal bo‘ldi!",
      lastMessageSender: e._id,
      lastMessageAt: daysAgo(2, 11, 5),
      unread: 0,
      createdAt: daysAgo(12),
      updatedAt: daysAgo(2, 11, 5),
    },
  ];
}

export function buildMockMessages(
  conversationId: string,
  adminId: string,
): ChatMessage[] {
  const admin = adminParticipant(adminId);

  const threads: Record<string, ChatMessage[]> = {
    [`${MOCK_ID_PREFIX}conv-aziz`]: (() => {
      const peer = seller("mock-user-aziz", "Aziz Motors", "+998901112233", true);
      return [
        {
          _id: "mock-msg-aziz-1",
          text: "Assalomu alaykum! Katalogda Cobalt uchun tormoz kolodkalari ko‘rinmayapti.",
          createdAt: daysAgo(1, 10, 15),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-aziz-2",
          text: "Va alaykum assalom. Qaysi yil modeli kerak?",
          createdAt: daysAgo(1, 10, 22),
          sender: admin,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-aziz-3",
          text: "2019–2021 oralig‘i. OEM yoki Bosch mos keladi.",
          createdAt: daysAgo(1, 10, 28),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-aziz-4",
          text: "Bugun kechqurun 3 ta variant qo‘shamiz. Shu orada https://autorin.uz/products ni tekshirib ko‘ring.",
          createdAt: daysAgo(1, 11, 5),
          sender: admin,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-aziz-5",
          text: "Toyota Camry 2018 uchun old faralar bormi?",
          createdAt: minutesAgo(12),
          sender: peer,
          readBy: [peer._id],
        },
        {
          _id: "mock-msg-aziz-6",
          text: "LED yoki oddiy halogen — qaysi biri kerak?",
          createdAt: minutesAgo(8),
          sender: peer,
          readBy: [peer._id],
        },
      ];
    })(),

    [`${MOCK_ID_PREFIX}conv-dilnoza`]: (() => {
      const peer = seller(
        "mock-user-dilnoza",
        "Dilnoza Spare Parts",
        "+998907774455",
      );
      return [
        {
          _id: "mock-msg-dil-1",
          text: "Buyurtma #4821 mijozga yetib bormadi deb yozgan.",
          createdAt: hoursAgo(5),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-dil-2",
          text: "Tekshirdik — kuryer manzilni noto‘g‘ri olgan. Yangi manzilni yuboring.",
          createdAt: hoursAgo(4),
          sender: admin,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-dil-3",
          text: "Toshkent, Chilonzor 9-mavze, 24-uy.",
          createdAt: hoursAgo(3),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-dil-4",
          text: "Buyurtma #4821 — yetkazib berish manzilini yangilang.",
          createdAt: hoursAgo(2),
          sender: admin,
          readBy: [adminId, peer._id],
        },
      ];
    })(),

    [`${MOCK_ID_PREFIX}conv-sarvar`]: (() => {
      const peer = seller("mock-user-sarvar", "Sarvar Auto", "+998935551122", true);
      return [
        {
          _id: "mock-msg-sar-1",
          text: "Do‘konni tasdiqlash uchun nima kerak?",
          createdAt: daysAgo(2, 9, 0),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-sar-2",
          text: "STIR, do‘kon fotosurati va egasining passporti (yoki ID).",
          createdAt: daysAgo(2, 9, 40),
          sender: admin,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-sar-3",
          text: "Tasdiqlash uchun do‘kon hujjatlarini yubordim.",
          createdAt: hoursAgo(5),
          sender: peer,
          readBy: [peer._id],
        },
      ];
    })(),

    [`${MOCK_ID_PREFIX}conv-jamshid`]: (() => {
      const peer = seller(
        "mock-user-jamshid",
        "Jamshid Oil & Filters",
        "+998941234567",
      );
      return [
        {
          _id: "mock-msg-jam-1",
          text: "Mahsulot kartochkasidagi rasm sifatini tekshirib bering.",
          createdAt: daysAgo(1, 15, 10),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-jam-2",
          text: "Yuborgan rasmlaringiz yaxshi. Faqat fonni oqroq qilib qayta yuklang.",
          createdAt: daysAgo(1, 15, 45),
          sender: admin,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-jam-3",
          text: "[photo]",
          images: [],
          createdAt: daysAgo(1, 16, 40),
          sender: peer,
          readBy: [adminId, peer._id],
        },
      ];
    })(),

    [`${MOCK_ID_PREFIX}conv-nodira`]: (() => {
      const peer = seller(
        "mock-user-nodira",
        "Nodira Car Care",
        "+998998887766",
      );
      return [
        {
          _id: "mock-msg-nod-1",
          text: "E’lonim moderatsiyada uzoq turibdi.",
          createdAt: daysAgo(2, 10, 0),
          sender: peer,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-nod-2",
          text: "Ko‘rib chiqdik — narx maydonida xato bor edi. Tuzatdik, e’lon faol.",
          createdAt: daysAgo(2, 10, 35),
          sender: admin,
          readBy: [adminId, peer._id],
        },
        {
          _id: "mock-msg-nod-3",
          text: "Rahmat, muammo hal bo‘ldi!",
          createdAt: daysAgo(2, 11, 5),
          sender: peer,
          readBy: [adminId, peer._id],
        },
      ];
    })(),
  };

  return threads[conversationId] ?? [];
}

export const DEFAULT_MOCK_PINNED = [`${MOCK_ID_PREFIX}conv-aziz`];
