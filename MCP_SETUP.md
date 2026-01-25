# MCP (Model Context Protocol) Setup for LifeAndGym

This document explains how to use MCP to connect to your Supabase database for development.

## What is MCP?

MCP (Model Context Protocol) allows Claude Code to directly interact with external services like databases, APIs, and tools. In this project, we use it to connect to our Supabase PostgreSQL database.

## Setup Complete ✅

The following has been configured:

1. **Supabase MCP Server installed** (`@supabase/mcp-server-supabase`)
2. **Configuration files created**:
   - `.mcp.json` - MCP server configuration (excluded from git)
   - `.mcp.json.example` - Template for team members
   - `.env.local` - Environment variables (excluded from git)
3. **Claude Code settings updated** to enable the Supabase MCP server

## What You Can Do Now

With MCP connected, you can ask Claude to:

### Database Operations

- **Query data**: "Show me all users in the database"
- **Check schema**: "What tables exist in the database?"
- **View table structure**: "Describe the structure of the workouts table"
- **Insert data**: "Add a new gym with name 'Downtown Fitness'"
- **Update data**: "Update the user with id X to have email Y"
- **Complex queries**: "Show me all active memberships with their gym details"

### Development Tasks

- **Data seeding**: "Seed the database with sample gyms and classes"
- **Schema validation**: "Check if all tables from MASTER_PLAN.md are created"
- **Data migration**: "Help me create a migration to add a new column"
- **Testing data**: "Create test users and memberships for development"

## Available MCP Tools

The Supabase MCP server provides these tools:

1. `supabase_select` - Query data from tables
2. `supabase_insert` - Insert new rows
3. `supabase_update` - Update existing rows
4. `supabase_delete` - Delete rows
5. `supabase_rpc` - Call database functions
6. `supabase_schema` - Get schema information

## Configuration Files

### .mcp.json
Contains the MCP server configuration with your Supabase credentials. **DO NOT commit this file to git** (it's in .gitignore).

### .env.local
Contains environment variables including Supabase credentials. Also excluded from git.

```env
SUPABASE_URL=https://uyqnvvhdeahtcgaglftp.supabase.co
SUPABASE_ANON_KEY=sb_publishable_GF2CA3e-5vtRmMFcXCu6qw_EdCDl9_L
SUPABASE_SERVICE_ROLE_KEY=sbp_9e8bdaf018a302956004945d293a13f750fecac0
```

## For Team Members

If you're setting this up for the first time:

1. Copy `.mcp.json.example` to `.mcp.json`
2. Copy `.env.local` (get credentials from team lead)
3. Install the MCP server: `npm install -g @supabase/mcp-server-supabase`
4. Restart Claude Code

## Security Notes

⚠️ **Important Security Information**:

- `.mcp.json` contains sensitive credentials - NEVER commit it
- `.env.local` contains API keys - NEVER commit it
- Service Role Key has admin access - keep it secret
- Only use Service Role Key on the server/backend
- Use Anon Key for client-side Flutter app

## Next Steps

Now you can use Claude Code to:

1. Verify database schema matches MASTER_PLAN.md
2. Seed test data for development
3. Query and inspect data directly
4. Run database operations without manually writing SQL
5. Validate data integrity

## Troubleshooting

### MCP Server not working?

1. Restart Claude Code to load the MCP server
2. Check if Node.js is installed: `node --version`
3. Verify MCP server is installed: `npm list -g @supabase/mcp-server-supabase`
4. Check `.mcp.json` has correct credentials
5. Look at Claude Code logs for errors

### Need to reinstall?

```bash
npm install -g @supabase/mcp-server-supabase
```

## Example Commands

Try these commands with Claude:

```
"Show me the current database schema"
"List all tables in the database"
"Show me the first 5 gyms"
"How many users are in the database?"
"Show me the structure of the memberships table"
```

---

**Last Updated**: 2026-01-24
**MCP Server Version**: @supabase/mcp-server-supabase@0.6.1
