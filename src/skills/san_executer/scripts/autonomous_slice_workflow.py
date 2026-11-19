#!/usr/bin/env python3
"""
autonomous_slice_workflow.py — Deterministic `run_workflow` orchestration for `san_executer` (v3.0.0).

Implements the 3-phase Contract-First & Adversarial QA workflow:
  Phase 1 (`contract_lock`): Lock OpenAPI/Zod/TypeBox contract & Architectural Fitness invariants.
  Phase 2 (`parallel_slice_execution`): Execute Backend & Frontend slices in parallel (`workspace="share"`).
  Phase 3 (`adversarial_qa_loop`): Multi-turn loop (max 3 rounds) between coders and `san-qa-auditor`.

Supports:
  - Native Antigravity `run_workflow` runtime (`antigravity_workflow` module or injected workflow globals)
  - Standalone CLI `--self-test` and `--dry-run` modes via standard `python3`
"""

from __future__ import annotations

import argparse
import asyncio
import inspect
import json
import os
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Awaitable, Callable, Dict, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Strict JSON Schemas (enforced via `finish` in `run_workflow` & locally)
# ---------------------------------------------------------------------------

CONTRACT_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "required": [
        "contract_locked",
        "feature_name",
        "endpoints",
        "shared_schema_paths",
        "fitness_invariants",
        "summary",
    ],
    "properties": {
        "contract_locked": {"type": "boolean"},
        "feature_name": {"type": "string", "minLength": 1},
        "endpoints": {
            "type": "array",
            "items": {
                "type": "object",
                "additionalProperties": False,
                "required": ["method", "path", "idempotency_required"],
                "properties": {
                    "method": {"type": "string", "enum": ["GET", "POST", "PUT", "PATCH", "DELETE"]},
                    "path": {"type": "string", "minLength": 1},
                    "idempotency_required": {"type": "boolean"},
                    "request_schema": {"type": "string"},
                    "response_schema": {"type": "string"},
                },
            },
        },
        "shared_schema_paths": {
            "type": "array",
            "items": {"type": "string", "minLength": 1},
        },
        "fitness_invariants": {
            "type": "array",
            "items": {"type": "string", "minLength": 1},
        },
        "summary": {"type": "string", "minLength": 1},
    },
}

CODE_SLICE_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "required": [
        "role",
        "status",
        "files_changed",
        "dialectic_summary",
        "tests_executed",
        "tests_passed",
    ],
    "properties": {
        "role": {"type": "string", "enum": ["backend", "frontend"]},
        "status": {"type": "string", "enum": ["COMPLETED", "BLOCKED"]},
        "files_changed": {
            "type": "array",
            "items": {"type": "string", "minLength": 1},
        },
        "dialectic_summary": {"type": "string", "minLength": 1},
        "tests_executed": {
            "type": "array",
            "items": {"type": "string", "minLength": 1},
        },
        "tests_passed": {"type": "boolean"},
        "ui_states_verified": {
            "type": "array",
            "items": {
                "type": "string",
                "enum": [
                    "Empty",
                    "Skeleton Cold-Start",
                    "Populated",
                    "Stale-While-Revalidate",
                    "Error",
                ],
            },
        },
        "notes": {"type": "string"},
    },
}

QA_VERDICT_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "required": [
        "passed",
        "blocking_issues",
        "owasp_clean",
        "substance_clean",
        "dom_geometry_clean",
    ],
    "properties": {
        "passed": {"type": "boolean"},
        "verdict": {"type": "string", "enum": ["LIVRABLE", "RETOUR_ATELIER"]},
        "blocking_issues": {
            "type": "array",
            "items": {"type": "string"},
        },
        "owasp_clean": {"type": "boolean"},
        "substance_clean": {"type": "boolean"},
        "dom_geometry_clean": {"type": "boolean"},
        "fitness_clean": {"type": "boolean"},
        "recommendations": {
            "type": "array",
            "items": {"type": "string"},
        },
        "summary": {"type": "string"},
    },
}

MAX_QA_ROUNDS = 3


# ---------------------------------------------------------------------------
# Lightweight JSON Schema Validator (zero third-party dependency)
# ---------------------------------------------------------------------------

def validate_against_schema(data: Any, schema: Dict[str, Any], path: str = "$") -> List[str]:
    """Validate `data` against a strict JSON Schema subset and return error strings."""
    errors: List[str] = []
    expected_type = schema.get("type")

    if expected_type == "object":
        if not isinstance(data, dict):
            return [f"{path}: expected object, got {type(data).__name__}"]
        props = schema.get("properties", {})
        for req in schema.get("required", []):
            if req not in data:
                errors.append(f"{path}: missing required field '{req}'")
        if schema.get("additionalProperties") is False:
            for key in data:
                if key not in props:
                    errors.append(f"{path}: unexpected property '{key}'")
        for key, val in data.items():
            if key in props:
                errors.extend(validate_against_schema(val, props[key], f"{path}.{key}"))
    elif expected_type == "array":
        if not isinstance(data, list):
            return [f"{path}: expected array, got {type(data).__name__}"]
        item_schema = schema.get("items")
        if isinstance(item_schema, dict):
            for idx, item in enumerate(data):
                errors.extend(validate_against_schema(item, item_schema, f"{path}[{idx}]"))
    elif expected_type == "string":
        if not isinstance(data, str):
            return [f"{path}: expected string, got {type(data).__name__}"]
        min_len = schema.get("minLength")
        if isinstance(min_len, int) and len(data) < min_len:
            errors.append(f"{path}: string shorter than minLength {min_len}")
        enum_vals = schema.get("enum")
        if enum_vals is not None and data not in enum_vals:
            errors.append(f"{path}: value '{data}' not in {enum_vals}")
    elif expected_type == "boolean":
        if not isinstance(data, bool):
            return [f"{path}: expected boolean, got {type(data).__name__}"]
    elif expected_type == "integer":
        if not isinstance(data, int) or isinstance(data, bool):
            return [f"{path}: expected integer, got {type(data).__name__}"]
    elif expected_type == "number":
        if not isinstance(data, (int, float)) or isinstance(data, bool):
            return [f"{path}: expected number, got {type(data).__name__}"]

    return errors


def assert_schema(data: Any, schema: Dict[str, Any], label: str) -> None:
    errs = validate_against_schema(data, schema)
    if errs:
        raise ValueError(f"Schema validation failed for {label}: {'; '.join(errs)}")


# ---------------------------------------------------------------------------
# Antigravity `run_workflow` Binding + Standalone Fallback
# ---------------------------------------------------------------------------

class StandaloneAgentHandle:
    """Stateful mock agent supporting both `await agent(...)` and multi-turn `a = agent(...); await a(...)`."""

    def __init__(
        self,
        runtime: "StandaloneWorkflowRuntime",
        prompt: Optional[str],
        schema: Optional[Dict[str, Any]],
        role: Optional[str],
        type_name: str,
        workspace: str,
        model: Optional[str],
    ) -> None:
        self.runtime = runtime
        self.standing_prompt = prompt or ""
        self.default_schema = schema
        self.role = role or type_name
        self.type_name = type_name
        self.workspace = workspace
        self.model = model
        self.turns = 0

    def __call__(self, prompt: str, schema: Optional[Dict[str, Any]] = None) -> Awaitable[Dict[str, Any]]:
        effective_schema = schema or self.default_schema
        return self._run_turn(prompt, effective_schema)

    def __await__(self):
        return self._run_turn(self.standing_prompt, self.default_schema).__await__()

    async def _run_turn(self, prompt: str, schema: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        if self.model == "inherit":
            raise ValueError("Model 'inherit' is forbidden for worker sub-executions; configure executor in .agents/models.json.")
        if not isinstance(schema, dict):
            raise ValueError(f"Agent '{self.role}' requires a JSON schema dict.")
        self.turns += 1
        return self.runtime.simulate_response(self, prompt, schema)


class StandaloneWorkflowRuntime:
    """Deterministic local simulation runtime for `--dry-run` and `--self-test`."""

    def __init__(self, feature: str = "sample-feature", simulate_qa_retry: bool = False, force_qa_fail: bool = False) -> None:
        self.feature = feature
        self.simulate_qa_retry = simulate_qa_retry
        self.force_qa_fail = force_qa_fail
        self.phases: List[str] = []
        self.logs: List[str] = []
        self.qa_turn_count = 0

    def log(self, *values: Any) -> None:
        line = " ".join(str(v) for v in values)
        self.logs.append(line)

    def phase(self, name: str) -> None:
        self.phases.append(name)
        self.log(f"[phase] {name}")

    def agent(
        self,
        prompt: Optional[str] = None,
        schema: Optional[Dict[str, Any]] = None,
        role: Optional[str] = None,
        type_name: str = "self",
        workspace: str = "inherit",
        model: Optional[str] = None,
    ) -> StandaloneAgentHandle:
        return StandaloneAgentHandle(self, prompt, schema, role, type_name, workspace, model)

    async def parallel(self, items: Sequence[Any], fn: Callable[[Any], Awaitable[Any]]) -> List[Any]:
        return list(await asyncio.gather(*(fn(item) for item in items)))

    async def pipeline(self, items: Sequence[Any], fn: Callable[[Any], Awaitable[Any]]) -> List[Any]:
        results: List[Any] = []
        for item in items:
            results.append(await fn(item))
        return results

    def simulate_response(self, handle: StandaloneAgentHandle, prompt: str, schema: Dict[str, Any]) -> Dict[str, Any]:
        if schema is CONTRACT_SCHEMA:
            return {
                "contract_locked": True,
                "feature_name": self.feature,
                "endpoints": [
                    {
                        "method": "POST",
                        "path": "/api/v1/slice/execute",
                        "idempotency_required": True,
                        "request_schema": "shared/contracts/slice.ts#ExecuteRequestSchema",
                        "response_schema": "shared/contracts/slice.ts#ExecuteResponseSchema",
                    }
                ],
                "shared_schema_paths": [
                    "shared/contracts/slice.ts",
                    "bruno/slice/execute.bru",
                ],
                "fitness_invariants": [
                    "No domain -> infrastructure direct imports",
                    "Zero circular module dependencies",
                    "UI components <= 220 lines; backend classes <= 200 lines",
                ],
                "summary": f"Contract locked for '{self.feature}' with OpenAPI/Zod & Fitness invariants.",
            }

        if schema is CODE_SLICE_SCHEMA:
            is_front = "front" in handle.role.lower() or "frontend" in prompt.lower()
            role_val = "frontend" if is_front else "backend"
            payload: Dict[str, Any] = {
                "role": role_val,
                "status": "COMPLETED",
                "files_changed": (
                    ["src/components/SliceView.tsx", "src/hooks/useSlice.ts"]
                    if is_front
                    else ["src/services/SliceService.ts", "tests/integration/slice.spec.ts"]
                ),
                "dialectic_summary": "Evaluated Approach A (monolithic) vs Approach B (atomic Contract-First); selected B.",
                "tests_executed": ["npm test -- slice.spec.ts (exit 0)"],
                "tests_passed": True,
                "notes": f"Dry-run simulated {role_val} turn #{handle.turns}",
            }
            if is_front:
                payload["ui_states_verified"] = [
                    "Empty",
                    "Skeleton Cold-Start",
                    "Populated",
                    "Stale-While-Revalidate",
                    "Error",
                ]
            return payload

        if schema is QA_VERDICT_SCHEMA:
            self.qa_turn_count += 1
            should_fail = self.force_qa_fail or (self.simulate_qa_retry and self.qa_turn_count == 1)
            if should_fail:
                return {
                    "passed": False,
                    "verdict": "RETOUR_ATELIER",
                    "blocking_issues": [
                        "src/components/SliceView.tsx:48 [BLOQUANT] Missing tabular-nums on numeric total and touch target < 44px"
                    ],
                    "owasp_clean": True,
                    "substance_clean": True,
                    "dom_geometry_clean": False,
                    "fitness_clean": True,
                    "recommendations": ["Add tabular-nums and min-h-[44px] min-w-[44px] on primary CTA"],
                    "summary": f"QA round {self.qa_turn_count}: RETOUR_ATELIER due to DOM geometry finding.",
                }
            return {
                "passed": True,
                "verdict": "LIVRABLE",
                "blocking_issues": [],
                "owasp_clean": True,
                "substance_clean": True,
                "dom_geometry_clean": True,
                "fitness_clean": True,
                "recommendations": [],
                "summary": f"QA round {self.qa_turn_count}: LIVRABLE — OWASP, substance, fitness & DOM clean.",
            }

        raise ValueError("Unsupported schema in standalone simulation")


def resolve_workflow_runtime(runtime_override: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Resolve Antigravity `run_workflow` primitives cleanly:
    1. Explicit runtime override dict
    2. `from antigravity_workflow import agent, parallel, pipeline, phase, args`
    3. Module globals or caller frame globals injected by `run_workflow`
    4. None (caller selects StandaloneWorkflowRuntime)
    """
    if runtime_override and all(k in runtime_override for k in ("agent", "parallel", "pipeline", "phase")):
        return runtime_override

    try:
        from antigravity_workflow import agent as aw_agent  # type: ignore
        from antigravity_workflow import args as aw_args  # type: ignore
        from antigravity_workflow import parallel as aw_parallel  # type: ignore
        from antigravity_workflow import phase as aw_phase  # type: ignore
        from antigravity_workflow import pipeline as aw_pipeline  # type: ignore
        try:
            from antigravity_workflow import log as aw_log  # type: ignore
        except ImportError:
            aw_log = print
        try:
            from antigravity_workflow import WORKSPACES as aw_workspaces  # type: ignore
        except ImportError:
            aw_workspaces = ()
        return {
            "agent": aw_agent,
            "parallel": aw_parallel,
            "pipeline": aw_pipeline,
            "phase": aw_phase,
            "args": aw_args,
            "log": aw_log,
            "WORKSPACES": aw_workspaces,
        }
    except ImportError:
        pass

    required_keys = ("agent", "parallel", "pipeline", "phase")
    mod_globals = globals()
    if all(k in mod_globals for k in required_keys):
        return {
            "agent": mod_globals["agent"],
            "parallel": mod_globals["parallel"],
            "pipeline": mod_globals["pipeline"],
            "phase": mod_globals["phase"],
            "args": mod_globals.get("args", {}),
            "log": mod_globals.get("log", print),
            "WORKSPACES": mod_globals.get("WORKSPACES", ()),
        }

    frame = inspect.currentframe()
    try:
        caller = frame.f_back if frame else None
        while caller is not None:
            fg = caller.f_globals
            if all(k in fg for k in required_keys):
                return {
                    "agent": fg["agent"],
                    "parallel": fg["parallel"],
                    "pipeline": fg["pipeline"],
                    "phase": fg["phase"],
                    "args": fg.get("args", {}),
                    "log": fg.get("log", print),
                    "WORKSPACES": fg.get("WORKSPACES", ()),
                }
            caller = caller.f_back
    finally:
        del frame

    return {}


# ---------------------------------------------------------------------------
# Gate Status Summary (zéro création .agents/cache)
# ---------------------------------------------------------------------------

def resolve_workspace_root(workflow_args: Dict[str, Any], workspaces: Tuple[str, ...]) -> Path:
    ws = workflow_args.get("workspace")
    if isinstance(ws, str) and ws.strip():
        return Path(ws).resolve()
    if workspaces:
        return Path(workspaces[0]).resolve()
    return Path.cwd().resolve()


def build_gate_status_summary(
    passed: bool,
    feature: str,
    rounds: int,
    verdict: Dict[str, Any],
) -> Dict[str, Any]:
    return {
        "passed": bool(passed),
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source": "autonomous_slice_workflow",
        "feature": feature,
        "rounds": rounds,
        "owasp_clean": bool(verdict.get("owasp_clean", False)),
        "substance_clean": bool(verdict.get("substance_clean", False)),
        "dom_geometry_clean": bool(verdict.get("dom_geometry_clean", False)),
    }


def is_verdict_green(verdict: Dict[str, Any]) -> bool:
    return (
        bool(verdict.get("passed") is True)
        and len(verdict.get("blocking_issues", [])) == 0
        and bool(verdict.get("owasp_clean") is True)
        and bool(verdict.get("substance_clean") is True)
        and bool(verdict.get("dom_geometry_clean") is True)
    )


# ---------------------------------------------------------------------------
# Core 3-Phase Orchestration (`run_autonomous_slice`)
# ---------------------------------------------------------------------------

async def run_autonomous_slice(
    workflow_args: Optional[Dict[str, Any]] = None,
    workspaces: Tuple[str, ...] = (),
    runtime: Optional[Dict[str, Any]] = None,
    write_gate_status: bool = True,
) -> Dict[str, Any]:
    """
    Execute the 3-phase `san_executer` autonomous slice pipeline:
      1. `contract_lock`: Lock shared OpenAPI/Zod/TypeBox contract & Fitness Functions.
      2. `parallel_slice_execution`: Fan out backend & frontend slices concurrently.
      3. `adversarial_qa_loop`: Multi-turn `coder <-> san-qa-auditor` loop (max 3 rounds).
    """
    rt = resolve_workflow_runtime(runtime)
    if not rt:
        raise RuntimeError(
            "No run_workflow runtime detected. Pass `runtime=...` or invoke via CLI `--dry-run` / `--self-test`."
        )

    effective_args: Dict[str, Any] = dict(rt.get("args") or {})
    if workflow_args:
        effective_args.update(workflow_args)

    wf_agent = rt["agent"]
    wf_parallel = rt["parallel"]
    wf_pipeline = rt["pipeline"]
    wf_phase = rt["phase"]
    wf_log = rt.get("log", print)
    effective_workspaces = workspaces or tuple(rt.get("WORKSPACES") or ())

    feature = str(effective_args.get("feature", "Unnamed feature slice")).strip() or "Unnamed feature slice"
    profile = str(effective_args.get("profile", "FULL_STACK")).upper()
    max_rounds = min(int(effective_args.get("max_rounds", MAX_QA_ROUNDS)), MAX_QA_ROUNDS)
    if max_rounds < 1:
        max_rounds = 1

    # Never use `model="inherit"` inside workflow worker sub-executions (uses .agents/models.json)
    worker_model = str(effective_args.get("model", "pro"))
    if worker_model == "inherit":
        raise ValueError("Forbidden model 'inherit': worker executions require an explicit tier or .agents/models.json.")

    architect_type = str(effective_args.get("architect_agent", "san-architect"))
    back_type = str(effective_args.get("backend_agent", "san-coder-back"))
    front_type = str(effective_args.get("frontend_agent", "san-coder-front"))
    auditor_type = str(effective_args.get("auditor_agent", "san-qa-auditor"))

    # ------------------------------------------------------------------
    # PHASE 1: contract_lock
    # ------------------------------------------------------------------
    wf_phase("contract_lock")
    wf_log(f"Locking Contract-First spec & Fitness invariants for '{feature}' ({profile})")

    contract_prompt = (
        f"Phase 1 (contract_lock) for feature: {feature} (profile: {profile}).\n"
        "1. Respect project rules in .agents/rules/*.md.\n"
        "2. Lock shared OpenAPI 3.1 / Zod / TypeBox schemas and Bruno assertions before parallel coding.\n"
        "3. Define Architectural Fitness Functions (module boundaries, zero cycles, component/class budgets).\n"
        "Return strict JSON via `finish` matching CONTRACT_SCHEMA."
    )
    contract = await wf_agent(
        prompt=contract_prompt,
        schema=CONTRACT_SCHEMA,
        role="Contract Lock (san-architect)",
        type_name=architect_type,
        workspace="inherit",
        model=worker_model,
    )
    assert_schema(contract, CONTRACT_SCHEMA, "CONTRACT_SCHEMA")
    if not contract["contract_locked"]:
        raise RuntimeError(f"Contract lock failed for feature '{feature}': {contract.get('summary')}")

    # ------------------------------------------------------------------
    # PHASE 2: parallel_slice_execution
    # ------------------------------------------------------------------
    wf_phase("parallel_slice_execution")
    slice_specs: List[Dict[str, str]] = []
    if profile in ("BACK_ONLY", "FULL_STACK"):
        slice_specs.append({
            "role": "backend",
            "type_name": back_type,
            "workspace": "share" if profile == "FULL_STACK" else "inherit",
            "title": "Backend Slice (san-coder-back)",
        })
    if profile in ("FRONT_ONLY", "FULL_STACK"):
        slice_specs.append({
            "role": "frontend",
            "type_name": front_type,
            "workspace": "share" if profile == "FULL_STACK" else "inherit",
            "title": "Frontend Slice (san-coder-front)",
        })
    if not slice_specs:
        raise ValueError(f"Unsupported profile '{profile}'. Expected BACK_ONLY, FRONT_ONLY, or FULL_STACK.")

    def build_slice_agent(spec: Dict[str, str]) -> Awaitable[Dict[str, Any]]:
        role = spec["role"]
        ui_clause = (
            "Enforce 5 non-destructive UI states (Empty, Skeleton Cold-Start, Populated, "
            "Stale-While-Revalidate, Error), tabular-nums, touch targets >= 44x44px, and prefers-reduced-motion.\n"
            if role == "frontend"
            else "Enforce ACID DB transactions, Idempotency-Key, strict typing, and real integration tests (no Mock Theater).\n"
        )
        slice_prompt = (
            f"Phase 2 (parallel_slice_execution) [{role}] for '{feature}'.\n"
            f"Locked Contract: {json.dumps(contract, ensure_ascii=False)}\n"
            "1. Inspect the relevant target files directly.\n"
            "2. State 2-Approach Dialectic before editing files.\n"
            f"3. {ui_clause}"
            "4. Run unit/integration tests & quality gates; return strict JSON matching CODE_SLICE_SCHEMA."
        )
        return wf_agent(
            prompt=slice_prompt,
            schema=CODE_SLICE_SCHEMA,
            role=spec["title"],
            type_name=spec["type_name"],
            workspace=spec["workspace"],
            model=worker_model,
        )

    wf_log(f"Launching {len(slice_specs)} parallel implementation slice(s)...")
    slices_raw = await wf_parallel(slice_specs, build_slice_agent)
    for idx, sl in enumerate(slices_raw):
        assert_schema(sl, CODE_SLICE_SCHEMA, f"CODE_SLICE_SCHEMA[{idx}]")

    # ------------------------------------------------------------------
    # PHASE 3: adversarial_qa_loop (max 3 rounds coder <-> san-qa-auditor)
    # ------------------------------------------------------------------
    wf_phase("adversarial_qa_loop")
    auditor = wf_agent(
        prompt=(
            "You are `san-qa-auditor` operating under Presumption of Defect. "
            "Inspect real files, test substance (no Mock Theater), OWASP security, "
            "Architectural Fitness Functions, Quality Gates, and DOM geometry (`export_png.mjs --audit-dom`)."
        ),
        schema=QA_VERDICT_SCHEMA,
        role="QA Inquisitor (san-qa-auditor)",
        type_name=auditor_type,
        workspace="inherit",
        model=worker_model,
    )

    latest_verdict: Dict[str, Any] = {}
    rounds_run = 0
    latest_slices = list(slices_raw)

    for round_idx in range(1, max_rounds + 1):
        rounds_run = round_idx
        audit_prompt = (
            f"Adversarial QA Round {round_idx}/{max_rounds} for '{feature}'.\n"
            f"Contract: {json.dumps(contract, ensure_ascii=False)}\n"
            f"Latest Code Slices: {json.dumps(latest_slices, ensure_ascii=False)}\n"
            "Verify Quality Gate exit 0, OWASP/secrets, test substance, Fitness Functions, and DOM geometry. "
            "Return strict JSON matching QA_VERDICT_SCHEMA."
        )
        verdict = await auditor(audit_prompt, QA_VERDICT_SCHEMA)
        assert_schema(verdict, QA_VERDICT_SCHEMA, f"QA_VERDICT_SCHEMA(round={round_idx})")
        latest_verdict = verdict

        if is_verdict_green(verdict):
            wf_log(f"QA Round {round_idx}/{max_rounds}: PASSED (LIVRABLE)")
            break

        wf_log(
            f"QA Round {round_idx}/{max_rounds}: RETOUR_ATELIER "
            f"({len(verdict.get('blocking_issues', []))} blocking issue(s))"
        )
        if round_idx < max_rounds:
            # Ordered remediation pipeline across active slice specs
            def remediate_slice(spec: Dict[str, str]) -> Awaitable[Dict[str, Any]]:
                fix_prompt = (
                    f"Remediation Turn for QA Round {round_idx} [{spec['role']}] on '{feature}'.\n"
                    f"Blocking issues to resolve: {json.dumps(verdict.get('blocking_issues', []), ensure_ascii=False)}\n"
                    f"OWASP clean={verdict['owasp_clean']}, Substance clean={verdict['substance_clean']}, "
                    f"DOM clean={verdict['dom_geometry_clean']}.\n"
                    "Fix every issue within your role and re-run tests. Return CODE_SLICE_SCHEMA."
                )
                return wf_agent(
                    prompt=fix_prompt,
                    schema=CODE_SLICE_SCHEMA,
                    role=f"Fix {spec['role']} (Round {round_idx})",
                    type_name=spec["type_name"],
                    workspace=spec["workspace"],
                    model=worker_model,
                )

            remediated = await wf_pipeline(slice_specs, remediate_slice)
            for idx, sl in enumerate(remediated):
                assert_schema(sl, CODE_SLICE_SCHEMA, f"CODE_SLICE_SCHEMA_FIX[{idx}]")
            latest_slices = list(remediated)

    passed_final = is_verdict_green(latest_verdict)
    gate_summary: Optional[Dict[str, Any]] = None
    if passed_final:
        gate_summary = build_gate_status_summary(True, feature, rounds_run, latest_verdict)

    return {
        "feature": feature,
        "profile": profile,
        "passed": passed_final,
        "verdict": "LIVRABLE" if passed_final else "RETOUR_ATELIER",
        "rounds": rounds_run,
        "contract": contract,
        "slices": latest_slices,
        "qa_verdict": latest_verdict,
        "gate_summary": gate_summary,
    }


# ---------------------------------------------------------------------------
# Self-Test & CLI Entrypoint
# ---------------------------------------------------------------------------

async def run_self_test() -> Dict[str, Any]:
    """Run deterministic self-tests covering schemas, 3 phases, and retry loop (max 3)."""
    for name, schema in (
        ("CONTRACT_SCHEMA", CONTRACT_SCHEMA),
        ("CODE_SLICE_SCHEMA", CODE_SLICE_SCHEMA),
        ("QA_VERDICT_SCHEMA", QA_VERDICT_SCHEMA),
    ):
        if schema.get("additionalProperties") is not False:
            raise AssertionError(f"{name} must enforce additionalProperties: False")

    for required_key in ("passed", "blocking_issues", "owasp_clean", "substance_clean", "dom_geometry_clean"):
        if required_key not in QA_VERDICT_SCHEMA["required"]:
            raise AssertionError(f"QA_VERDICT_SCHEMA missing required field '{required_key}'")

    with tempfile.TemporaryDirectory(prefix="san_slice_selftest_") as tmpdir:
        tmp_path = Path(tmpdir)

        # 2. Test nominal multi-turn adversarial loop (Round 1 RETOUR_ATELIER -> Fix -> Round 2 LIVRABLE)
        rt_retry = StandaloneWorkflowRuntime(feature="momo-checkout", simulate_qa_retry=True)
        runtime_dict = {
            "agent": rt_retry.agent,
            "parallel": rt_retry.parallel,
            "pipeline": rt_retry.pipeline,
            "phase": rt_retry.phase,
            "log": rt_retry.log,
            "args": {"feature": "momo-checkout", "profile": "FULL_STACK", "workspace": str(tmp_path)},
            "WORKSPACES": (str(tmp_path),),
        }
        res_pass = await run_autonomous_slice(runtime=runtime_dict, write_gate_status=True)
        assert res_pass["passed"] is True, "Expected retry workflow to pass on round 2"
        assert res_pass["rounds"] == 2, f"Expected 2 rounds, got {res_pass['rounds']}"
        assert rt_retry.phases == ["contract_lock", "parallel_slice_execution", "adversarial_qa_loop"]
        assert isinstance(res_pass.get("gate_summary"), dict) and res_pass["gate_summary"]["passed"] is True
        assert not (tmp_path / ".agents" / "cache").exists(), "Zero .agents/cache directory expected"

        # 3. Test fail-closed behavior after 3 failed rounds
        fail_dir = tmp_path / "fail_case"
        fail_dir.mkdir()
        rt_fail = StandaloneWorkflowRuntime(feature="broken-slice", force_qa_fail=True)
        runtime_fail = {
            "agent": rt_fail.agent,
            "parallel": rt_fail.parallel,
            "pipeline": rt_fail.pipeline,
            "phase": rt_fail.phase,
            "log": rt_fail.log,
            "args": {"feature": "broken-slice", "profile": "FULL_STACK", "workspace": str(fail_dir)},
            "WORKSPACES": (str(fail_dir),),
        }
        res_fail = await run_autonomous_slice(runtime=runtime_fail, write_gate_status=True)
        assert res_fail["passed"] is False, "Expected persistent failure to fail-closed"
        assert res_fail["rounds"] == 3, f"Expected cap at 3 rounds, got {res_fail['rounds']}"
        assert res_fail["verdict"] == "RETOUR_ATELIER"
        assert res_fail.get("gate_summary") is None

        # 4. Test worker model guard: model="inherit" must raise ValueError
        try:
            rt_bad = StandaloneWorkflowRuntime(feature="bad-model")
            await run_autonomous_slice(
                workflow_args={"feature": "bad-model", "model": "inherit"},
                runtime={
                    "agent": rt_bad.agent,
                    "parallel": rt_bad.parallel,
                    "pipeline": rt_bad.pipeline,
                    "phase": rt_bad.phase,
                    "log": rt_bad.log,
                    "args": {},
                    "WORKSPACES": (str(tmp_path),),
                },
                write_gate_status=False,
            )
            raise AssertionError("Expected model='inherit' to be rejected")
        except ValueError:
            pass

    return {
        "self_test": "PASSED",
        "schemas_verified": ["CONTRACT_SCHEMA", "CODE_SLICE_SCHEMA", "QA_VERDICT_SCHEMA"],
        "phases_verified": ["contract_lock", "parallel_slice_execution", "adversarial_qa_loop"],
        "max_qa_rounds": MAX_QA_ROUNDS,
        "gate_summary_verified": True,
    }


def parse_cli_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="san_executer run_workflow orchestrator (Contract-First + Parallel Slices + Adversarial QA Loop)"
    )
    parser.add_argument("--dry-run", action="store_true", help="Simulate the 3-phase workflow without LLM calls")
    parser.add_argument("--self-test", action="store_true", help="Run internal schema and loop self-tests")
    parser.add_argument("--feature", default="sample-feature", help="Target feature name for dry-run")
    parser.add_argument(
        "--profile",
        default="FULL_STACK",
        choices=["BACK_ONLY", "FRONT_ONLY", "FULL_STACK"],
        help="Execution profile",
    )
    parser.add_argument("--workspace", default="", help="Workspace directory path")
    parser.add_argument("--write-gate-status", action="store_true", help="Deprecated no-op flag (zero .agents/cache)")
    parser.add_argument("--json", action="store_true", help="Emit JSON output")
    return parser.parse_args(argv)


def main() -> int:
    cli_args = parse_cli_args()
    if cli_args.self_test:
        summary = asyncio.run(run_self_test())
        print(json.dumps(summary, indent=2, ensure_ascii=False))
        return 0

    if cli_args.dry_run:
        rt = StandaloneWorkflowRuntime(feature=cli_args.feature)
        ws = (cli_args.workspace,) if cli_args.workspace else (os.getcwd(),)
        runtime_dict = {
            "agent": rt.agent,
            "parallel": rt.parallel,
            "pipeline": rt.pipeline,
            "phase": rt.phase,
            "log": rt.log,
            "args": {"feature": cli_args.feature, "profile": cli_args.profile},
            "WORKSPACES": ws,
        }
        result = asyncio.run(
            run_autonomous_slice(
                runtime=runtime_dict,
                write_gate_status=bool(cli_args.write_gate_status),
            )
        )
        print(json.dumps(result, indent=2, ensure_ascii=False))
        return 0 if result["passed"] else 1

    print(
        json.dumps(
            {
                "mode": "run_workflow_module",
                "entrypoint": "run_autonomous_slice(args, WORKSPACES)",
                "hint": "Use --dry-run or --self-test for standalone CLI execution, or invoke via Antigravity run_workflow.",
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
