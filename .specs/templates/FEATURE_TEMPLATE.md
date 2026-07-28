# SPEC-[ID]: [Feature Title]

- **Status:** [DRAFT | IN REVIEW | APPROVED | IN PROGRESS | COMPLETED]
- **Author:** [Your Name / Gemini Code Agent]
- **Created Date:** [YYYY-MM-DD]
- **Target Feature Path:** `src/renderer/src/features/[feature-name]/`

---

## 1. Executive Summary & Problem Statement
Briefly explain what this feature achieves and what problem it solves within the application.

## 2. Functional Requirements
List user-facing capabilities using exact, testable criteria.
- [ ] **FR-1:** User can click "X" to trigger "Y".
- [ ] **FR-2:** Input must be validated using Zod schema `[SchemaName]`.

## 3. Technical Architecture & File Plan
Specify exact file paths to be created or modified according to `AGENTS.md` rules.

### New Files
- `src/renderer/src/features/[feature-name]/index.tsx` (Main Orchestrator)
- `src/renderer/src/features/[feature-name]/components/MainComponent.tsx`
- `src/renderer/src/features/[feature-name]/components/index.ts` (Barrel Export)
- `src/renderer/src/features/[feature-name]/types/index.ts` (Zod Schemas & Types)
- `src/renderer/src/features/[feature-name]/utils/index.ts` (Module Helpers)

### Modified Files
- `src/main/ipc/channelHandlers.ts` (New IPC Channel Listener)
- `src/main/services/FeatureService.ts` (Singleton Business Logic)

## 4. API & Data Flow Contracts
Define IPC channel names, payload interfaces, and Zod validation schemas.

### IPC Channels
- `CHANNEL_NAME`: Request payload structure and expected return format.

### Preload API Exposure
- **Exposed Method:** `window.api.[featureName].methodName(payload)`
- **Bridge File:** `src/preload/index.ts`

### Data Schemas
```typescript
// Define expected Zod schema for input/output validation
export const FeatureInputSchema = z.object({
  id: z.string(),
  // ...
});
```

## 5. Non-Functional & Security Constraints
- JSDoc mandatory for all exported functions, hooks, services, and utilities.
- Strict function limits (under 40–50 lines per function) following SRP.
- Zero usage of `any`; all contracts must pass Zod schema validation.
- API keys stored exclusively in Main process using Electron `safeStorage`.

## 6. Implementation Checklist
- [ ] Step 1: Create Main Process IPC service and Singleton method.
- [ ] Step 2: Define Zod schemas and export TypeScript interfaces.
- [ ] Step 3: Create UI feature module with barrel exports.
- [ ] Step 4: Run npm run lint and verify Oxlint pass.