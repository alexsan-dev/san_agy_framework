#!/usr/bin/env python3
"""
parallel_inquisition_workflow.py — Fan-out `run_workflow` audit for `san_qa_security_expert` (v2.1.0).

Executes a 3-track parallel inquisition under Presumption of Defect:
  1. `owasp_secrets`: OWASP Top 10 / API Security 2023 / BOLA-IDOR & hardcoded secrets scan.
  2. `test_substance_fitness`: Anti-Mock Theater test substance audit & Architectural Fitness Functions.
  3. `dom_geometry_ui`: DOM geometry linter (`export_png.mjs --audit-dom`) & 5 non-destructive UI states.

Aggregates all tracks deterministically into `INQUISITION_REPORT_SCHEMA` and emits binary
verdict (`LIVRABLE` | `RETOUR_ATELIER`), optionally persisting `.agents/cache/last-gate-status.json`.

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
# Strict JSON Schemas (`TRACK_FINDING_SCHEMA` & `INQUISITION_REPORT_SCHEMA`)
# ---------------------------------------------------------------------------

FINDING_ITEM_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "required": ["location", "severity", "rule", "description", "remediation"],
    "properties": {
        "location": {"type": "string", "minLength": 1},
        "severity": {"type": "string", "enum": ["BLOQUANT", "ELEVATION_QUALITE"]},
        "rule": {"type": "string", "minLength": 1},
        "description": {"type": "string", "minLength": 1},
        "remediation": {"type": "string", "minLength": 1},
    },
}

TRACK_FINDING_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "required": [
        "track_id",
        "passed",
        "score",
        "blocking_issues",
        "checks_executed",
        "summary",
    ],
    "properties": {
        "track_id": {
            "type": "string",
            "enum": ["owasp_secrets", "test_substance_fitness", "dom_geometry_ui"],
        },
        "passed": {"type": "boolean"},
        "score": {"type": "number"},
        "blocking_issues": {
            "type": "array",
            "items": FINDING_ITEM_SCHEMA,
        },
        "warnings": {
            "type": "array",
            "items": {"type": "string"},
        },
        "checks_executed": {
            "type": "array",
            "items": {"type": "string", "minLength": 1},
        },
        "summary": {"type": "string", "minLength": 1},
    },
}

INQUISITION_REPORT_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "additionalProperties": False,
    "required": [
        "verdict",
        "passed",
        "security_score",
        "blocking_count",
        "owasp_clean",
        "substance_clean",
        "fitness_clean",
        "dom_geometry_clean",
        "ui_5_states_clean",
        "tracks",
        "blocking_issues",
        "timestamp",
    ],
    "properties": {
        "verdict": {"type": "string", "enum": ["LIVRABLE", "RETOUR_ATELIER"]},
        "passed": {"type": "boolean"},
        "security_score": {"type": "number"},
        "blocking_count": {"type": "integer"},
        "owasp_clean": {"type": "boolean"},
        "substance_clean": {"type": "boolean"},
        "fitness_clean": {"type": "boolean"},
        "dom_geometry_clean": {"type": "boolean"},
        "ui_5_states_clean": {"type": "boolean"},
        "tracks": {
            "type": "object",
            "additionalProperties": False,
            "required": ["owasp_secrets", "test_substance_fitness", "dom_geometry_ui"],
            "properties": {
                "owasp_secrets": TRACK_FINDING_SCHEMA,
                "test_substance_fitness": TRACK_FINDING_SCHEMA,
                "dom_geometry_ui": TRACK_FINDING_SCHEMA,
            },
        },
        "blocking_issues": {
            "type": "array",
            "items": FINDING_ITEM_SCHEMA,
        },
        "timestamp": {"type": "string", "minLength": 1},
    },
}

AUDIT_TRACKS: Tuple[Dict[str, str], ...] = (
    {
        "track_id": "owasp_secrets",
        "role": "Track 1: OWASP & Secrets Auditor",
        "focus": (
            "Audit OWASP Top 10 / API Security 2023 (BOLA/IDOR, injections, auth, rate-limits, "
            "Idempotency-Key), scan hardcoded secrets/DB credentials via qa_security_gate.sh, "
            "and verify 3G throttling resilience."
        ),
    },
    {
        "track_id": "test_substance_fitness",
        "role": "Track 2: Test Substance & Fitness Auditor",
        "focus": (
            "Detect Mocking Theater (mocked SUT, tautologies, --passWithNoTests, || true) AND "
            "verify Architectural Fitness Functions (module layer boundaries, zero circular deps, "
            "UI <= 220 lines, backend <= 200 lines, bundle budgets)."
        ),
    },
    {
        "track_id": "dom_geometry_ui",
        "role": "Track 3: DOM Geometry & 5 UI States Auditor",
        "focus": (
            "Execute `export_png.mjs --viewports=mobile,tablet,desktop --audit-dom` (overflows, "
            "box collisions, touch targets < 44x44px, tabular-nums) and verify the 5 non-destructive "
            "UI states (Empty, Skeleton Cold-Start, Populated, Stale-While-Revalidate, Error) + prefers-reduced-motion."
        ),
    },
)


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
    """Mock agent handle for standalone CLI `--dry-run` and `--self-test`."""

    def __init__(
        self,
        runtime: "StandaloneInquisitionRuntime",
        prompt: Optional[str],
        schema: Optional[Dict[str, Any]],
        role: Optional[str],
        type_name: str,
        workspace: str,
        model: Optional[str],
    ) -> None:
        self.runtime = runtime
        self.prompt = prompt or ""
        self.schema = schema
        self.role = role or type_name
        self.type_name = type_name
        self.workspace = workspace
        self.model = model

    def __await__(self):
        return self._execute().__await__()

    async def _execute(self) -> Dict[str, Any]:
        if self.model == "inherit":
            raise ValueError("Model 'inherit' is forbidden on Argon/Carbon; use explicit tier or gemini-4-hydrogen-xhigh.")
        if not isinstance(self.schema, dict):
            raise ValueError(f"Agent '{self.role}' requires a JSON schema dict.")
        return self.runtime.simulate_track(self.prompt)


class StandaloneInquisitionRuntime:
    """Deterministic simulation runtime for 3-track parallel audit tests."""

    def __init__(self, fail_track: Optional[str] = None) -> None:
        self.fail_track = fail_track
        self.phases: List[str] = []
        self.logs: List[str] = []

    def log(self, *values: Any) -> None:
        self.logs.append(" ".join(str(v) for v in values))

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

    def simulate_track(self, prompt: str) -> Dict[str, Any]:
        track_id = "owasp_secrets"
        if "test_substance_fitness" in prompt:
            track_id = "test_substance_fitness"
        elif "dom_geometry_ui" in prompt:
            track_id = "dom_geometry_ui"

        if self.fail_track == track_id:
            return {
                "track_id": track_id,
                "passed": False,
                "score": 68,
                "blocking_issues": [
                    {
                        "location": "design/mockup/checkout.html:112",
                        "severity": "BLOQUANT",
                        "rule": "DOM_HORIZONTAL_OVERFLOW" if track_id == "dom_geometry_ui" else "FITNESS_BOUNDARY_BREACH",
                        "description": f"Simulated blocking defect detected on track '{track_id}'.",
                        "remediation": "Resolve blocking anomaly and re-run parallel_inquisition_workflow.",
                    }
                ],
                "warnings": ["Simulated fail-closed test warning"],
                "checks_executed": [f"simulated_{track_id}_audit"],
                "summary": f"Track '{track_id}' failed with 1 blocking issue.",
            }

        checks_map = {
            "owasp_secrets": ["qa_security_gate.sh", "owasp_api_2023_checklist", "secrets_regex_scan"],
            "test_substance_fitness": ["anti_mock_theater_scan", "fitness_module_boundaries", "fitness_cycle_check"],
            "dom_geometry_ui": ["export_png.mjs --viewports=mobile,tablet,desktop --audit-dom", "ui_5_states_check"],
        }
        return {
            "track_id": track_id,
            "passed": True,
            "score": 96,
            "blocking_issues": [],
            "warnings": [],
            "checks_executed": checks_map[track_id],
            "summary": f"Track '{track_id}' clean (0 blocking issues).",
        }


def resolve_workflow_runtime(runtime_override: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """Resolve `run_workflow` primitives from explicit override, `antigravity_workflow`, or caller globals."""
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
# Aggregation & Persistence
# ---------------------------------------------------------------------------

def aggregate_inquisition_report(track_results: Sequence[Dict[str, Any]]) -> Dict[str, Any]:
    """Aggregate the 3 parallel track outputs into a strict `INQUISITION_REPORT_SCHEMA` verdict."""
    tracks_by_id: Dict[str, Dict[str, Any]] = {}
    for res in track_results:
        assert_schema(res, TRACK_FINDING_SCHEMA, "TRACK_FINDING_SCHEMA")
        tracks_by_id[res["track_id"]] = res

    expected_ids = ("owasp_secrets", "test_substance_fitness", "dom_geometry_ui")
    for tid in expected_ids:
        if tid not in tracks_by_id:
            raise ValueError(f"Missing required audit track result: '{tid}'")

    all_blocking: List[Dict[str, Any]] = []
    for tid in expected_ids:
        for issue in tracks_by_id[tid]["blocking_issues"]:
            if issue["severity"] == "BLOQUANT":
                all_blocking.append(issue)

    owasp_track = tracks_by_id["owasp_secrets"]
    substance_track = tracks_by_id["test_substance_fitness"]
    dom_track = tracks_by_id["dom_geometry_ui"]

    owasp_clean = owasp_track["passed"] and not any(
        i["severity"] == "BLOQUANT" for i in owasp_track["blocking_issues"]
    )
    substance_clean = substance_track["passed"] and not any(
        i["severity"] == "BLOQUANT" for i in substance_track["blocking_issues"]
    )
    fitness_clean = substance_clean and not any(
        "FITNESS" in i["rule"].upper() for i in substance_track["blocking_issues"]
    )
    dom_geometry_clean = dom_track["passed"] and not any(
        i["severity"] == "BLOQUANT" for i in dom_track["blocking_issues"]
    )
    ui_5_states_clean = dom_geometry_clean

    security_score = round(
        min(
            float(owasp_track["score"]),
            (float(owasp_track["score"]) + float(substance_track["score"]) + float(dom_track["score"])) / 3.0,
        ),
        2,
    )

    passed = (
        len(all_blocking) == 0
        and security_score >= 90.0
        and owasp_clean
        and substance_clean
        and fitness_clean
        and dom_geometry_clean
        and ui_5_states_clean
    )

    report: Dict[str, Any] = {
        "verdict": "LIVRABLE" if passed else "RETOUR_ATELIER",
        "passed": passed,
        "security_score": security_score,
        "blocking_count": len(all_blocking),
        "owasp_clean": owasp_clean,
        "substance_clean": substance_clean,
        "fitness_clean": fitness_clean,
        "dom_geometry_clean": dom_geometry_clean,
        "ui_5_states_clean": ui_5_states_clean,
        "tracks": {
            "owasp_secrets": owasp_track,
            "test_substance_fitness": substance_track,
            "dom_geometry_ui": dom_track,
        },
        "blocking_issues": all_blocking,
        "timestamp": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }
    assert_schema(report, INQUISITION_REPORT_SCHEMA, "INQUISITION_REPORT_SCHEMA")
    return report


def write_last_gate_status(workspace_root: Path, report: Dict[str, Any], target: str) -> Path:
    cache_dir = workspace_root / ".agents" / "cache"
    cache_dir.mkdir(parents=True, exist_ok=True)
    gate_file = cache_dir / "last-gate-status.json"
    payload = {
        "passed": bool(report["passed"]),
        "timestamp": report["timestamp"],
        "source": "parallel_inquisition_workflow",
        "target": target,
        "verdict": report["verdict"],
        "security_score": report["security_score"],
        "blocking_count": report["blocking_count"],
    }
    tmp_file = cache_dir / f".last-gate-status.{os.getpid()}.tmp"
    tmp_file.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.replace(tmp_file, gate_file)
    return gate_file


# ---------------------------------------------------------------------------
# Parallel Inquisition Entrypoint (`run_parallel_inquisition`)
# ---------------------------------------------------------------------------

async def run_parallel_inquisition(
    workflow_args: Optional[Dict[str, Any]] = None,
    workspaces: Tuple[str, ...] = (),
    runtime: Optional[Dict[str, Any]] = None,
    write_gate_status: bool = True,
) -> Dict[str, Any]:
    """Execute the 3-track parallel inquisition and return an `INQUISITION_REPORT_SCHEMA` report."""
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
    wf_phase = rt["phase"]
    wf_log = rt.get("log", print)
    effective_workspaces = workspaces or tuple(rt.get("WORKSPACES") or ())

    target = str(effective_args.get("target", ".")).strip() or "."
    html_target = str(effective_args.get("html_target", "")).strip()
    auditor_type = str(effective_args.get("auditor_agent", "san-qa-auditor"))
    worker_model = str(effective_args.get("model", "pro"))
    if worker_model == "inherit":
        raise ValueError("Forbidden model 'inherit': Argon/Carbon quota protection requires explicit tier.")

    wf_phase("parallel_inquisition_fanout")
    wf_log(f"Launching 3-track parallel inquisition on target='{target}'")

    def build_track_agent(track: Dict[str, str]) -> Awaitable[Dict[str, Any]]:
        tid = track["track_id"]
        dom_hint = f" HTML/Design target: {html_target}." if html_target and tid == "dom_geometry_ui" else ""
        prompt = (
            f"Audit Track '{tid}' on target '{target}'.{dom_hint}\n"
            "1. Consult .agents/cache/REPO_MAP.md first (Map-First).\n"
            f"2. Focus: {track['focus']}\n"
            "3. Operate strictly read-only under Presumption of Defect (zero code edits).\n"
            "Return strict JSON matching TRACK_FINDING_SCHEMA."
        )
        return wf_agent(
            prompt=prompt,
            schema=TRACK_FINDING_SCHEMA,
            role=track["role"],
            type_name=auditor_type,
            workspace="inherit",
            model=worker_model,
        )

    track_results = await wf_parallel(list(AUDIT_TRACKS), build_track_agent)

    wf_phase("inquisition_aggregation")
    report = aggregate_inquisition_report(track_results)
    wf_log(
        f"Inquisition verdict: {report['verdict']} "
        f"(score={report['security_score']}, blocking={report['blocking_count']})"
    )

    if report["passed"] and write_gate_status:
        ws_arg = effective_args.get("workspace")
        ws_root = (
            Path(ws_arg).resolve()
            if isinstance(ws_arg, str) and ws_arg.strip()
            else (Path(effective_workspaces[0]).resolve() if effective_workspaces else Path.cwd().resolve())
        )
        gate_path = write_last_gate_status(ws_root, report, target)
        wf_log(f"Updated gate proof: {gate_path}")

    return report


# ---------------------------------------------------------------------------
# Self-Test & CLI Entrypoint
# ---------------------------------------------------------------------------

async def run_self_test() -> Dict[str, Any]:
    """Run deterministic self-tests for 3-track parallel fan-out, aggregation, and fail-closed verdicts."""
    if INQUISITION_REPORT_SCHEMA.get("additionalProperties") is not False:
        raise AssertionError("INQUISITION_REPORT_SCHEMA must enforce additionalProperties: False")

    with tempfile.TemporaryDirectory(prefix="san_inquisition_selftest_") as tmpdir:
        tmp_path = Path(tmpdir)

        # 1. Nominal LIVRABLE test
        rt_pass = StandaloneInquisitionRuntime()
        report_pass = await run_parallel_inquisition(
            workflow_args={"target": "src/", "workspace": str(tmp_path)},
            workspaces=(str(tmp_path),),
            runtime={
                "agent": rt_pass.agent,
                "parallel": rt_pass.parallel,
                "pipeline": rt_pass.pipeline,
                "phase": rt_pass.phase,
                "log": rt_pass.log,
                "args": {},
                "WORKSPACES": (str(tmp_path),),
            },
            write_gate_status=True,
        )
        assert report_pass["verdict"] == "LIVRABLE"
        assert report_pass["passed"] is True
        assert report_pass["blocking_count"] == 0
        assert report_pass["owasp_clean"] is True
        assert report_pass["substance_clean"] is True
        assert report_pass["fitness_clean"] is True
        assert report_pass["dom_geometry_clean"] is True
        assert (tmp_path / ".agents" / "cache" / "last-gate-status.json").is_file()

        # 2. Fail-closed RETOUR_ATELIER when DOM geometry track fails
        fail_dir = tmp_path / "fail_dom"
        fail_dir.mkdir()
        rt_fail = StandaloneInquisitionRuntime(fail_track="dom_geometry_ui")
        report_fail = await run_parallel_inquisition(
            workflow_args={"target": "src/", "workspace": str(fail_dir)},
            workspaces=(str(fail_dir),),
            runtime={
                "agent": rt_fail.agent,
                "parallel": rt_fail.parallel,
                "pipeline": rt_fail.pipeline,
                "phase": rt_fail.phase,
                "log": rt_fail.log,
                "args": {},
                "WORKSPACES": (str(fail_dir),),
            },
            write_gate_status=True,
        )
        assert report_fail["verdict"] == "RETOUR_ATELIER"
        assert report_fail["passed"] is False
        assert report_fail["dom_geometry_clean"] is False
        assert report_fail["blocking_count"] == 1
        assert not (fail_dir / ".agents" / "cache" / "last-gate-status.json").exists()

    return {
        "self_test": "PASSED",
        "tracks_verified": ["owasp_secrets", "test_substance_fitness", "dom_geometry_ui"],
        "schemas_verified": ["TRACK_FINDING_SCHEMA", "INQUISITION_REPORT_SCHEMA"],
        "fail_closed_verified": True,
    }


def parse_cli_args(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="san_qa_security_expert parallel 3-track inquisition workflow"
    )
    parser.add_argument("--dry-run", action="store_true", help="Simulate 3-track parallel audit")
    parser.add_argument("--self-test", action="store_true", help="Run internal schema and aggregation self-tests")
    parser.add_argument("--target", default=".", help="Target path or module under audit")
    parser.add_argument("--html-target", default="", help="Optional HTML/UI path for DOM geometry audit")
    parser.add_argument("--report", default="", help="Optional path to write JSON report")
    parser.add_argument("--workspace", default="", help="Workspace directory path")
    parser.add_argument("--write-gate-status", action="store_true", help="Persist .agents/cache/last-gate-status.json on pass")
    parser.add_argument("--json", action="store_true", help="Emit JSON output")
    return parser.parse_args(argv)


def main() -> int:
    cli_args = parse_cli_args()
    if cli_args.self_test:
        summary = asyncio.run(run_self_test())
        print(json.dumps(summary, indent=2, ensure_ascii=False))
        return 0

    if cli_args.dry_run:
        rt = StandaloneInquisitionRuntime()
        ws = (cli_args.workspace,) if cli_args.workspace else (os.getcwd(),)
        report = asyncio.run(
            run_parallel_inquisition(
                workflow_args={"target": cli_args.target, "html_target": cli_args.html_target},
                workspaces=ws,
                runtime={
                    "agent": rt.agent,
                    "parallel": rt.parallel,
                    "pipeline": rt.pipeline,
                    "phase": rt.phase,
                    "log": rt.log,
                    "args": {},
                    "WORKSPACES": ws,
                },
                write_gate_status=bool(cli_args.write_gate_status),
            )
        )
        if cli_args.report:
            report_path = Path(cli_args.report)
            report_path.parent.mkdir(parents=True, exist_ok=True)
            report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(json.dumps(report, indent=2, ensure_ascii=False))
        return 0 if report["passed"] else 1

    print(
        json.dumps(
            {
                "mode": "run_workflow_module",
                "entrypoint": "run_parallel_inquisition(args, WORKSPACES)",
                "hint": "Use --dry-run or --self-test for standalone CLI execution, or invoke via Antigravity run_workflow.",
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
