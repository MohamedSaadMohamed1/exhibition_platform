// Candoo Firestore Data Seeder
// Run: node seed_firestore.js

const { initializeApp } = require("firebase/app");
const {
  getFirestore,
  doc,
  setDoc,
  collection,
  addDoc,
  Timestamp,
} = require("firebase/firestore");
const { randomUUID } = require("crypto");

// Firebase config - same as firebase_options.dart
const firebaseConfig = {
  apiKey: "AIzaSyAILsHeQfeZwPJ228_g7rT6XL1FtKWRgD4",
  authDomain: "candoo-7ddfc.firebaseapp.com",
  projectId: "candoo-7ddfc",
  storageBucket: "candoo-7ddfc.firebasestorage.app",
  messagingSenderId: "810206757302",
  appId: "1:810206757302:web:5a93ed31565751e47b4117",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const now = Timestamp.now();
const futureDate = (days) =>
  Timestamp.fromDate(new Date(Date.now() + days * 86400000));
const pastDate = (days) =>
  Timestamp.fromDate(new Date(Date.now() - days * 86400000));

async function seedDatabase() {
  console.log("🚀 Starting database seeding...\n");

  // ===========================================================
  // 1. USERS
  // ===========================================================
  console.log("👤 Seeding users...");

  const adminId = randomUUID();
  const organizerId = randomUUID();
  const exhibitorId = randomUUID();
  const visitor1Id = randomUUID();
  const supplier1UserId = randomUUID();

  const users = [
    {
      id: adminId,
      name: "Ahmed Admin",
      phone: "+201001234567",
      role: "admin",
      email: "admin@candoo.app",
      isActive: true,
      createdBy: "system",
      createdAt: now,
      updatedAt: now,
    },
    {
      id: organizerId,
      name: "Sara Organizer",
      phone: "+201112345678",
      role: "organizer",
      email: "sara@events.com",
      isActive: true,
      createdBy: adminId,
      createdAt: now,
      updatedAt: now,
    },
    {
      id: exhibitorId,
      name: "Cairo Tech LLC",
      phone: "+201223456789",
      role: "exhibitor",
      email: "info@cairotech.com",
      isActive: true,
      createdBy: adminId,
      createdAt: now,
      updatedAt: now,
    },
    {
      id: visitor1Id,
      name: "Mostafa Visitor",
      phone: "+201334567890",
      role: "visitor",
      email: "mostafa@gmail.com",
      isActive: true,
      createdBy: "system",
      createdAt: now,
      updatedAt: now,
    },
    {
      id: supplier1UserId,
      name: "Nour Supplier",
      phone: "+201445678901",
      role: "supplier",
      email: "nour@alphadecore.com",
      isActive: true,
      createdBy: adminId,
      createdAt: now,
      updatedAt: now,
    },
  ];

  for (const user of users) {
    const { id, ...data } = user;
    await setDoc(doc(db, "users", id), data);
    console.log(`  ✅ User added: ${user.name} [${user.role}]`);
  }

  // ===========================================================
  // 2. EVENTS
  // ===========================================================
  console.log("\n📅 Seeding events...");

  const event1Id = randomUUID();
  const event2Id = randomUUID();
  const event3Id = randomUUID();

  const events = [
    {
      id: event1Id,
      title: "TechX Egypt 2026",
      description:
        "The largest technology exhibition in Egypt featuring AI, robotics, Web3 startups, and smart city innovations.",
      location: "Cairo International Convention Centre, Nasr City",
      address: "El-Nasr Rd, Al Estad, Nasr City, Cairo Governorate",
      startDate: futureDate(20),
      endDate: futureDate(23),
      tags: ["technology", "ai", "startups", "egypt", "robotics"],
      images: [
        "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80",
        "https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80",
      ],
      interestedCount: 856,
      boothCount: 60,
      organizerId: organizerId,
      organizerName: "Sara Organizer",
      status: "published",
      category: "Technology",
      latitude: 30.0674,
      longitude: 31.344,
      createdAt: now,
      updatedAt: now,
    },
    {
      id: event2Id,
      title: "Candoo Global Trade Fair 2026",
      description:
        "A massive international networking event for suppliers, decorators, exhibitors and event planners from 50+ countries.",
      location: "Dubai World Trade Centre, Sheikh Zayed Road",
      address: "Trade Centre - 1 - Dubai - UAE",
      startDate: pastDate(2),
      endDate: futureDate(5),
      tags: ["trade", "exhibition", "business", "international", "networking"],
      images: [
        "https://images.unsplash.com/photo-1551818255-e6e10975bc17?w=800&q=80",
        "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800&q=80",
      ],
      interestedCount: 3200,
      boothCount: 200,
      organizerId: organizerId,
      organizerName: "Sara Organizer",
      status: "published",
      category: "Business",
      latitude: 25.2285,
      longitude: 55.2867,
      createdAt: now,
      updatedAt: now,
    },
    {
      id: event3Id,
      title: "Creative Design Expo 2026",
      description:
        "An immersive expo celebrating graphic design, interior design, fashion, and creative arts across the MENA region.",
      location: "Mall of Egypt, 6th of October City",
      startDate: futureDate(45),
      endDate: futureDate(47),
      tags: ["design", "art", "fashion", "creative", "mena"],
      images: [
        "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80",
      ],
      interestedCount: 430,
      boothCount: 35,
      organizerId: organizerId,
      organizerName: "Sara Organizer",
      status: "published",
      category: "Design & Arts",
      createdAt: now,
      updatedAt: now,
    },
  ];

  for (const event of events) {
    const { id, ...data } = event;
    await setDoc(doc(db, "events", id), data);
    console.log(`  ✅ Event added: ${event.title}`);
  }

  // ===========================================================
  // 3. SUPPLIERS
  // ===========================================================
  console.log("\n🏪 Seeding suppliers...");

  const supplier1Id = randomUUID();
  const supplier2Id = randomUUID();
  const supplier3Id = randomUUID();

  const suppliers = [
    {
      id: supplier1Id,
      name: "Alpha Decorations",
      description:
        "Premium booth and event decorators specializing in corporate exhibitions, product launches, and trade fairs.",
      services: ["Decoration", "Furniture"],
      category: "Decoration",
      images: [
        "https://images.unsplash.com/photo-1497366216548-37526070297c?w=800&q=80",
        "https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80",
      ],
      ownerId: supplier1UserId,
      ownerName: "Nour Supplier",
      contactEmail: "contact@alphadecor.com",
      contactPhone: "+201445678901",
      website: "https://alphadecor.com",
      address: "5 Gamal Abd El-Nasser St, Heliopolis, Cairo",
      rating: 4.8,
      reviewCount: 34,
      createdByAdmin: adminId,
      isActive: true,
      isVerified: true,
      createdAt: now,
      updatedAt: now,
    },
    {
      id: supplier2Id,
      name: "TechSound A/V Solutions",
      description:
        "Professional audio-visual equipment rental. Microphones, LED walls, projectors, PA systems for all event sizes.",
      services: ["Audio & Visual"],
      category: "Audio & Visual",
      images: [
        "https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=800&q=80",
      ],
      ownerId: adminId,
      ownerName: "Ahmed Admin",
      contactEmail: "sales@techsound.app",
      contactPhone: "+201556789012",
      rating: 4.5,
      reviewCount: 21,
      createdByAdmin: adminId,
      isActive: true,
      isVerified: true,
      createdAt: now,
      updatedAt: now,
    },
    {
      id: supplier3Id,
      name: "Snap & Capture Photography",
      description:
        "Event photography and videography experts. Covering exhibitions, trade fairs, and corporate functions across Egypt.",
      services: ["Photography"],
      category: "Photography",
      images: [
        "https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800&q=80",
      ],
      ownerId: adminId,
      ownerName: "Ahmed Admin",
      contactEmail: "hello@snapcapture.eg",
      rating: 4.9,
      reviewCount: 58,
      createdByAdmin: adminId,
      isActive: true,
      isVerified: true,
      createdAt: now,
      updatedAt: now,
    },
  ];

  for (const supplier of suppliers) {
    const { id, ...data } = supplier;
    await setDoc(doc(db, "suppliers", id), data);
    console.log(`  ✅ Supplier added: ${supplier.name}`);
  }

  // ===========================================================
  // 4. BOOTHS for Event 1
  // ===========================================================
  console.log("\n🏢 Seeding booths for TechX Egypt 2026...");

  const booths = [
    { number: "A1", size: "large", status: "available", price: 5000, eventId: event1Id },
    { number: "A2", size: "medium", status: "available", price: 3500, eventId: event1Id },
    { number: "A3", size: "small", status: "booked", price: 2000, eventId: event1Id, bookedBy: exhibitorId },
    { number: "B1", size: "premium", status: "available", price: 8000, eventId: event1Id },
    { number: "B2", size: "large", status: "available", price: 5000, eventId: event1Id },
  ];

  for (const booth of booths) {
    const boothId = randomUUID();
    await setDoc(doc(db, "booths", boothId), {
      ...booth,
      createdAt: now,
      updatedAt: now,
    });
    console.log(`  ✅ Booth added: ${booth.number} (${booth.size}) - ${booth.status}`);
  }

  console.log("\n🎉 Database seeded successfully!");
  console.log("📊 Summary:");
  console.log(`  - ${users.length} Users`);
  console.log(`  - ${events.length} Events`);
  console.log(`  - ${suppliers.length} Suppliers`);
  console.log(`  - ${booths.length} Booths`);
  process.exit(0);
}

seedDatabase().catch((e) => {
  console.error("❌ Error seeding database:", e);
  process.exit(1);
});
