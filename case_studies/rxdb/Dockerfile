# Use Node.js LTS version
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Create package.json with proper RxDB dependency from npm
RUN echo '{\
  "name": "rxdb-server",\
  "version": "1.0.0",\
  "description": "RxDB Server Application",\
  "main": "server.js",\
  "scripts": {\
    "start": "node server.js",\
    "dev": "node server.js"\
  },\
  "dependencies": {\
    "rxdb": "^15.0.0",\
    "express": "^4.18.2"\
  }\
}' > package.json

# Install dependencies from npm (not local files)
RUN npm install

# Create the server application
RUN echo 'const express = require("express");\
const { createRxDatabase } = require("rxdb");\
const { getRxStorageMemory } = require("rxdb/plugins/storage-memory");\
\
const app = express();\
const PORT = process.env.PORT || 3000;\
\
// Hero schema\
const heroSchema = {\
  version: 0,\
  primaryKey: "name",\
  type: "object",\
  properties: {\
    name: {\
      type: "string",\
      maxLength: 100\
    },\
    color: {\
      type: "string"\
    },\
    power: {\
      type: "string"\
    }\
  },\
  required: ["name"]\
};\
\
let database;\
\
async function createDatabase() {\
  console.log("🗄️  Creating RxDB database...");\
  \
  try {\
    database = await createRxDatabase({\
      name: "heroesdb",\
      storage: getRxStorageMemory()\
    });\
    \
    console.log("✅ Database created successfully");\
    \
    // Add collections\
    await database.addCollections({\
      heroes: {\
        schema: heroSchema\
      }\
    });\
    \
    console.log("✅ Heroes collection added");\
    \
    // Insert sample data\
    const sampleHeroes = [\
      { name: "Superman", color: "blue", power: "flight" },\
      { name: "Batman", color: "black", power: "intelligence" },\
      { name: "Wonder Woman", color: "red", power: "strength" },\
      { name: "Flash", color: "red", power: "speed" },\
      { name: "Green Lantern", color: "green", power: "willpower" }\
    ];\
    \
    for (const hero of sampleHeroes) {\
      try {\
        await database.heroes.insert(hero);\
        console.log(`✅ Inserted hero: ${hero.name}`);\
      } catch (error) {\
        console.log(`⚠️  Hero ${hero.name} already exists or error:`, error.message);\
      }\
    }\
    \
    console.log("🎉 Database setup complete!");\
    return database;\
  } catch (error) {\
    console.error("❌ Error creating database:", error);\
    throw error;\
  }\
}\
\
// Middleware\
app.use(express.json());\
app.use(express.static("public"));\
\
// Routes\
app.get("/", (req, res) => {\
  res.json({\
    message: "🚀 RxDB Server is running!",\
    version: "1.0.0",\
    database: {\
      name: "heroesdb",\
      storage: "in-memory",\
      collections: ["heroes"]\
    },\
    endpoints: {\
      "GET /": "API information",\
      "GET /heroes": "List all heroes",\
      "GET /heroes/:name": "Get hero by name",\
      "POST /heroes": "Create new hero",\
      "PUT /heroes/:name": "Update hero",\
      "DELETE /heroes/:name": "Delete hero",\
      "GET /stats": "Database statistics",\
      "GET /health": "Health check"\
    },\
    example: {\
      "create_hero": {\
        "method": "POST",\
        "url": "/heroes",\
        "body": { "name": "Spiderman", "color": "red", "power": "web-slinging" }\
      }\
    }\
  });\
});\
\
app.get("/heroes", async (req, res) => {\
  try {\
    const heroes = await database.heroes.find().exec();\
    res.json({\
      count: heroes.length,\
      heroes: heroes.map(hero => hero.toJSON())\
    });\
  } catch (error) {\
    res.status(500).json({ error: error.message });\
  }\
});\
\
app.get("/heroes/:name", async (req, res) => {\
  try {\
    const hero = await database.heroes.findOne(req.params.name).exec();\
    if (hero) {\
      res.json(hero.toJSON());\
    } else {\
      res.status(404).json({ error: "Hero not found" });\
    }\
  } catch (error) {\
    res.status(500).json({ error: error.message });\
  }\
});\
\
app.post("/heroes", async (req, res) => {\
  try {\
    const { name, color, power } = req.body;\
    \
    if (!name) {\
      return res.status(400).json({ error: "Name is required" });\
    }\
    \
    const heroData = {\
      name,\
      color: color || "unknown",\
      power: power || "unknown"\
    };\
    \
    const hero = await database.heroes.insert(heroData);\
    res.status(201).json({\
      message: "Hero created successfully",\
      hero: hero.toJSON()\
    });\
  } catch (error) {\
    if (error.code === "RXDB_CONFLICT") {\
      res.status(409).json({ error: "Hero with this name already exists" });\
    } else {\
      res.status(400).json({ error: error.message });\
    }\
  }\
});\
\
app.put("/heroes/:name", async (req, res) => {\
  try {\
    const hero = await database.heroes.findOne(req.params.name).exec();\
    if (!hero) {\
      return res.status(404).json({ error: "Hero not found" });\
    }\
    \
    const { color, power } = req.body;\
    const updatedData = {};\
    if (color !== undefined) updatedData.color = color;\
    if (power !== undefined) updatedData.power = power;\
    \
    await hero.update({ $set: updatedData });\
    res.json({\
      message: "Hero updated successfully",\
      hero: hero.toJSON()\
    });\
  } catch (error) {\
    res.status(400).json({ error: error.message });\
  }\
});\
\
app.delete("/heroes/:name", async (req, res) => {\
  try {\
    const hero = await database.heroes.findOne(req.params.name).exec();\
    if (!hero) {\
      return res.status(404).json({ error: "Hero not found" });\
    }\
    \
    await hero.remove();\
    res.json({ message: "Hero deleted successfully" });\
  } catch (error) {\
    res.status(500).json({ error: error.message });\
  }\
});\
\
app.get("/stats", async (req, res) => {\
  try {\
    const heroCount = await database.heroes.count().exec();\
    const heroes = await database.heroes.find().exec();\
    const colors = {};\
    const powers = {};\
    \
    heroes.forEach(hero => {\
      const data = hero.toJSON();\
      colors[data.color] = (colors[data.color] || 0) + 1;\
      powers[data.power] = (powers[data.power] || 0) + 1;\
    });\
    \
    res.json({\
      database: "heroesdb",\
      collections: {\
        heroes: {\
          count: heroCount,\
          colorDistribution: colors,\
          powerDistribution: powers\
        }\
      },\
      timestamp: new Date().toISOString()\
    });\
  } catch (error) {\
    res.status(500).json({ error: error.message });\
  }\
});\
\
app.get("/health", (req, res) => {\
  res.json({\
    status: "healthy",\
    uptime: process.uptime(),\
    timestamp: new Date().toISOString(),\
    database: database ? "connected" : "disconnected"\
  });\
});\
\
async function startServer() {\
  try {\
    console.log("🚀 Starting RxDB Server...");\
    \
    // Initialize database\
    await createDatabase();\
    \
    // Start HTTP server\
    app.listen(PORT, "0.0.0.0", () => {\
      console.log(`\\n🌐 RxDB Server running on http://localhost:${PORT}`);\
      console.log("\\n📋 Available endpoints:");\
      console.log("   GET  /           - API information");\
      console.log("   GET  /heroes     - List all heroes");\
      console.log("   POST /heroes     - Create new hero");\
      console.log("   GET  /heroes/:name - Get specific hero");\
      console.log("   PUT  /heroes/:name - Update hero");\
      console.log("   DELETE /heroes/:name - Delete hero");\
      console.log("   GET  /stats      - Database statistics");\
      console.log("   GET  /health     - Health check");\
      console.log("\\n🎯 Try: curl http://localhost:3000/heroes");\
      console.log("\\n✨ Ready to serve requests!");\
    });\
  } catch (error) {\
    console.error("❌ Failed to start server:", error);\
    process.exit(1);\
  }\
}\
\
// Handle graceful shutdown\
process.on("SIGTERM", async () => {\
  console.log("\\n🛑 Shutting down gracefully...");\
  if (database) {\
    await database.destroy();\
  }\
  process.exit(0);\
});\
\
process.on("SIGINT", async () => {\
  console.log("\\n🛑 Shutting down gracefully...");\
  if (database) {\
    await database.destroy();\
  }\
  process.exit(0);\
});\
\
startServer();' > server.js

# Expose port
EXPOSE 3000

# Start the server
CMD ["npm", "start"]