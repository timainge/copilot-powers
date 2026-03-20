"""
KB MCP Server — BM25-based knowledge base retrieval for Copilot agent mode.

Provides structured access to the /kb/ directory via MCP stdio protocol.
~150 lines of Python, no agent frameworks, just mcp + rank_bm25.

Tools:
  - kb_search: BM25 search over KB summaries
  - get_file_summary: Direct read of a file's KB entry
  - get_module_summary: Direct read of a module's rolled-up summary
  - get_domain_concepts: Inverted index lookup for domain concepts
  - list_debt_signals: Aggregated tech debt flags
  - get_business_rules: Business rules for a module

Setup:
  pip install mcp rank_bm25
"""

import json
import os
from pathlib import Path
from typing import Any

from mcp.server.fastmcp import FastMCP
from rank_bm25 import BM25Okapi

# --- Configuration ---

KB_ROOT = Path(os.environ.get("KB_ROOT", "kb"))

# --- Server ---

mcp = FastMCP("kb", instructions="Knowledge base retrieval server for codebase intelligence.")

# --- BM25 Index (built at startup) ---

_bm25_index: BM25Okapi | None = None
_bm25_docs: list[dict[str, Any]] = []


def _build_index() -> None:
    """Build BM25 index from all KB JSON files at startup."""
    global _bm25_index, _bm25_docs
    _bm25_docs = []
    corpus: list[list[str]] = []

    index_dir = KB_ROOT / "index"
    if not index_dir.exists():
        return

    for json_file in index_dir.rglob("*.json"):
        if json_file.name.startswith("."):
            continue
        try:
            data = json.loads(json_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            continue

        # Build searchable text from key fields
        searchable_parts = [
            data.get("purpose", ""),
            data.get("module", ""),
            data.get("file", ""),
            data.get("subsystem", ""),
        ]
        # Add domain concepts
        concepts = data.get("domain_concepts", [])
        if isinstance(concepts, list):
            searchable_parts.extend(concepts)
        # Add public surface names
        for item in data.get("public_surface", []):
            if isinstance(item, dict):
                searchable_parts.append(item.get("name", ""))
                searchable_parts.append(item.get("description", ""))

        text = " ".join(str(p) for p in searchable_parts if p)
        tokens = text.lower().split()

        if tokens:
            corpus.append(tokens)
            _bm25_docs.append({
                "path": str(json_file.relative_to(KB_ROOT)),
                "data": data,
            })

    if corpus:
        _bm25_index = BM25Okapi(corpus)


# --- Tools ---


@mcp.tool()
def kb_search(query: str, scope: str = "", top_k: int = 10) -> list[dict[str, Any]]:
    """Search the knowledge base using BM25.

    Args:
        query: Search query (natural language or keywords).
        scope: Optional scope filter — 'index', 'domain', 'architecture'. Empty = all.
        top_k: Number of results to return (default 10).
    """
    if _bm25_index is None or not _bm25_docs:
        return [{"error": "KB index is empty. Run codebase exploration first."}]

    tokens = query.lower().split()
    scores = _bm25_index.get_scores(tokens)

    results = []
    for i, score in enumerate(scores):
        if score > 0:
            doc = _bm25_docs[i]
            if scope and not doc["path"].startswith(scope):
                continue
            results.append({
                "path": doc["path"],
                "score": round(float(score), 3),
                "purpose": doc["data"].get("purpose", ""),
                "domain_concepts": doc["data"].get("domain_concepts", []),
            })

    results.sort(key=lambda x: x["score"], reverse=True)
    return results[:top_k]


@mcp.tool()
def get_file_summary(file_path: str) -> dict[str, Any]:
    """Get the KB summary for a specific source file.

    Args:
        file_path: Relative path to the source file (e.g., 'src/Services/PaymentProcessor.cs').
    """
    kb_path = KB_ROOT / "index" / (file_path + ".json")
    if not kb_path.exists():
        return {"error": f"No KB entry found for {file_path}"}
    try:
        return json.loads(kb_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as e:
        return {"error": str(e)}


@mcp.tool()
def get_module_summary(module_path: str) -> dict[str, Any]:
    """Get the rolled-up summary for a module (directory).

    Args:
        module_path: Relative path to the module directory (e.g., 'src/Services').
    """
    kb_path = KB_ROOT / "index" / module_path / "_dir.json"
    if not kb_path.exists():
        return {"error": f"No module summary found for {module_path}"}
    try:
        return json.loads(kb_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as e:
        return {"error": str(e)}


@mcp.tool()
def get_domain_concepts(concept: str) -> list[dict[str, Any]]:
    """Find all files and modules that reference a specific domain concept.

    Args:
        concept: Domain concept to search for (case-insensitive).
    """
    concept_lower = concept.lower()
    results = []

    for doc in _bm25_docs:
        concepts = doc["data"].get("domain_concepts", [])
        if any(concept_lower in c.lower() for c in concepts):
            results.append({
                "path": doc["path"],
                "file": doc["data"].get("file", doc["data"].get("module", "")),
                "purpose": doc["data"].get("purpose", ""),
                "matching_concepts": [c for c in concepts if concept_lower in c.lower()],
            })

    return results


@mcp.tool()
def list_debt_signals(severity: str = "") -> list[dict[str, Any]]:
    """List tech debt signals across the codebase.

    Args:
        severity: Filter by severity — 'low', 'medium', 'high'. Empty = all.
    """
    results = []

    for doc in _bm25_docs:
        signals = doc["data"].get("tech_debt_signals", [])
        for signal in signals:
            if isinstance(signal, dict):
                if severity and signal.get("severity", "") != severity:
                    continue
                results.append({
                    "file": doc["data"].get("file", doc["path"]),
                    **signal,
                })

    # Sort by severity (high first)
    severity_order = {"high": 0, "medium": 1, "low": 2}
    results.sort(key=lambda x: severity_order.get(x.get("severity", "low"), 3))
    return results


@mcp.tool()
def get_business_rules(module: str = "") -> dict[str, Any]:
    """Get extracted business rules for a module.

    Args:
        module: Module name (reads from /kb/domain/{module}.json). Empty = list available modules.
    """
    domain_dir = KB_ROOT / "domain"

    if not module:
        available = [f.stem for f in domain_dir.glob("*.json") if not f.name.startswith(".")]
        return {"available_modules": available}

    domain_path = domain_dir / f"{module}.json"
    if not domain_path.exists():
        return {"error": f"No domain extraction found for module '{module}'"}
    try:
        return json.loads(domain_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as e:
        return {"error": str(e)}


# --- Startup ---

_build_index()

if __name__ == "__main__":
    mcp.run(transport="stdio")
