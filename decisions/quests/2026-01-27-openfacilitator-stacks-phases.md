# Phases

## Phase 1: Core — Chain & Token Registration
**Status:** completed
**Goal:** Register Stacks chains and tokens in the core package so the rest of the system can reference them.
**Packages:** `packages/core`
**Commit:** `ee44079` feat(core): register Stacks chains and tokens

## Phase 2: Core — Settlement Module
**Status:** completed
**Goal:** Implement Stacks payment settlement (broadcast + verification) matching the Solana pattern.
**Packages:** `packages/core`
**Commit:** `c3db553` feat(core): add Stacks settlement module

## Phase 3: SDK — Network Support
**Status:** completed
**Goal:** Extend the SDK to recognize and handle Stacks networks.
**Packages:** `packages/sdk`
**Commit:** `677e28e` feat(sdk): add Stacks network support

## Phase 4: Server — Database & Wallet Infrastructure
**Status:** completed
**Goal:** Add Stacks key storage, wallet generation, and balance checking to the server.
**Packages:** `packages/server`
**Commit:** `5543d0f` feat(server): add Stacks database schema and wallet services

## Phase 5: Server — Routes & API
**Status:** completed
**Goal:** Expose Stacks wallet management and settlement through server routes.
**Packages:** `packages/server`
**Commit:** `22b26ec` feat(server): add Stacks routes for wallet management and settlement

## Phase 6: Dashboard — Stacks Provider & Wallet UI
**Status:** completed
**Goal:** Add Stacks wallet connection and management UI to the dashboard.
**Packages:** `apps/dashboard`
**Commit:** `92bf48c` feat(dashboard): add Stacks wallet management UI
