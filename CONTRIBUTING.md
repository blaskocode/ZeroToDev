# Contributing to Zero-to-Running Developer Environment

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Project Structure](#project-structure)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive experience for everyone. We expect all contributors to:

- **Be respectful** of differing viewpoints and experiences
- **Accept constructive criticism** gracefully
- **Focus on what is best** for the community and project
- **Show empathy** towards other community members

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling or personal attacks
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

---

## Getting Started

### Fork and Clone

1. **Fork the repository** on GitHub
2. **Clone your fork locally:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ZeroToDev.git
   cd ZeroToDev
   ```

3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/ZeroToDev.git
   ```

### Setup Development Environment

```bash
# Copy environment variables
cp .env.example .env

# Validate prerequisites
./scripts/validate-prereqs.sh

# Start development environment
make dev
```

Verify everything works:
- Frontend: http://localhost:5173
- API: http://localhost:4000/health

---

## Development Workflow

### Branch Naming

Use descriptive branch names following this pattern:

```
<type>/<short-description>
```

**Types:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Test additions or changes
- `chore/` - Maintenance tasks

**Examples:**
```bash
git checkout -b feature/add-user-authentication
git checkout -b fix/health-check-timeout
git checkout -b docs/update-aws-guide
git checkout -b refactor/extract-database-utils
```

### Making Changes

1. **Create a new branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our [coding standards](#coding-standards)

3. **Test your changes:**
   ```bash
   # Run the full stack
   make dev
   
   # Test manually
   # - Check http://localhost:5173
   # - Check http://localhost:4000/health
   # - Verify hot reload works
   
   # View logs
   make logs
   ```

4. **Commit your changes** following our [commit guidelines](#commit-guidelines)

5. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a pull request** on GitHub

### Stay Up to Date

Regularly sync with the upstream repository:

```bash
# Fetch latest changes
git fetch upstream

# Merge into your branch
git checkout main
git merge upstream/main

# Update your branch
git checkout feature/your-feature-name
git rebase main
```

---

## Coding Standards

### General Principles

- **Keep it simple**: Favor clarity over cleverness
- **DRY (Don't Repeat Yourself)**: Extract common logic
- **SOLID principles**: Follow object-oriented design principles
- **Error handling**: Always handle errors gracefully
- **Comments**: Explain "why", not "what"

### TypeScript/JavaScript

**Style:**
- Use **TypeScript** for all new code
- **2 spaces** for indentation
- **Semicolons** required
- **Single quotes** for strings
- **Trailing commas** in objects and arrays

**Example:**
```typescript
// ✅ Good
interface User {
  id: string;
  name: string;
  email: string;
}

export const getUser = async (id: string): Promise<User> => {
  try {
    const user = await database.findById(id);
    return user;
  } catch (error) {
    logger.error('Failed to fetch user', { id, error });
    throw new Error('User not found');
  }
};

// ❌ Bad
const getUser = (id) => {
    return database.findById(id)
}
```

**Naming Conventions:**
```typescript
// Variables and functions: camelCase
const userName = 'John';
const getUserData = () => {};

// Classes and interfaces: PascalCase
class UserService {}
interface UserData {}

// Constants: UPPER_SNAKE_CASE
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'http://api.example.com';

// Files: kebab-case
user-service.ts
health-check.routes.ts
```

### React Components

**Functional components with hooks:**
```typescript
// ✅ Good
interface ServiceCardProps {
  title: string;
  status: 'healthy' | 'unhealthy';
  onRefresh: () => void;
}

export const ServiceCard: React.FC<ServiceCardProps> = ({ title, status, onRefresh }) => {
  const [isLoading, setIsLoading] = React.useState(false);
  
  const handleRefresh = async () => {
    setIsLoading(true);
    try {
      await onRefresh();
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <div className="service-card">
      <h3>{title}</h3>
      <StatusIndicator status={status} />
      <button onClick={handleRefresh} disabled={isLoading}>
        Refresh
      </button>
    </div>
  );
};
```

**Component structure:**
1. Imports
2. Type definitions
3. Component definition
4. Export

### CSS/Tailwind

- Use **Tailwind utility classes** first
- Extract common patterns into components
- Keep custom CSS minimal
- Use semantic class names for custom CSS

```tsx
// ✅ Good
<div className="flex items-center justify-between p-4 bg-white dark:bg-gray-800 rounded-lg shadow">
  <h2 className="text-xl font-bold">Title</h2>
</div>

// ❌ Bad (inline styles)
<div style={{ display: 'flex', padding: '16px' }}>
  <h2 style={{ fontSize: '20px' }}>Title</h2>
</div>
```

### File Organization

**Keep files under 750 lines** (project rule):
- If a file exceeds 750 lines, split it into multiple files
- Extract utilities into separate files
- Group related functionality

**Example structure:**
```
api/src/
  routes/
    user.routes.ts          # Route definitions
    user.controller.ts      # Request handlers
    user.service.ts         # Business logic
    user.validation.ts      # Input validation
    user.types.ts           # Type definitions
```

---

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type** (required):
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic changes)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements

**Scope** (optional): Component affected (api, frontend, infra, docs)

**Subject** (required): Short description (50 chars max)
- Use imperative mood ("add" not "added")
- Don't capitalize first letter
- No period at the end

**Body** (optional): Detailed explanation
- Wrap at 72 characters
- Explain "what" and "why", not "how"

**Footer** (optional): Breaking changes, issue references

### Examples

**Simple commit:**
```
feat(api): add user authentication endpoint
```

**Detailed commit:**
```
fix(frontend): correct health check polling interval

The health check was polling every second instead of every 5 seconds,
causing unnecessary load on the API. Updated the interval constant
and added a comment explaining the choice.

Fixes #42
```

**Breaking change:**
```
feat(api): change health check response format

BREAKING CHANGE: Health check endpoint now returns status object
instead of a boolean. Update frontend to use new format.

Before: { "healthy": true }
After: { "status": "ok", "timestamp": "2025-11-10T..." }
```

---

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] All tests pass locally
- [ ] Added tests for new features
- [ ] Updated documentation
- [ ] Checked for merge conflicts
- [ ] Rebased on latest main branch

### Creating the PR

1. **Title**: Clear, concise description
   ```
   feat(api): Add user authentication endpoint
   fix(frontend): Correct health check display
   ```

2. **Description**: Use this template:
   ```markdown
   ## Description
   Brief description of what this PR does.
   
   ## Changes
   - Added X feature
   - Fixed Y bug
   - Updated Z documentation
   
   ## Testing
   - [ ] Tested locally
   - [ ] Manual testing steps documented
   - [ ] Automated tests added/updated
   
   ## Screenshots (if applicable)
   [Add screenshots for UI changes]
   
   ## Related Issues
   Closes #123
   Related to #456
   ```

3. **Labels**: Add appropriate labels (bug, enhancement, documentation, etc.)

4. **Reviewers**: Request review from maintainers

### PR Review Process

**As an author:**
- Respond to feedback promptly
- Make requested changes
- Mark conversations as resolved when addressed
- Be patient and respectful

**As a reviewer:**
- Be constructive and specific
- Explain the "why" behind suggestions
- Approve when satisfied
- Request changes if needed

### CI/CD Checks

All PRs must pass:
- ✅ **Linting**: Code style checks
- ✅ **Build**: Frontend and API build successfully
- ✅ **Health checks**: All services start and pass health checks

If checks fail:
```bash
# Run locally to debug
make dev
make logs

# Fix issues and push again
git add .
git commit -m "fix: address CI issues"
git push
```

### Merging

- PRs require **1 approval** from a maintainer
- All CI checks must pass
- Use **"Squash and merge"** to keep history clean
- Delete branch after merge

---

## Testing

### Manual Testing

Always test your changes manually:

```bash
# Start full stack
make dev

# Test in browser
# - Frontend: http://localhost:5173
# - API: http://localhost:4000/health

# Check logs
make logs

# Check service status
make status

# Clean restart
make clean && make dev
```

### Automated Tests (Future)

When adding tests:
```bash
# Frontend tests
cd frontend
npm test

# API tests
cd api
npm test

# Run all tests
npm run test:all
```

---

## Documentation

### What to Document

**Always document:**
- New features (README, relevant docs)
- API endpoints (JSDoc comments)
- Configuration options (.env.example)
- Breaking changes (CHANGELOG.md)
- Architecture decisions (docs/ARCHITECTURE.md)

**Code comments:**
```typescript
// ✅ Good - explains "why"
// Retry 3 times because the database might be initializing
const maxRetries = 3;

// ❌ Bad - explains "what" (obvious from code)
// Set maxRetries to 3
const maxRetries = 3;
```

### Documentation Files

- **README.md**: Project overview, quick start
- **QUICKSTART.md**: 3-step setup guide
- **docs/DEVELOPER_GUIDE.md**: Detailed development workflow
- **docs/ARCHITECTURE.md**: System design and patterns
- **docs/AWS_DEPLOYMENT.md**: Cloud deployment guide
- **TROUBLESHOOTING.md**: Common issues and solutions
- **CHANGELOG.md**: Version history

### Updating Documentation

- Update docs in the same PR as code changes
- Keep examples up to date
- Test all commands and code examples
- Check for broken links

---

## Project Structure

Understanding the project structure helps you navigate and contribute:

```
ZeroToDev/
├── api/                    # Backend service
│   ├── src/
│   │   ├── routes/        # API routes
│   │   ├── db/            # Database connectors
│   │   ├── cache/         # Redis cache
│   │   ├── config/        # Configuration
│   │   └── middleware/    # Express middleware
│   ├── Dockerfile
│   └── package.json
│
├── frontend/              # React application
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── services/      # API client
│   │   └── types/         # TypeScript types
│   ├── Dockerfile
│   └── package.json
│
├── infra/                 # Infrastructure as Code
│   ├── terraform/
│   │   └── modules/       # Terraform modules
│   └── scripts/           # Deployment scripts
│
├── scripts/               # CLI utilities
│   ├── cli/              # Enhanced CLI tools
│   ├── dev.sh            # Start development
│   ├── down.sh           # Stop services
│   └── status.sh         # Service status
│
├── docs/                  # Documentation
│   ├── ARCHITECTURE.md
│   ├── DEVELOPER_GUIDE.md
│   ├── AWS_DEPLOYMENT.md
│   └── GITHUB_SETUP.md
│
├── .github/
│   └── workflows/         # GitHub Actions
│
├── docker-compose.yml     # Local orchestration
├── Makefile              # Build commands
└── README.md             # Project overview
```

---

## Questions?

If you have questions or need help:

1. **Check existing documentation:**
   - [README](README.md)
   - [Developer Guide](docs/DEVELOPER_GUIDE.md)
   - [Troubleshooting](TROUBLESHOOTING.md)

2. **Search existing issues:**
   - [Open Issues](../../issues)
   - [Closed Issues](../../issues?q=is%3Aissue+is%3Aclosed)

3. **Open a discussion:**
   - [GitHub Discussions](../../discussions)

4. **Open an issue:**
   - Use issue templates
   - Provide context and details
   - Be patient and respectful

---

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- CHANGELOG.md for significant contributions
- Project documentation

---

Thank you for contributing to making development environments easier for everyone! 🎉

