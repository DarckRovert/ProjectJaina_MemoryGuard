import os
import re
import sys

def strip_lua_comments(code):
    code = re.sub(r'--\[\[.*?\]\]', '', code, flags=re.DOTALL)
    code = re.sub(r'--.*$', '', code, flags=re.MULTILINE)
    return code

def test_addon_sanity():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    print(f"Testing addon directory: {base_dir}")

    # 1. Verify required documentation files
    required_docs = [
        "README.md", "CHANGELOG.md", "LICENSE", "NOTICE.md",
        "API.md", "AGENTS.md", "INSTALL.md", "SECURITY.md",
        "ECOSYSTEM_REGISTRY.md", ".gitignore", ".gitattributes"
    ]
    for doc in required_docs:
        path = os.path.join(base_dir, doc)
        assert os.path.exists(path), f"Missing required file: {doc}"
    print("[PASS] All required repository documentation files exist.")

    # 2. Check TOC integrity
    toc_path = os.path.join(base_dir, "ProjectJaina_MemoryGuard.toc")
    assert os.path.exists(toc_path), "ProjectJaina_MemoryGuard.toc missing!"
    with open(toc_path, "r", encoding="utf-8", errors="ignore") as tf:
        toc_content = tf.read()
    assert "SavedVariables: ProjectJaina_MemoryGuard_DB" in toc_content, "SavedVariables missing in TOC"
    assert "ProjectJaina_MemoryGuard.lua" in toc_content, "Lua entry missing in TOC"

    # 3. Check Lua files for forbidden Retail APIs and syntax
    for root, dirs, files in os.walk(base_dir):
        if ".git" in root or "Tests" in root or "Libs" in root:
            continue
        for f in files:
            if f.endswith(".lua"):
                file_path = os.path.join(root, f)
                with open(file_path, "r", encoding="utf-8", errors="ignore") as lf:
                    raw_content = lf.read()
                    content = strip_lua_comments(raw_content)
                    assert not re.search(r'\bSetColorTexture\s*\(', content), f"Forbidden SetColorTexture found in {f}"
                    assert not re.search(r'\bC_Timer\.After\s*\(', content), f"Forbidden C_Timer.After found in {f}"
                    assert not re.search(r'(?<![:\.\w])IsInRaid\s*\(', content), f"Forbidden global IsInRaid found in {f}"
                    assert "ProjectJaina_MemoryGuard_DB" in raw_content, "SavedVariables DB not referenced in Lua"
                    assert "_G.ProjectJaina_MemoryGuard_Purge" in raw_content, "Public Purge API not exported"
    print("[PASS] All Lua files adhere to 3.3.5a engine rules and L9 API contracts.")

    print("\n>>> ALL ProjectJaina_MemoryGuard SANITY CHECKS PASSED 100% <<<")

if __name__ == "__main__":
    test_addon_sanity()
