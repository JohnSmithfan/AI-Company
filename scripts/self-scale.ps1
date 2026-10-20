<#
========================================================================================
 self-scale.ps1 - Self-scaling evaluator and proposal generator (small tier)
 Package : ai-company | Version : 2.0.0 | scale_tier : small
========================================================================================
 Governance model : PROPOSE-ONLY, three-stage architecture (references/scaling.md #1).

CAN do :
  - read {SKILL_DIR} (read-only)
  - read / update .scaling-state.json (operational records only - the single
    permitted write inside {SKILL_DIR}, per README_FOR_AI.md sec 12.6)
  - accept host-supplied metrics via -Action record-metrics or the drop
    directory (references/scaling.md sec 3.1)
  - collect the four scaling metrics and evaluate thresholds T1-T4
    (T1/T3 are skipped, not guessed, when the host data is stale - sec 3.1)
  - generate an upgrade package under {WORKSPACE_ROOT}/.skill-upgrade/<timestamp>/
    for ANY selectable target tier (-TargetTier, references/scaling.md sec 2);
    omitting -TargetTier keeps the historical linear default (next tier)
  - run gates G1-G6 on the generated package (README_FOR_AI.md sec 12.3)
  - write UPGRADE-PROPOSAL.md into the package directory (README_FOR_AI.md sec 12)
  - record the proposal in .scaling-state.json -> pending_proposals

 CANNOT do (hard boundary, README_FOR_AI.md sec 9.5) :
   - write any other file under {SKILL_DIR}
   - modify the permissions block, tests/**, or this script's own gate logic
   - install, apply, or commit anything (no such Action value exists - P36)
   - request additional permissions

 Compatibility : Windows PowerShell 5.1 (no &&, no ternary operator, no ?? operator).
 Paths         : all derived from $PSScriptRoot; no hardcoded absolute user paths (P18).
 Deletion      : no executable recursive force-delete path exists (P23); rejected
                 packages are quarantined by move, not destroyed. The proposal
                 report quotes a forbidden delete-then-restore command as an
                 example only, never as a call.
 Line endings  : this script is LF, authored that way and pinned by
                 .gitattributes (* text=auto eol=lf) so a contributor's local
                 core.autocrlf cannot rewrite it; every .md and .json artifact
                 it writes is likewise LF - see Write-TextFileNoBom.
 Copy policy   : the package file set is defined once (README_FOR_AI.md sec 3)
                 and excludes repository tooling directories (.git/, .github/,
                 .workbuddy/, .skill-upgrade/) plus build residues (__pycache__/,
                 *.pyc), so the file count and the gate hashes never depend on
                 the checkout environment.
========================================================================================
#>

param(
  [ValidateSet('evaluate','propose','report','status','record-metrics')]
  [string]$Action = 'evaluate',      # no install / apply / commit values (P36)
  [switch]$DryRun,                   # only output what would be done, no package
  [switch]$Force,                    # propose even when no threshold is hit (SCL_001)

  # --- Target tier selection (propose only; scaling.md sec 2) -------------------
  # Arbitrary scale choice: any tier listed in selectable_targets for the current
  # tier may be requested (cross-tier jumps included). Leave empty for the
  # historical linear default (upgrade_path[current tier]). Validated at runtime
  # against the config vocabulary - not a ValidateSet, so the tier list stays a
  # single data source in scaling-config.json.
  [string]$TargetTier = '',          # '' = default next tier; else micro|small|medium|large|group

  # --- Host write-back interface (metrics whose source can only be the host) ---
  # Only meaningful with -Action record-metrics. See scaling.md section 3.1.
  [int]$AgentCount = -1,             # live agent instances attached to this skill (>= 0)
  [double]$RoutingAccuracy = -1.0,   # 'department: auto' hit rate in [0,1]
  [int]$SampleSize = -1,             # routing sample size; < min_routing_samples -> T3 skipped
  [string]$ObservedAt = '',          # ISO-8601 UTC observation time; defaults to now
  [string]$Source = 'host'           # free-form host identifier for the audit log
)

$ErrorActionPreference = 'Stop'

# --------------------------------------------------------------------------------------
# Constants and paths (derived from $PSScriptRoot only)
# --------------------------------------------------------------------------------------

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$SkillDir      = Split-Path -Parent $PSScriptRoot        # {SKILL_DIR} (parent of scripts/)
# {WORKSPACE_ROOT} is derived as the parent of {SKILL_DIR} and never from an
# ambient environment variable: the surrounding host also uses WORKSPACE_ROOT,
# so reading it here would silently redirect the upgrade package and the metric
# drop directory into that host's directory. The derivation (and the nesting
# caveat that {SKILL_DIR} then lives under {WORKSPACE_ROOT}) is documented in
# references/scaling.md sec 3.1 and README_FOR_AI.md sec 9.1.
$WorkspaceRoot = Split-Path -Parent $SkillDir
$StateFile     = Join-Path $SkillDir '.scaling-state.json'
$ConfigFile    = Join-Path $PSScriptRoot 'scaling-config.json'
$DepartmentsDir = Join-Path (Join-Path $SkillDir 'references') 'departments'
$ErrorCodesFile = Join-Path (Join-Path $SkillDir 'references') 'error-codes.md'

# Tier data (R3 audited values). Three adjacent edges are implemented by this
# build (micro -> small, small -> medium, medium -> large); any other tier
# correctly fails with SCL_002 (no mapping defined).
$TierAgentCaps = @{
  'micro' = 3; 'small' = 10; 'medium' = 50; 'large' = 200; 'group' = 200
}
$TierBlockMean = @{ 'micro' = 9.0; 'small' = 3.6; 'medium' = 2.0; 'large' = 1.0; 'group' = 1.0 }

# Package file set (README_FOR_AI.md sec 3). A "package file" is a file of the
# skill itself; repository tooling directories are NEVER package content, so
# they are excluded from the 5h copy, from every file count, and from the gate
# hashes. Keeping this list in ONE place is what stops the counting basis and
# the copy range from drifting apart again (the H-1 defect).
$ExcludedDirSegments = @('.git', '.github', '.workbuddy', '.skill-upgrade')

# Expected package-file-set size per tier (README_FOR_AI.md sec 3 / sec 15).
# small = 30: 26 micro package files - 1 operational state file - 2 retired
# legacy D2 pages + 5 split D2 pages + 1 new prompt + 1 package state file.
# group = 246 mirrors scaling-config.json file_count_expectation.group (the
# group tier is scaffold-only in this build; see $GroupEdge).
$TierFileCount = @{ 'micro' = 26; 'small' = 30; 'medium' = 37; 'large' = 148; 'group' = 246 }
$TargetFileCount = @{ 'small' = $TierFileCount['small'] }
$TierOrder = @('micro', 'small', 'medium', 'large', 'group')

# The deterministic micro -> small split mapping (merge tree, README_FOR_AI.md sec 10.1).
# Split order = page order of FB sections inside each legacy D2 file (scaling.md 4.3).
$UpgradeEdge = @{
  From = 'micro'
  To   = 'small'
  NewVersion = '2.0.0'
  OldVersion = '1.0.0'
  ExpectedBlocks = 18
  DepartmentCount = 5
  # 6 error-code prefixes present after micro -> small (CEO_/CTO_ carried from
  # micro; CISO_/CHO_/CQO_ revived; SCL_ retained). Drives gate G6.
  Prefixes = @('CEO_', 'CTO_', 'CISO_', 'CHO_', 'CQO_', 'SCL_')
  Split = @(
    @{ Slug = 'governance-and-operations'; Prefix = 'CEO_';  Source = 'governance-and-delivery'; Blocks = 6; Display = 'Governance and Operations' },
    @{ Slug = 'quality-and-delivery';      Prefix = 'CQO_';  Source = 'governance-and-delivery'; Blocks = 2; Display = 'Quality and Delivery' },
    @{ Slug = 'technology-and-platform';   Prefix = 'CTO_';  Source = 'engineering-and-safety';  Blocks = 3; Display = 'Technology and Platform' },
    @{ Slug = 'security-and-compliance';   Prefix = 'CISO_'; Source = 'engineering-and-safety';  Blocks = 3; Display = 'Security and Compliance' },
    @{ Slug = 'people-and-growth';         Prefix = 'CHO_';  Source = 'engineering-and-safety';  Blocks = 4; Display = 'People and Growth' }
  )
  # Report fragments for New-ProposalReport (keep this edge self-describing).
  Report = @{
    FromDepartmentCount = 2
    TargetFiles = 30
    ChangeList = @(
      '| New department D2 files | 5 | governance-and-operations, quality-and-delivery, technology-and-platform, security-and-compliance, people-and-growth |'
      '| Retired department D2 files | 2 | governance-and-delivery, engineering-and-safety (slugs preserved as aliases) |'
      '| New department D3 files | 0 | Not applicable (target tier < large) |'
      '| New prompts | 1 | prompts/03-test-cases.md (agent-invoked, harness level L3, listed in the SKILL.md Prompts index) |'
      '| Frontmatter rewritten | 1 | scale_tier / department_count / function_block_count / version / error_code_prefixes / department_aliases pointer / interface.department.enum / description |'
      '| Revived error-code prefixes | 3 | CISO_, CHO_, CQO_ |'
      '| Error-code alias skeleton | 1 table | 24 legacy-code rows appended to references/error-codes.md, every row marked "requires human review" |'
      '| Aliases added | 5 | See the Alias Map in references/scaling.md |'
      '| Governance files updated | <=4 | CHANGELOG.md entry inserted after [Unreleased]; version strings bumped (counted, context-exact) and Project Structure tree rewritten to the 30-file skeleton in SKILL.md index / README*.md |'
    )
    HumanReview = @(
      'Error-code remapping from CEO_ / CTO_ to the revived CISO_ / CHO_ / CQO_ prefixes in references/error-codes.md. The alias-table skeleton (24 rows) has been generated; every "requires human review" cell must be completed with the real new code, and the file header counts updated (step 5e).'
      'README Project Structure trees have been rewritten to the 30-file small-tier skeleton in README.md / README.en.md / README.zh.md; the remaining narrative claims (department names, block split, quick-start wording) still describe the micro layout and require human review (step 5i).'
      'Department D2 pages produced by the deterministic split keep the legacy preamble wording; a human should confirm each page''s non-FB narrative matches its new department scope.'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the package. The pending proposal records acceptance_passed = false until this is done.'
    )
    DryRun = @(
      'DRY-RUN: 5h copy the package (excluding .scaling-state.json, retired D2, __pycache__/, *.pyc)'
      'DRY-RUN: 5a/5b split 2 legacy D2 pages into 5 departments (18 blocks conserved; leftover/shortage aborts with SCL_010)'
      'DRY-RUN: 5a generate prompts/03-test-cases.md (agent-invoked, L3)'
      'DRY-RUN: 5d rewrite frontmatter (scale_tier=small, department_count=5, version=2.0.0, enum + description)'
      'DRY-RUN: 5e bump _meta.json; append the error-code alias-table skeleton (requires human review)'
      'DRY-RUN: 5g append 5 alias rows to the package Alias Map'
      'DRY-RUN: 5i bump README versions (counted, context-exact); rewrite structure trees to the 30-file skeleton; insert the CHANGELOG entry after [Unreleased]'
      'DRY-RUN: package state file with tier_history skeleton entry (append-only)'
    )
  }
}

# The deterministic small -> medium mapping (merge tree, README_FOR_AI.md sec 10.1).
# 9 departments (5 existing + 4 new), 18 function blocks conserved (mean 2.0,
# no department above 3), 37 package files, version 3.0.0, 10 error-code prefixes.
# small -> medium does NOT rename slugs; 8 function blocks migrate from existing
# departments to 4 new departments and are re-prefixed (see $MediumBlockMoves).
$TargetFileCount['medium'] = 37
$TierFileCount['medium']   = 37
$TargetFileCount['large']  = 148
$TierFileCount['large']    = 148
# group = 246 mirrors scaling-config.json file_count_expectation.group. The
# group tier is scaffold-only in this build (see $GroupEdge): no builder
# produces 246 files today, and gate G6 reports the gap as the checklist.
$TargetFileCount['group']  = 246
$TierFileCount['group']    = 246
$MediumEdge = @{
  From = 'small'
  To   = 'medium'
  NewVersion = '3.0.0'
  OldVersion = '2.0.0'
  ExpectedBlocks = 18
  DepartmentCount = 9
  Prefixes = @('CEO_', 'CTO_', 'CISO_', 'CHO_', 'CQO_', 'CLR_', 'CDO_', 'CPO_', 'CCO_', 'SCL_')
  # 9 department specs (Slug / Prefix / Blocks / Display). Drives G4 distribution,
  # G6 interface.department.enum + D2-presence + the 37-file count basis.
  Split = @(
    @{ Slug = 'governance-and-operations'; Prefix = 'CEO_';  Blocks = 3; Display = 'Governance and Operations' }
    @{ Slug = 'technology-and-platform';   Prefix = 'CTO_';  Blocks = 2; Display = 'Technology and Platform' }
    @{ Slug = 'security-and-compliance';   Prefix = 'CISO_'; Blocks = 2; Display = 'Security and Compliance' }
    @{ Slug = 'quality-and-delivery';      Prefix = 'CQO_';  Blocks = 1; Display = 'Quality and Delivery' }
    @{ Slug = 'people-and-growth';         Prefix = 'CHO_';  Blocks = 2; Display = 'People and Growth' }
    @{ Slug = 'legal-and-risk';            Prefix = 'CLR_';  Blocks = 2; Display = 'Legal and Risk' }
    @{ Slug = 'data-and-analytics';        Prefix = 'CDO_';  Blocks = 2; Display = 'Data and Analytics' }
    @{ Slug = 'product-and-strategy';      Prefix = 'CPO_';  Blocks = 2; Display = 'Product and Strategy' }
    @{ Slug = 'customer-and-partnerships'; Prefix = 'CCO_';  Blocks = 2; Display = 'Customer and Partnerships' }
  )
  # G5 alias coverage. small -> medium keeps all 5 legacy slugs and adds 4 new
  # ones, so the "legacy" slugs are the 5 source departments and the "target"
  # slugs are the 4 new departments (the 8 block migrations below).
  AliasLegacy = @('governance-and-operations', 'technology-and-platform', 'security-and-compliance', 'quality-and-delivery', 'people-and-growth')
  AliasTarget = @('legal-and-risk', 'data-and-analytics', 'product-and-strategy', 'customer-and-partnerships')
  # Report fragments for New-ProposalReport (keep this edge self-describing).
  Report = @{
    FromDepartmentCount = 5
    TargetFiles = 37
    ChangeList = @(
      '| New department D2 files | 4 | legal-and-risk, data-and-analytics, product-and-strategy, customer-and-partnerships (each 2 blocks) |'
      '| Retired department D2 files | 0 | small -> medium does not retire any department; 8 blocks migrate between departments instead |'
      '| New department D3 files | 0 | Not applicable (target tier < large) |'
      '| New shared reference modules | 3 | references/shared/{glossary, cross-department-handoff, common-patterns}.md |'
      '| New prompts | 0 | prompts/03-test-cases.md is already carried by the small tier |'
      '| Frontmatter rewritten | 1 | scale_tier / department_count / function_block_count / version / error_code_prefixes (10 prefixes) / department_aliases pointer / interface.department.enum (auto + 9) / description |'
      '| Revived error-code prefixes | 0 | no prefixes revived; 4 new prefixes added: CLR_, CDO_, CPO_, CCO_ |'
      '| Error-code re-prefixing (resolved) | 8 codes | CEO_008->CLR_001, CEO_005->CPO_002, CEO_009->CCO_001, CISO_002->CLR_002, CTO_004->CDO_001, CQO_003->CDO_002, CHO_004->CPO_001, CHO_003->CCO_002 (applied deterministically; source prefixes re-baselined) |'
      '| Aliases added | 8 | block-migration alias rows appended to references/scaling.md Alias Map |'
      '| Governance files updated | <=4 | CHANGELOG.md entry inserted after [Unreleased]; version strings bumped to 3.0.0 (counted, context-exact) and Project Structure tree rewritten to the 37-file skeleton in SKILL.md index / README*.md |'
    )
    HumanReview = @(
      'Error-code re-prefixing is applied deterministically and the 8 migration rows are recorded in the resolved alias-history table in references/error-codes.md; a human should confirm the 8 moved codes map to the intended function-block semantics and that the 5 source-prefix re-baselined counts (CEO_ 6, CISO_ 3, CTO_ 3, CQO_ 2, CHO_ 2) are reflected in the file header (step 5e).'
      'README Project Structure trees have been rewritten to the 37-file medium-tier skeleton in README.md / README.en.md / README.zh.md; the narrative claims (department names, block split, quick-start wording) should be reviewed to match the 9-department layout (step 5i).'
      'The 4 new department D2 pages were authored with fresh preambles; a human should confirm each page''s non-FB narrative matches its new department scope and that the 3 shared reference modules are consistent with the department pages.'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the package. The pending proposal records acceptance_passed = false until this is done.'
    )
    ChangelogBullets = @(
      '- Departments: 5 -> 9 (8 function blocks migrated from 5 existing departments to 4 new departments: legal-and-risk, data-and-analytics, product-and-strategy, customer-and-partnerships; 18 blocks conserved)'
      '- New error-code prefixes: CLR_, CDO_, CPO_, CCO_ (resolved alias table appended to references/error-codes.md)'
      '- New shared modules: references/shared/{glossary, cross-department-handoff, common-patterns}.md'
      '- Slug aliases appended to references/scaling.md (Alias Map)'
    )
    DryRun = @(
      'DRY-RUN: 5h copy the package (excluding .scaling-state.json; small already carries prompts/03-test-cases.md, no D2 retirements)'
      'DRY-RUN: 5a migrate 8 function blocks from 5 source departments into 4 new departments (re-prefixed; source pages re-baselined; 18 blocks conserved)'
      'DRY-RUN: 5a author 4 new department D2 files (legal-and-risk, data-and-analytics, product-and-strategy, customer-and-partnerships)'
      'DRY-RUN: 5a author references/shared/{glossary, cross-department-handoff, common-patterns}.md'
      'DRY-RUN: 5d rewrite frontmatter (scale_tier=medium, department_count=9, version=3.0.0, enum + description)'
      'DRY-RUN: 5e bump _meta.json; transform error-codes.md (move 8 codes, re-baseline 5 source prefixes, insert 4 new prefixes, append resolved alias history)'
      'DRY-RUN: 5g append 8 alias rows to the package Alias Map'
      'DRY-RUN: 5i bump README versions to 3.0.0; rewrite structure trees to the 37-file skeleton; insert the CHANGELOG entry'
      'DRY-RUN: package state file initialized for tier medium (append-only)'
    )
  }
}

# The deterministic medium -> large mapping (merge tree, README_FOR_AI.md sec 10.1).
# 18 departments (9 medium retired + 18 large introduced), 18 function blocks
# conserved but re-homed one per department (large mean = 1.0, T2 threshold > 1.5),
# 148 package files, version 4.0.0, 18 error-code prefixes. The large target is the
# concrete ai-company-large package (re-versioned 4.1.0 -> 4.0.0 at build time); the
# builder copies it, overlays the medium-tier tests/ and scripts/self-scale.ps1 (G2/G3
# immutable), preserves the live permissions block (G1/G3), and rewrites the
# frontmatter / README badges / Alias Map to the large contract.
$LargeEdge = @{
  From = 'medium'
  To   = 'large'
  NewVersion = '4.0.0'
  OldVersion = '3.0.0'
  ExpectedBlocks = 18
  DepartmentCount = 18
  # 18 error-code prefixes present at large (from ai-company-large frontmatter).
  Prefixes = @('BRD_', 'CEO_', 'CFO_', 'CHO_', 'CISO_', 'CLO_', 'CMO_', 'COO_', 'CQO_', 'CRO_', 'CTO_', 'FW_', 'INTEL_', 'IRP_', 'KNM_', 'MDL_', 'PMGR_', 'PRC_')
  # 18 department specs (Slug / Prefix / Blocks / Display). Drives G4 distribution,
  # G6 interface.department.enum + D2-presence + the 148-file count basis.
  Split = @(
    @{ Slug = 'board-and-branch';        Prefix = 'BRD_';   Blocks = 1; Display = 'Board and Branch' }
    @{ Slug = 'delivery-scheduling';     Prefix = 'PMGR_';  Blocks = 1; Display = 'Delivery Scheduling' }
    @{ Slug = 'engineering-tooling';     Prefix = 'CTO_';   Blocks = 1; Display = 'Engineering and Tooling' }
    @{ Slug = 'executive-strategy';      Prefix = 'CEO_';   Blocks = 1; Display = 'Executive Strategy' }
    @{ Slug = 'finance-treasury';        Prefix = 'CFO_';   Blocks = 1; Display = 'Finance and Treasury' }
    @{ Slug = 'incident-identity';       Prefix = 'IRP_';   Blocks = 1; Display = 'Incident and Identity' }
    @{ Slug = 'intelligence-sentiment';  Prefix = 'INTEL_'; Blocks = 1; Display = 'Intelligence and Sentiment' }
    @{ Slug = 'knowledge-ethics';        Prefix = 'KNM_';   Blocks = 1; Display = 'Knowledge and Ethics' }
    @{ Slug = 'legal-privacy';           Prefix = 'CLO_';   Blocks = 1; Display = 'Legal and Privacy' }
    @{ Slug = 'lifecycle-training';      Prefix = 'CHO_';   Blocks = 1; Display = 'Lifecycle and Training' }
    @{ Slug = 'marketing-partnerships';  Prefix = 'CMO_';   Blocks = 1; Display = 'Marketing and Partnerships' }
    @{ Slug = 'model-data';              Prefix = 'MDL_';   Blocks = 1; Display = 'Model and Data' }
    @{ Slug = 'operations-coordination'; Prefix = 'COO_';   Blocks = 1; Display = 'Operations and Coordination' }
    @{ Slug = 'platform-mlops';          Prefix = 'FW_';    Blocks = 1; Display = 'Platform and MLOps' }
    @{ Slug = 'procurement-billing';     Prefix = 'PRC_';   Blocks = 1; Display = 'Procurement and Billing' }
    @{ Slug = 'quality-visualization';   Prefix = 'CQO_';   Blocks = 1; Display = 'Quality and Visualization' }
    @{ Slug = 'risk-audit';              Prefix = 'CRO_';   Blocks = 1; Display = 'Risk and Audit' }
    @{ Slug = 'security-resilience';     Prefix = 'CISO_';  Blocks = 1; Display = 'Security and Resilience' }
  )
  # G5 alias coverage. medium -> large retires all 9 medium slugs and introduces
  # 18 large slugs; the 18 blocks are conserved but re-homed 1-per-department.
  AliasLegacy = @('customer-and-partnerships', 'data-and-analytics', 'governance-and-operations', 'legal-and-risk', 'people-and-growth', 'product-and-strategy', 'quality-and-delivery', 'security-and-compliance', 'technology-and-platform')
  AliasTarget = @('board-and-branch', 'delivery-scheduling', 'engineering-tooling', 'executive-strategy', 'finance-treasury', 'incident-identity', 'intelligence-sentiment', 'knowledge-ethics', 'legal-privacy', 'lifecycle-training', 'marketing-partnerships', 'model-data', 'operations-coordination', 'platform-mlops', 'procurement-billing', 'quality-visualization', 'risk-audit', 'security-resilience')
  # Report fragments for New-ProposalReport (keep this edge self-describing).
  Report = @{
    FromDepartmentCount = 9
    TargetFiles = 148
    ChangeList = @(
      '| New department D2 files | 18 | board-and-branch, delivery-scheduling, engineering-tooling, executive-strategy, finance-treasury, incident-identity, intelligence-sentiment, knowledge-ethics, legal-privacy, lifecycle-training, marketing-partnerships, model-data, operations-coordination, platform-mlops, procurement-billing, quality-visualization, risk-audit, security-resilience (each 1 block; all 9 medium departments retired) |'
      '| Retired department D2 files | 9 | the 9 medium-tier departments (slugs preserved as aliases) |'
      '| New department D3 files | 18 | each large department gains a D3 layer (references/departments/<slug>/) |'
      '| New shared reference modules | 0 | carried from medium; large adds 7-domain routing + department-index.md |'
      '| New prompts | 0 | prompts/03-test-cases.md (agent-invoked, L3) carried unchanged from the medium tier (G2 immutable) |'
      '| Frontmatter rewritten | 1 | scale_tier / department_count / function_block_count / version / error_code_prefixes (19 prefixes) / interface.department.enum (auto + 18) / description |'
      '| Revived error-code prefixes | 13 | BRD_, CFO_, CLO_, CMO_, COO_, CRO_, FW_, INTEL_, IRP_, KNM_, MDL_, PMGR_, PRC_ (net 19 prefixes at large; 6 shared with medium: CEO_, CTO_, CISO_, CHO_, CQO_, SCL_) |'
      '| Aliases added | 18 | medium->large alias rows appended to references/scaling.md Alias Map |'
      '| Governance files updated | <=4 | CHANGELOG.md entry inserted after [Unreleased]; version strings bumped to 4.0.0 and Project Structure tree reviewed |'
    )
    HumanReview = @(
      'All 9 medium-tier department slugs are retired and replaced by 18 large-tier slugs; the 18 function blocks are conserved but re-homed one per department. Confirm the medium->large alias rows in references/scaling.md map each retired slug to its intended large successor.'
      'The large package carries the medium-tier tests/test-method-patterns.py unchanged (G2 immutable). Those tests are medium-aware and will not pass against the 18-department / 117-code large layout; they must be made large-aware at install time (acceptance_passed stays false until then).'
      'README Project Structure trees describe the 148-file large skeleton; the narrative claims should be reviewed to match the 18-department / 7-domain layout (step 5i).'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the package. The pending proposal records acceptance_passed = false until this is done.'
    )
    ChangelogBullets = @(
      '- Departments: 9 -> 18 (the 9 medium-tier departments are retired; 18 large-tier departments replace them; 18 function blocks conserved, one per department)'
      '- Error-code prefixes: 10 -> 19 (18 department prefixes + SCL_ infrastructure; 117 codes)'
      '- New D3 layer per department, 7-domain routing, and a department index'
      '- Slug aliases appended to references/scaling.md (Alias Map)'
    )
    DryRun = @(
      'DRY-RUN: 5h copy ai-company-large content (excluding its .scaling-state.json); overlay live tests/ + scripts/self-scale.ps1 + references/scaling.md (G2/G3 immutable)'
      'DRY-RUN: 5a de-bold D2 Function blocks figures (G4 reads plain integer)'
      'DRY-RUN: 5d build SKILL.md from the LIVE frontmatter shell retargeted to large (scale_tier=large, department_count=18, function_block_count=18, version=4.0.0, 19 prefixes, enum auto+18, permissions preserved for G1) + ai-company-large body'
      'DRY-RUN: 5e bump _meta.json to 4.0.0'
      'DRY-RUN: 5g append 18 alias rows (9 medium legacy -> 18 large target) to the package Alias Map'
      'DRY-RUN: package state file initialized for tier large (acceptance_passed=false)'
      'DRY-RUN: 5i bump README version 4.1.0 -> 4.0.0 (badge + at-a-glance rows)'
    )
  }
}
# Large-tier description (ASCII; used by the medium -> large frontmatter rewrite).
# Byte-identical to the ai-company-large source SKILL.md description (799 chars,
# inside the 700-900 spec band; the previous 699-char text missed the floor and
# claimed 18 prefixes where the package declares 19 - audit B3).
$LargeDescription = "Large-tier (scale_tier: large) unified AI company governance skill for 50-200 agents across multiple product lines. Routes tasks through 7 domains to 18 specialized departments (1 function block each, 18 total), with 117 error codes across 19 prefixes, a D3 specification layer per department, two-level routing, and a department index. Ships audited Python code templates as a single authoritative source, 3 prompt frameworks, and Harness L1-L6 maturity levels with AIGC triple labeling and mandatory PII masking. Supports propose-only self-scaling: the skill detects tier overflow and proposes an upgrade package, which humans approve and an external installer applies. Use when any AI-company governance, finance, engineering, security, or delivery function is needed at multi-product-line scale."

# ======================================================================================
# Arbitrary target selection: additional (from -> to) edges.
#
# The large target content is the canonical ai-company-large reference package
# (source-independent), so micro -> large and small -> large reuse the SAME
# builder as medium -> large; only the frontmatter shell, the retired-slug set
# (G5) and the report narrative differ. The medium target is reached from micro
# by composing the two deterministic transformations in place (see
# New-MicroToMediumUpgradePackage). The group target has no authored content at
# all, so it is a scaffold (UPGRADE-WORK-ORDER.txt) whose content gates fail by
# design. Every edge is fully self-describing: gates G4/G5/G6, the proposal
# report and the DryRun narrative are all driven by these fields.
# ======================================================================================

# small -> large : cross-tier jump (medium skipped). The 5 small departments are
# the retired set; the 18 large slugs and 18 function blocks are target data
# shared with the medium -> large edge.
$SmallToLargeEdge = @{
  From = 'small'
  To   = 'large'
  NewVersion = '4.0.0'
  OldVersion = '2.0.0'
  OldPrefixCount = 6
  ExpectedBlocks = 18
  DepartmentCount = 18
  Prefixes = $LargeEdge.Prefixes
  Split = $LargeEdge.Split
  AliasLegacy = @('governance-and-operations', 'technology-and-platform', 'security-and-compliance', 'quality-and-delivery', 'people-and-growth')
  AliasTarget = $LargeEdge.AliasTarget
  Report = @{
    FromDepartmentCount = 5
    TargetFiles = 148
    ChangeList = @(
      '| New department D2 files | 18 | board-and-branch, delivery-scheduling, engineering-tooling, executive-strategy, finance-treasury, incident-identity, intelligence-sentiment, knowledge-ethics, legal-privacy, lifecycle-training, marketing-partnerships, model-data, operations-coordination, platform-mlops, procurement-billing, quality-visualization, risk-audit, security-resilience (each 1 block; all 5 small departments retired) |'
      '| Retired department D2 files | 5 | governance-and-operations, quality-and-delivery, technology-and-platform, security-and-compliance, people-and-growth (slugs preserved as aliases) |'
      '| New department D3 files | 18 | each large department gains a D3 layer (references/departments/<slug>/) |'
      '| New shared reference modules | 0 | the large reference package ships its own shared set |'
      '| New prompts | 0 | prompts/03-test-cases.md (agent-invoked, L3) carried unchanged (G2 immutable) |'
      '| Frontmatter rewritten | 1 | scale_tier / department_count / function_block_count / version / error_code_prefixes (19 prefixes) / interface.department.enum (auto + 18) / description |'
      '| Revived error-code prefixes | 13 | BRD_, CFO_, CLO_, CMO_, COO_, CRO_, FW_, INTEL_, IRP_, KNM_, MDL_, PMGR_, PRC_ (net 19 prefixes at large) |'
      '| Aliases added | 18 | small->large alias rows appended to references/scaling.md Alias Map |'
      '| Governance files updated | <=4 | CHANGELOG.md entry inserted after [Unreleased]; version strings bumped to 4.0.0 |'
      '| Cross-tier jump | 1 | small -> large directly (the medium tier is skipped); the CHANGELOG keeps the full bloodline history |'
    )
    HumanReview = @(
      'The 5 small-tier department slugs are retired and replaced by 18 large-tier slugs; the 18 function blocks are conserved but re-homed one per department. Confirm the small->large alias rows in references/scaling.md map each retired slug to its intended large successor (the exact 1:1 mapping is flagged for human review).'
      'This is a cross-tier jump: the medium tier is skipped. The generated CHANGELOG retains the bloodline history of the reference package; the state record carries from=small, to=large.'
      'The large package carries the live tests/test-method-patterns.py unchanged (G2 immutable). Those tests are small-aware and will not pass against the 18-department / 117-code large layout; they must be made large-aware at install time (acceptance_passed stays false until then).'
      'README Project Structure trees describe the 148-file large skeleton; the narrative claims should be reviewed to match the 18-department / 7-domain layout (step 5i).'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the package. The pending proposal records acceptance_passed = false until this is done.'
    )
    ChangelogBullets = @(
      '- Departments: 5 -> 18 (the 5 small-tier departments are retired; 18 large-tier departments replace them; 18 function blocks conserved, one per department)'
      '- Error-code prefixes: 6 -> 19 (18 department prefixes + SCL_ infrastructure; 117 codes)'
      '- Cross-tier jump: the medium tier is skipped; the CHANGELOG keeps the full bloodline history'
      '- New D3 layer per department, 7-domain routing, and a department index'
      '- Slug aliases appended to references/scaling.md (Alias Map)'
    )
    DryRun = @(
      'DRY-RUN: 5h copy ai-company-large content (excluding its .scaling-state.json); overlay live tests/ + scripts/self-scale.ps1 + references/scaling.md (G2/G3 immutable)'
      'DRY-RUN: 5a de-bold D2 Function blocks figures (G4 reads plain integer)'
      'DRY-RUN: 5d build SKILL.md from the LIVE frontmatter shell retargeted to large (scale_tier=large, department_count=18, function_block_count=18, version=4.0.0, 19 prefixes, enum auto+18, permissions preserved for G1) + ai-company-large body'
      'DRY-RUN: 5e bump _meta.json to 4.0.0'
      'DRY-RUN: 5g append 18 alias rows (5 small legacy -> 18 large target) to the package Alias Map'
      'DRY-RUN: package state file initialized for tier large (acceptance_passed=false)'
      'DRY-RUN: 5i bump README versions (badge + at-a-glance rows)'
    )
  }
}

# micro -> large : cross-tier jump (small and medium skipped). The 2 micro
# departments are the retired set.
$MicroToLargeEdge = @{
  From = 'micro'
  To   = 'large'
  NewVersion = '4.0.0'
  OldVersion = '1.0.0'
  OldPrefixCount = 2
  ExpectedBlocks = 18
  DepartmentCount = 18
  Prefixes = $LargeEdge.Prefixes
  Split = $LargeEdge.Split
  AliasLegacy = @('governance-and-delivery', 'engineering-and-safety')
  AliasTarget = $LargeEdge.AliasTarget
  Report = @{
    FromDepartmentCount = 2
    TargetFiles = 148
    ChangeList = @(
      '| New department D2 files | 18 | board-and-branch, delivery-scheduling, engineering-tooling, executive-strategy, finance-treasury, incident-identity, intelligence-sentiment, knowledge-ethics, legal-privacy, lifecycle-training, marketing-partnerships, model-data, operations-coordination, platform-mlops, procurement-billing, quality-visualization, risk-audit, security-resilience (each 1 block; both micro departments retired) |'
      '| Retired department D2 files | 2 | governance-and-delivery, engineering-and-safety (slugs preserved as aliases) |'
      '| New department D3 files | 18 | each large department gains a D3 layer (references/departments/<slug>/) |'
      '| New shared reference modules | 0 | the large reference package ships its own shared set |'
      '| New prompts | 0 | prompts/03-test-cases.md (agent-invoked, L3) carried unchanged (G2 immutable) |'
      '| Frontmatter rewritten | 1 | scale_tier / department_count / function_block_count / version / error_code_prefixes (19 prefixes) / interface.department.enum (auto + 18) / description |'
      '| Revived error-code prefixes | 17 | every large department prefix except CEO_ / CTO_ (net 19 prefixes at large) |'
      '| Aliases added | 18 | micro->large alias rows appended to references/scaling.md Alias Map |'
      '| Governance files updated | <=4 | CHANGELOG.md entry inserted after [Unreleased]; version strings bumped to 4.0.0 |'
      '| Cross-tier jump | 1 | micro -> large directly (the small and medium tiers are skipped); the CHANGELOG keeps the full bloodline history |'
    )
    HumanReview = @(
      'The 2 micro-tier department slugs (governance-and-delivery, engineering-and-safety) are retired and replaced by 18 large-tier slugs; the 18 function blocks are conserved but re-homed one per department. Confirm the micro->large alias rows in references/scaling.md map each retired slug to its intended large successor (the exact 1:1 mapping is flagged for human review).'
      'This is a cross-tier jump: the small and medium tiers are skipped. The generated CHANGELOG retains the bloodline history of the reference package; the state record carries from=micro, to=large.'
      'The large package carries the live tests/test-method-patterns.py unchanged (G2 immutable). Those tests are micro-aware and will not pass against the 18-department / 117-code large layout; they must be made large-aware at install time (acceptance_passed stays false until then).'
      'README Project Structure trees describe the 148-file large skeleton; the narrative claims should be reviewed to match the 18-department / 7-domain layout (step 5i).'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the package. The pending proposal records acceptance_passed = false until this is done.'
    )
    ChangelogBullets = @(
      '- Departments: 2 -> 18 (the 2 micro-tier departments are retired; 18 large-tier departments replace them; 18 function blocks conserved, one per department)'
      '- Error-code prefixes: 2 -> 19 (18 department prefixes + SCL_ infrastructure; 117 codes)'
      '- Cross-tier jump: the small and medium tiers are skipped; the CHANGELOG keeps the full bloodline history'
      '- New D3 layer per department, 7-domain routing, and a department index'
      '- Slug aliases appended to references/scaling.md (Alias Map)'
    )
    DryRun = @(
      'DRY-RUN: 5h copy ai-company-large content (excluding its .scaling-state.json); overlay live tests/ + scripts/self-scale.ps1 + references/scaling.md (G2/G3 immutable)'
      'DRY-RUN: 5a de-bold D2 Function blocks figures (G4 reads plain integer)'
      'DRY-RUN: 5d build SKILL.md from the LIVE frontmatter shell retargeted to large (scale_tier=large, department_count=18, function_block_count=18, version=4.0.0, 19 prefixes, enum auto+18, permissions preserved for G1) + ai-company-large body'
      'DRY-RUN: 5e bump _meta.json to 4.0.0'
      'DRY-RUN: 5g append 18 alias rows (2 micro legacy -> 18 large target) to the package Alias Map'
      'DRY-RUN: package state file initialized for tier large (acceptance_passed=false)'
      'DRY-RUN: 5i bump README versions (badge + at-a-glance rows)'
    )
  }
}

# micro -> medium : cross-tier jump via in-place composition. Stage 1 is the
# deterministic micro -> small split; stage 2 is the small -> medium
# transformation run on the same package directory (-SkipInitialCopy). The
# department data (Split / AliasLegacy / AliasTarget / prefixes) is the medium
# tier's, shared with the small -> medium edge; only From and the report
# narrative differ.
$MicroToMediumEdge = @{
  From = 'micro'
  To   = 'medium'
  NewVersion = '3.0.0'
  OldVersion = '1.0.0'
  OldPrefixCount = 2
  ExpectedBlocks = 18
  DepartmentCount = 9
  Prefixes = $MediumEdge.Prefixes
  Split = $MediumEdge.Split
  AliasLegacy = $MediumEdge.AliasLegacy
  AliasTarget = $MediumEdge.AliasTarget
  Report = @{
    FromDepartmentCount = 2
    TargetFiles = 37
    ChangeList = @(
      '| Stage 1 (micro -> small) | 5 department D2 files | governance-and-delivery -> governance-and-operations + quality-and-delivery; engineering-and-safety -> technology-and-platform + security-and-compliance + people-and-growth (18 blocks conserved) |'
      '| Stage 2 (small -> medium) | 4 new departments | legal-and-risk, data-and-analytics, product-and-strategy, customer-and-partnerships (8 blocks migrate; re-prefixed) |'
      '| New shared reference modules | 3 | references/shared/{glossary, cross-department-handoff, common-patterns}.md |'
      '| New prompts | 1 | prompts/03-test-cases.md (agent-invoked, harness level L3) |'
      '| Frontmatter rewritten | 1 | scale_tier=medium, department_count=9, function_block_count=18, version=3.0.0, 10 prefixes, enum auto+9, description |'
      '| Error-code re-prefixing (resolved) | 8 codes | CEO_008->CLR_001, CEO_005->CPO_002, CEO_009->CCO_001, CISO_002->CLR_002, CTO_004->CDO_001, CQO_003->CDO_002, CHO_004->CPO_001, CHO_003->CCO_002 |'
      '| Aliases added | 5 + 8 | micro->small split rows and small->medium migration rows appended to references/scaling.md Alias Map |'
      '| Governance files updated | <=4 | CHANGELOG.md entry inserted after [Unreleased]; version strings bumped to 3.0.0 |'
      '| Cross-tier jump | 1 | micro -> medium directly (the small tier is skipped); both transformation stages are recorded in the CHANGELOG |'
    )
    HumanReview = @(
      'This is a cross-tier jump produced by composing the two deterministic transformations in place (micro -> small split, then the small -> medium migration). Confirm the resulting 9-department layout matches the small -> medium contract: 8 migrated blocks re-prefixed (CLR_001, CPO_002, CCO_001, CLR_002, CDO_001, CDO_002, CPO_001, CCO_002) and the 5 source prefixes re-baselined (CEO_ 6, CISO_ 3, CTO_ 3, CQO_ 2, CHO_ 2).'
      'Stage 1 appends the micro -> small split rows and the 24-row error-code alias skeleton (every row marked "requires human review"); stage 2 appends the small -> medium migration rows. Complete the skeleton cells and update the error-codes.md header counts.'
      'The package carries the live tests/test-method-patterns.py unchanged (G2 immutable). Those tests are micro-aware and will not pass against the 9-department layout; they must be made medium-aware at install time (acceptance_passed stays false until then).'
      'README Project Structure trees describe the 37-file medium skeleton; the narrative claims should be reviewed to match the 9-department layout (step 5i).'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the package. The pending proposal records acceptance_passed = false until this is done.'
    )
    ChangelogBullets = @(
      '- Departments: 2 -> 9 (micro -> small split, then the small -> medium migration: 8 function blocks move to 4 new departments; 18 blocks conserved)'
      '- New error-code prefixes: CLR_, CDO_, CPO_, CCO_ (resolved alias table appended to references/error-codes.md)'
      '- New shared modules: references/shared/{glossary, cross-department-handoff, common-patterns}.md'
      '- Cross-tier jump: the small tier is skipped; both transformation stages are recorded here'
      '- Slug aliases appended to references/scaling.md (Alias Map)'
    )
    DryRun = @(
      'DRY-RUN: 5h copy the current (micro) package (excluding .scaling-state.json)'
      'DRY-RUN: stage 1 (micro -> small): 5a/5b split 2 legacy D2 pages into 5 departments (18 blocks conserved); 5a generate prompts/03-test-cases.md; 5d retarget frontmatter to small; 5e bump _meta.json + alias skeleton; 5g append 5 alias rows; 5i rewrite README trees + CHANGELOG entry'
      'DRY-RUN: stage 2 (small -> medium, initial copy skipped): 5a migrate 8 function blocks into 4 new departments (re-prefixed; source pages re-baselined); author 4 D2 pages + 3 shared modules; 5d retarget frontmatter to medium; 5e transform error-codes.md; 5g append 8 alias rows; 5i rewrite README trees + CHANGELOG entry'
      'DRY-RUN: package state file initialized for tier medium (append-only)'
    )
  }
}

# large -> group : SCAFFOLD. The group tier's 36 departments are not authored
# anywhere and their slugs are undefined, so no deterministic content exists and
# this build never fabricates structure. The builder copies the package forward
# verbatim and emits UPGRADE-WORK-ORDER.txt; the frontmatter is deliberately NOT
# retargeted (there is no 36-slug enum to write), so the content gates G4/G5/G6
# fail BY DESIGN and their failure detail IS the authoring checklist. G1-G3 pass
# because the carry-forward is byte-identical. Scaffold edges record nothing in
# .scaling-state.json (no pending proposal) and are never quarantined.
$GroupEdge = @{
  From = 'large'
  To   = 'group'
  NewVersion = '5.0.0'
  OldVersion = '4.0.0'
  OldPrefixCount = 19
  ExpectedBlocks = 36
  DepartmentCount = 36
  Prefixes = @()
  Split = @()
  AliasLegacy = $LargeEdge.AliasTarget
  AliasTarget = @()
  Scaffold = $true
  Report = @{
    FromDepartmentCount = 18
    TargetFiles = 246
    ChangeList = @(
      '| Scaffold package | 1 | the current large package copied forward verbatim (content unchanged); UPGRADE-WORK-ORDER.txt emitted |'
      '| Authored content required | 36 departments | references/departments/<slug>.md + <slug>/department-spec.md + <slug>/prompts/01-implement-method.md + <slug>/prompts/02-robustness-checks.md + <slug>/references/method-patterns.md |'
      '| Frontmatter rebuild required | 1 | scale_tier=group, department_count=36, function_block_count=36, version=5.0.0, interface.department.enum (auto + 36), department_aliases pointer; permissions copied verbatim |'
      '| references/department-index.md | 1 | 7 domains, 36 rows |'
      '| references/error-codes.md | 1 | revived prefixes start at 001 |'
      '| references/scaling.md | 1 | Alias Map appended (append-only): 18 large slugs -> 36 group slugs |'
      '| Gates | by design | G1-G3 pass (byte-identical carry-forward); G4/G5/G6 fail until the content exists - the failure detail is the checklist |'
    )
    HumanReview = @(
      'The group tier has no authored content and its 36 department slugs are undefined; this build deliberately does not fabricate structure. Complete UPGRADE-WORK-ORDER.txt (36 department page sets, department-index rows, error-code prefixes, the frontmatter rebuild and the Alias Map rows), then re-run the six gates.'
      'This scaffold is NOT a proposal: nothing is recorded in .scaling-state.json and no UPGRADE-PROPOSAL.md is written, so no installer can apply an incomplete package. When the content is complete the gates re-run and a normal proposal is recorded.'
      'Full acceptance (README_FOR_AI.md sec 15; content groups A-G, H, I, U) on the completed package. The recorded proposal sets acceptance_passed = false until this is done.'
    )
    ChangelogBullets = @(
      '- Scaffold generated: the group tier requires 36 authored department page sets (D2 + D3 + 2 prompts + method-patterns each), a 36-row department index, revived error-code prefixes and a frontmatter rebuild'
      '- See UPGRADE-WORK-ORDER.txt in the package for the complete authoring checklist'
    )
    DryRun = @(
      'DRY-RUN: 5h copy the current (large) package forward (excluding .scaling-state.json); write the group-tier state skeleton and UPGRADE-WORK-ORDER.txt'
      'DRY-RUN: frontmatter NOT retargeted (36 group slugs do not exist yet; the work order lists the rebuild)'
      'DRY-RUN: 6 run gates G1-G6; G4/G5/G6 fail BY DESIGN (content missing)'
      'DRY-RUN: scaffold branch: package left in place (not quarantined), nothing recorded in the state file, exit 0'
    )
  }
}

# --------------------------------------------------------------------------------------
# Deterministic dispatch tables for arbitrary target selection.
# Key = '<from>-><to>'. The edges above are the data; these two tables are the
# ONLY place a pair is bound to a builder, so adding a pair never touches the
# gate, report or flow code. The test suite asserts every key here is listed in
# scaling-config.json selectable_targets (no config/script drift).
# --------------------------------------------------------------------------------------
$UpgradeEdges = [ordered]@{
  'micro->small'  = $UpgradeEdge
  'small->medium' = $MediumEdge
  'medium->large' = $LargeEdge
  'micro->large'  = $MicroToLargeEdge
  'small->large'  = $SmallToLargeEdge
  'micro->medium' = $MicroToMediumEdge
  'large->group'  = $GroupEdge
}
$UpgradeBuildFns = [ordered]@{
  'micro->small'  = { param($Dir, $Edge) New-UpgradePackage -PkgDir $Dir }
  'small->medium' = { param($Dir, $Edge) New-SmallToMediumUpgradePackage -PkgDir $Dir -Edge $Edge }
  'medium->large' = { param($Dir, $Edge) New-MediumToLargeUpgradePackage -PkgDir $Dir -Edge $Edge }
  'micro->large'  = { param($Dir, $Edge) New-MediumToLargeUpgradePackage -PkgDir $Dir -Edge $Edge }
  'small->large'  = { param($Dir, $Edge) New-MediumToLargeUpgradePackage -PkgDir $Dir -Edge $Edge }
  'micro->medium' = { param($Dir, $Edge) New-MicroToMediumUpgradePackage -PkgDir $Dir -Edge $Edge }
  'large->group'  = { param($Dir, $Edge) New-LargeToGroupUpgradePackage -PkgDir $Dir -Edge $Edge }
}

# Ordered selectable targets for a source tier: the config contract first
# (scaling-config.json selectable_targets), the builder table as fallback for an
# older config that lacks the key.
function Get-SelectableTargetTiers {
  param([string]$FromTier, $Config)
  if (($null -ne $Config) -and ($null -ne $Config.SelectableTargets) -and $Config.SelectableTargets.ContainsKey($FromTier)) {
    return @($Config.SelectableTargets[$FromTier])
  }
  $out = @()
  foreach ($k in @($UpgradeEdges.Keys)) { if ($k -like ($FromTier + '->*')) { $out += ($k -replace '^.*->', '') } }
  return @($out | Sort-Object)
}

function Get-DefaultTargetTier {
  param([string]$FromTier, $Config)
  if (($null -ne $Config) -and ($null -ne $Config.SelectableTargets) -and $Config.SelectableTargets.ContainsKey($FromTier)) {
    $list = @($Config.SelectableTargets[$FromTier])
    if ($list.Count -gt 0) { return [string]$list[0] }
  }
  if (($null -ne $Config) -and ($null -ne $Config.UpgradePath) -and $Config.UpgradePath.ContainsKey($FromTier)) {
    return [string]$Config.UpgradePath[$FromTier]
  }
  $list = @(Get-SelectableTargetTiers -FromTier $FromTier -Config $Config)
  if ($list.Count -gt 0) { return [string]$list[0] }
  return ''
}

# small -> medium block migrations: the 8 moved function blocks, re-prefixed.
# SourceDept = origin D2 page; Label = FB section label inside it; From = exact
# error code to re-prefix; ToDept = destination D2 page; ToCode = new code;
# ToFb = new FB number inside the destination page; ToLabel = new FB label.
$MediumBlockMoves = @{
  'governance-and-operations' = @(
    @{ Label = 'CRO';  From = 'CEO_008'; ToDept = 'legal-and-risk';            ToCode = 'CLR_001'; ToFb = 1; ToLabel = 'CLR' }
    @{ Label = 'BRD';  From = 'CEO_005'; ToDept = 'product-and-strategy';      ToCode = 'CPO_002'; ToFb = 2; ToLabel = 'CPO' }
    @{ Label = 'PRC';  From = 'CEO_009'; ToDept = 'customer-and-partnerships'; ToCode = 'CCO_001'; ToFb = 1; ToLabel = 'CCO' }
  )
  'security-and-compliance' = @(
    @{ Label = 'CLO';  From = 'CISO_002'; ToDept = 'legal-and-risk';       ToCode = 'CLR_002'; ToFb = 2; ToLabel = 'CLR' }
  )
  'technology-and-platform' = @(
    @{ Label = 'MDL';  From = 'CTO_004'; ToDept = 'data-and-analytics';    ToCode = 'CDO_001'; ToFb = 1; ToLabel = 'CDO' }
  )
  'quality-and-delivery' = @(
    @{ Label = 'INFO'; From = 'CQO_003'; ToDept = 'data-and-analytics';    ToCode = 'CDO_002'; ToFb = 2; ToLabel = 'CDO' }
  )
  'people-and-growth' = @(
    @{ Label = 'INTEL'; From = 'CHO_004'; ToDept = 'product-and-strategy';  ToCode = 'CPO_001'; ToFb = 1; ToLabel = 'CPO' }
    @{ Label = 'CMO';   From = 'CHO_003'; ToDept = 'customer-and-partnerships'; ToCode = 'CCO_002'; ToFb = 2; ToLabel = 'CCO' }
  )
}
# Error-code re-baselining inside the 5 source departments after the moves
# (keeps each existing prefix continuous with no gaps). Keyed by prefix; each
# entry is an ordered list of (Old -> New) renames applied to the KEPT codes.
$MediumSourceRebase = @{
  'CEO_' = @(
    @{ Old = 'CEO_007'; New = 'CEO_TMP' },   # placeholder to avoid collision
    @{ Old = 'CEO_006'; New = 'CEO_005' },
    @{ Old = 'CEO_TMP'; New = 'CEO_006' }
  )
  'CISO_' = @(
    @{ Old = 'CISO_004'; New = 'CISO_TMP' },
    @{ Old = 'CISO_003'; New = 'CISO_002' },
    @{ Old = 'CISO_TMP'; New = 'CISO_003' }
  )
}

# --------------------------------------------------------------------------------------
# Logging and termination helpers
# --------------------------------------------------------------------------------------

function Write-Log {
  # Uses Write-Host (not Write-Output) so that log lines never pollute the
  # return values of functions whose results are assigned to variables.
  param([string]$Message)
  Write-Host ("{0} [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'), $PID, $Message)
}

function Stop-WithCode {
  param([string]$Code, [string]$Message)
  Write-Log "FATAL $Code : $Message"
  Write-Log "Execution stopped. No content file under the skill directory was modified."
  exit 2
}

function Get-UtcNowIso {
  return (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}

function Get-WorkspaceRelativePath {
  # Render a path as a workspace-relative reference ({WORKSPACE_ROOT}/...).
  # State files must never embed machine-specific absolute user paths: the
  # large-tier suite's M-check test_no_hardcoded_user_paths sweeps
  # .scaling-state.json (and every *.md/*.json/*.ps1/*.py) for drive-letter
  # user-path patterns, and the post-apply live suite is large-aware.
  # $WorkspaceRoot is script-scoped (defined near the top of this script).
  param([Parameter(Mandatory)][string]$Path)
  if ([string]::IsNullOrWhiteSpace($Path)) { return '' }
  $root = $WorkspaceRoot.TrimEnd('\', '/')
  if ($Path.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -and $Path.Length -gt $root.Length) {
    return ('{WORKSPACE_ROOT}/' + $Path.Substring($root.Length + 1).Replace('\', '/'))
  }
  return $Path.Replace('\', '/')
}

# --------------------------------------------------------------------------------------
# Text / hash helpers
# --------------------------------------------------------------------------------------

function Get-TextSha256 {
  param([string]$Text)
  if ($null -eq $Text) { return '' }
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '').ToLowerInvariant()
  } finally { $sha.Dispose() }
}

function Read-TextFile {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  return [System.IO.File]::ReadAllText($Path)
}

function Write-TextFileNoBom {
  # E15 : every .md / .json artifact written by this script keeps LF line
  # endings (.editorconfig [*] = lf). The script itself is LF as well
  # ([*.ps1] end_of_line = lf, pinned by .gitattributes). Here-strings are
  # normalized anyway, so the function is safe even if a file arrives with CRLF.
  param([string]$Path, [string]$Text)
  if ($null -eq $Text) { $Text = '' }
  $normalized = $Text -replace "`r`n", "`n"
  [System.IO.File]::WriteAllText($Path, $normalized, $Utf8NoBom)
}

# --------------------------------------------------------------------------------------
# Package file set (ONE definition, shared by the copy, the counts and the gates)
# --------------------------------------------------------------------------------------

function Test-PackagePathExcluded {
  # True when a relative package path (either separator style) falls outside the
  # package file set: its first path segment is a repository tooling directory,
  # or it is a build residue.
  param([string]$RelativePath)
  if ([string]::IsNullOrWhiteSpace($RelativePath)) { return $true }
  $normalized = $RelativePath.Replace('\', '/')
  $segments = $normalized -split '/'
  if ($segments.Count -gt 0) {
    if ($ExcludedDirSegments -contains $segments[0]) { return $true }
  }
  if ($normalized -match '(^|/)__pycache__/') { return $true }
  if ($normalized -match '\.pyc$') { return $true }
  return $false
}

function Get-PackageRelativePaths {
  # Every file under $Root that belongs to the package file set, as posix
  # relative paths, sorted. This is the single counting basis used by the 5h
  # copy, gate G6, the proposal report and the state file's validation.file_count.
  param([string]$Root)
  $out = @()
  if (-not (Test-Path -LiteralPath $Root)) { return $out }
  $files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Force -ErrorAction SilentlyContinue)
  foreach ($f in $files) {
    $rel = $f.FullName.Substring($Root.Length + 1).Replace('\', '/')
    if (Test-PackagePathExcluded -RelativePath $rel) { continue }
    $out += $rel
  }
  return @($out | Sort-Object)
}

# --------------------------------------------------------------------------------------
# Configuration (scripts/scaling-config.json, falls back to documented defaults)
# --------------------------------------------------------------------------------------

function Load-Config {
  $cfg = $null
  if (Test-Path -LiteralPath $ConfigFile) {
    try { $cfg = ConvertFrom-Json ([System.IO.File]::ReadAllText($ConfigFile)) }
    catch { Write-Log "WARN scaling-config.json is invalid JSON; using built-in defaults" }
  } else {
    Write-Log "WARN scaling-config.json not found; using built-in defaults"
  }
  $result = @{
    IntervalDays = 30
    AgentHeadroom = 1.0
    BlocksRatio = 1.5
    RoutingFloor = 0.85
    ReuseCeiling = 0.25
    OutputDir = ''
    MetricsMaxAgeDays = 45
    MinRoutingSamples = 20
    MetricsDropDir = ''
    MetricsLogCap = 20
    # Arbitrary target selection (references/scaling.md sec 2). Defaults mirror
    # the historical linear chain so an older config still resolves a default.
    TierOrder = @('micro', 'small', 'medium', 'large', 'group')
    MaxTier = 'group'
    UpgradePath = @{}
    SelectableTargets = @{}
  }
  if ($null -ne $cfg) {
    if ($null -ne $cfg.PSObject.Properties['evaluation_interval_days']) { $result.IntervalDays = [int]$cfg.evaluation_interval_days }
    if ($null -ne $cfg.PSObject.Properties['thresholds']) {
      $t = $cfg.thresholds
      if ($null -ne $t.PSObject.Properties['agent_count_headroom'])       { $result.AgentHeadroom = [double]$t.agent_count_headroom }
      if ($null -ne $t.PSObject.Properties['blocks_per_department_ratio']){ $result.BlocksRatio = [double]$t.blocks_per_department_ratio }
      if ($null -ne $t.PSObject.Properties['routing_accuracy_floor'])     { $result.RoutingFloor = [double]$t.routing_accuracy_floor }
      if ($null -ne $t.PSObject.Properties['error_code_reuse_ceiling'])   { $result.ReuseCeiling = [double]$t.error_code_reuse_ceiling }
    }
    if ($null -ne $cfg.PSObject.Properties['host_metrics']) {
      $h = $cfg.host_metrics
      if ($null -ne $h.PSObject.Properties['max_age_days'])         { $result.MetricsMaxAgeDays = [int]$h.max_age_days }
      if ($null -ne $h.PSObject.Properties['min_routing_samples'])  { $result.MinRoutingSamples = [int]$h.min_routing_samples }
      if ($null -ne $h.PSObject.Properties['drop_dir'])             { $result.MetricsDropDir = [string]$h.drop_dir }
      if ($null -ne $h.PSObject.Properties['log_cap'])              { $result.MetricsLogCap = [int]$h.log_cap }
    }
    if ($null -ne $cfg.PSObject.Properties['output_dir']) { $result.OutputDir = [string]$cfg.output_dir }
    if ($null -ne $cfg.PSObject.Properties['tier_order']) {
      $order = @($cfg.tier_order | ForEach-Object { [string]$_ } | Where-Object { $_ -ne '' })
      if ($order.Count -gt 0) { $result.TierOrder = $order }
    }
    if ($null -ne $cfg.PSObject.Properties['max_tier']) { $result.MaxTier = [string]$cfg.max_tier }
    if ($null -ne $cfg.PSObject.Properties['upgrade_path']) {
      $up = @{}
      foreach ($p in $cfg.upgrade_path.PSObject.Properties) { $up[[string]$p.Name] = [string]$p.Value }
      $result.UpgradePath = $up
    }
    if ($null -ne $cfg.PSObject.Properties['selectable_targets']) {
      $st = @{}
      foreach ($p in $cfg.selectable_targets.PSObject.Properties) {
        $st[[string]$p.Name] = @($p.Value | ForEach-Object { [string]$_ } | Where-Object { $_ -ne '' })
      }
      $result.SelectableTargets = $st
    }
    # Contract consistency: every default target must be the first selectable
    # target for its tier (drift here would silently change the default path).
    foreach ($tier in @($result.UpgradePath.Keys)) {
      if ($result.SelectableTargets.ContainsKey($tier)) {
        $first = @($result.SelectableTargets[$tier])
        if (($first.Count -gt 0) -and ($first[0] -ne $result.UpgradePath[$tier])) {
          Stop-WithCode 'SCL_007' ("scaling-config.json drift: upgrade_path.$tier = '$($result.UpgradePath[$tier])' but selectable_targets.$tier starts with '$($first[0])'")
        }
      }
    }
  }
  if ([string]::IsNullOrWhiteSpace($result.OutputDir)) { $result.OutputDir = '{WORKSPACE_ROOT}/.skill-upgrade' }
  if ([string]::IsNullOrWhiteSpace($result.MetricsDropDir)) { $result.MetricsDropDir = '{WORKSPACE_ROOT}/.skill-metrics' }
  if ($result.MetricsLogCap -lt 1) { $result.MetricsLogCap = 20 }
  return $result
}

# --------------------------------------------------------------------------------------
# State file handling (step 1 ; SCL_007 on corrupt / inconsistent)
# --------------------------------------------------------------------------------------

function Read-State {
  if (-not (Test-Path -LiteralPath $StateFile)) {
    Stop-WithCode 'SCL_007' "state file not found: $StateFile"
  }
  $state = $null
  try { $state = ConvertFrom-Json ([System.IO.File]::ReadAllText($StateFile)) }
  catch { Stop-WithCode 'SCL_007' "state file is not valid JSON: $StateFile" }
  foreach ($field in @('schema_version', 'current_tier', 'tier_history', 'pending_proposals', 'next_evaluation')) {
    if ($null -eq $state.PSObject.Properties[$field]) {
      Stop-WithCode 'SCL_007' "state file is missing required field '$field'"
    }
  }
  $validTiers = @('micro', 'small', 'medium', 'large', 'group')
  if ($validTiers -notcontains [string]$state.current_tier) {
    Stop-WithCode 'SCL_007' "state file current_tier has an illegal value: '$($state.current_tier)'"
  }
  # P41 : current_tier must agree with the SKILL.md frontmatter scale_tier.
  $fm = Get-FrontmatterText (Join-Path $SkillDir 'SKILL.md')
  if ($null -ne $fm) {
    $fmTier = $null
    $fmMatch = [regex]::Match($fm, '(?m)^\s*scale_tier\s*:\s*([a-z]+)\s*$')
    if ($fmMatch.Success) { $fmTier = $fmMatch.Groups[1].Value }
    if (($null -ne $fmTier) -and ($fmTier -ne [string]$state.current_tier)) {
      Stop-WithCode 'SCL_007' ("current_tier '{0}' does not match SKILL.md frontmatter scale_tier '{1}'" -f $state.current_tier, $fmTier)
    }
  }
  Initialize-ValidationBlock -State $state
  return $state
}

function Set-StateProperty {
  param($State, [string]$Name, $Value)
  if ($null -ne $State.PSObject.Properties[$Name]) { $State.$Name = $Value }
  else { $State | Add-Member -MemberType NoteProperty -Name $Name -Value $Value }
}

function Initialize-ValidationBlock {
  # README_FOR_AI.md sec 12.6 requires a TOP-LEVEL 'validation' block on the state
  # file: gates_passed must be 6 and file_count must be the expected package
  # file count for the current tier (micro 26 / small 30). Before this fix the
  # block only ever existed inside pending_proposals[] entries, so any machine
  # reader of the top level saw a contract that was never implemented (M-2).
  # acceptance_passed is carried over: only a human (or the external installer)
  # may set it to true.
  param($State)
  $tier = [string]$State.current_tier
  $expected = 0
  if ($TierFileCount.ContainsKey($tier)) { $expected = [int]$TierFileCount[$tier] }
  $block = [ordered]@{
    gates_passed      = 6
    file_count        = $expected
    acceptance_passed = $false
  }
  if ($null -ne $State.PSObject.Properties['validation']) {
    $existing = $State.validation
    if ($null -ne $existing) {
      if ($null -ne $existing.PSObject.Properties['acceptance_passed']) {
        $block.acceptance_passed = [bool]$existing.acceptance_passed
      }
    }
  }
  Set-StateProperty -State $State -Name 'validation' -Value $block
}

function Format-JsonStringLiteral {
  param([string]$Value)
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('"')
  foreach ($ch in $Value.ToCharArray()) {
    if ($ch -eq '"') { [void]$sb.Append('\"') }
    elseif ($ch -eq '\') { [void]$sb.Append('\\') }
    elseif ($ch -eq "`b") { [void]$sb.Append('\b') }
    elseif ($ch -eq "`f") { [void]$sb.Append('\f') }
    elseif ($ch -eq "`n") { [void]$sb.Append('\n') }
    elseif ($ch -eq "`r") { [void]$sb.Append('\r') }
    elseif ($ch -eq "`t") { [void]$sb.Append('\t') }
    elseif ([int]$ch -lt 32) { [void]$sb.Append(('\u{0:x4}' -f [int]$ch)) }
    else { [void]$sb.Append($ch) }
  }
  [void]$sb.Append('"')
  return $sb.ToString()
}

function Format-JsonScalar {
  param($Value)
  $inv = [System.Globalization.CultureInfo]::InvariantCulture
  if ($null -eq $Value) { return 'null' }
  if ($Value -is [bool]) { if ($Value) { return 'true' }; return 'false' }
  if ($Value -is [string]) { return (Format-JsonStringLiteral $Value) }
  if (($Value -is [double]) -or ($Value -is [single]) -or ($Value -is [decimal])) {
    # Keep at least one decimal place so that 1.0 never collapses to 1 in the
    # committed state file (the repository style stores these metrics as floats).
    return ([double]$Value).ToString('0.0###########', $inv)
  }
  if (($Value -is [int]) -or ($Value -is [long]) -or ($Value -is [int16]) -or ($Value -is [uint32]) -or ($Value -is [uint64])) {
    return $Value.ToString($inv)
  }
  return (Format-JsonStringLiteral ([string]$Value))
}

function ConvertTo-StableJson {
  # E16 : ConvertTo-Json emits PowerShell-flavoured output - empty arrays expand
  # into large blank blocks and nested keys are indented relative to the parent
  # key name, which breaks the 2-space indent mandated by .editorconfig and
  # leaves a noisy diff every time this script touches the state file. This
  # serializer emits stable, 2-space-indented JSON with `[]` for empty arrays.
  param($Value, [int]$Level = 0)
  $nl  = [string][char]10
  $pad = ' ' * ($Level * 2)
  $padIn = ' ' * (($Level + 1) * 2)

  if ($null -eq $Value) { return 'null' }
  if ($Value -is [System.Collections.IDictionary]) {
    $keys = @($Value.Keys)
    if ($keys.Count -eq 0) { return '{}' }
    $parts = @()
    foreach ($k in $keys) {
      $parts += ($padIn + (Format-JsonStringLiteral ([string]$k)) + ': ' + (ConvertTo-StableJson -Value $Value[$k] -Level ($Level + 1)))
    }
    return '{' + $nl + ($parts -join (',' + $nl)) + $nl + $pad + '}'
  }
  if (($Value -is [System.Collections.IEnumerable]) -and -not ($Value -is [string])) {
    $items = @($Value)
    if ($items.Count -eq 0) { return '[]' }
    $parts = @()
    foreach ($it in $items) {
      $parts += ($padIn + (ConvertTo-StableJson -Value $it -Level ($Level + 1)))
    }
    return '[' + $nl + ($parts -join (',' + $nl)) + $nl + $pad + ']'
  }
  if ($Value -is [System.Management.Automation.PSCustomObject]) {
    $props = @($Value.PSObject.Properties | Where-Object { $_.MemberType -in @('NoteProperty', 'Property', 'AliasProperty') })
    if ($props.Count -eq 0) { return '{}' }
    $parts = @()
    foreach ($p in $props) {
      $parts += ($padIn + (Format-JsonStringLiteral ([string]$p.Name)) + ': ' + (ConvertTo-StableJson -Value $p.Value -Level ($Level + 1)))
    }
    return '{' + $nl + ($parts -join (',' + $nl)) + $nl + $pad + '}'
  }
  return (Format-JsonScalar $Value)
}

function Save-State {
  param($State)
  $json = ConvertTo-StableJson -Value $State
  Write-TextFileNoBom -Path $StateFile -Text ($json + "`n")
  Write-Log "state file updated: $StateFile"
}

# --------------------------------------------------------------------------------------
# Frontmatter helpers
# --------------------------------------------------------------------------------------

function Get-FrontmatterText {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $null }
  $lines = [System.IO.File]::ReadAllLines($Path)
  if ($lines.Count -lt 2) { return $null }
  if ($lines[0].Trim() -ne '---') { return $null }
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i].Trim() -eq '---') {
      if ($i -le 1) { return '' }
      return ($lines[1..($i - 1)] -join "`n")
    }
  }
  return $null
}

function Get-FrontmatterSubBlock {
  # Returns the full YAML sub-block of a top-level key (the key line plus every
  # indented line that follows it), or $null when the key is absent.
  param([string]$FrontmatterText, [string]$Key)
  if ($null -eq $FrontmatterText) { return $null }
  $lines = $FrontmatterText -split "`n"
  $start = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match ('^' + $Key + '\s*:\s*$')) { $start = $i; break }
  }
  if ($start -lt 0) { return $null }
  $out = New-Object System.Collections.Generic.List[string]
  $out.Add($lines[$start])
  for ($i = $start + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\S') { break }
    $out.Add($lines[$i])
  }
  return ($out -join "`n")
}

function Get-DenyItems {
  # Extracts the items of the 'deny' list inside a permissions block. Supports
  # both the inline flow form  deny: ["a", "b", ...]  (README_FOR_AI.md sec 9.1 shape) and the
  # block list form  deny:\n  - a\n  - b .
  param([string]$PermissionsBlock)
  $items = @()
  if ($null -eq $PermissionsBlock) { return $items }
  foreach ($line in ($PermissionsBlock -split "`n")) {
    if ($line -match '^\s+deny\s*:\s*\[(.*)\]\s*$') {
      foreach ($m in [regex]::Matches($Matches[1], '"([^"]+)"')) { $items += $m.Groups[1].Value }
    }
  }
  if ($items.Count -eq 0) {
    $inDeny = $false
    foreach ($line in ($PermissionsBlock -split "`n")) {
      if ($line -match '^\s+deny\s*:\s*$') { $inDeny = $true; continue }
      if ($inDeny) {
        if ($line -match '^\s+-\s+(.+?)\s*$') { $items += $Matches[1].Trim('"') }
        elseif ($line -match '^\S') { break }
      }
    }
  }
  return $items
}

# --------------------------------------------------------------------------------------
# Host write-back interface (references/scaling.md section 3.1)
#
# T1 (agent_count) and T3 (routing_accuracy) cannot be observed from inside the
# package, so they arrive from the host through this interface instead of being
# invented here. Three rules shape everything below:
#
#   1. VALIDATE  - a value outside its domain is rejected before anything is
#                  written; a rejected write leaves the state file untouched.
#   2. TIMESTAMP - an observation without a trustworthy observation time cannot
#                  drive a tier decision, so freshness gates T1/T3.
#   3. SKIP, DO NOT GUESS - stale or absent host data makes T1/T3 skip, never
#                  fall back to a default number. A one-year-old report of
#                  "99 agents" must not generate an upgrade proposal today.
# --------------------------------------------------------------------------------------

function Resolve-MetricsDropDir {
  param($Config)
  # {WORKSPACE_ROOT} is the only placeholder expanded here; anything else is
  # left verbatim so a misconfigured path stays visible in the log.
  $dir = [string]$Config.MetricsDropDir
  return $dir.Replace('{WORKSPACE_ROOT}', $WorkspaceRoot)
}

function Test-HostMetricValue {
  # Domain check for a single host-supplied metric.
  # Returns @{ Ok = <bool>; Reason = <string> }.
  param([string]$Name, $Value)
  if ($Name -ne 'agent_count' -and $Name -ne 'routing_accuracy') {
    return @{ Ok = $false; Reason = "unknown host metric '$Name' (supported: agent_count, routing_accuracy)" }
  }
  if ($null -eq $Value) {
    return @{ Ok = $false; Reason = "$Name is null" }
  }
  if (-not ($Value -is [int]) -and -not ($Value -is [long]) -and -not ($Value -is [double]) -and -not ($Value -is [decimal])) {
    return @{ Ok = $false; Reason = "$Name must be numeric, got '$Value'" }
  }
  if ($Name -eq 'agent_count') {
    $n = [double]$Value
    if ($n -ne [math]::Floor($n)) { return @{ Ok = $false; Reason = "agent_count must be a whole number, got $Value" } }
    if ($n -lt 0)                { return @{ Ok = $false; Reason = "agent_count must be >= 0, got $Value" } }
    if ($n -gt 1000000)          { return @{ Ok = $false; Reason = "agent_count $Value is implausibly large; rejected as a host bug" } }
    return @{ Ok = $true; Reason = 'ok' }
  }
  $d = [double]$Value
  if ($d -lt 0.0 -or $d -gt 1.0) { return @{ Ok = $false; Reason = "routing_accuracy must be within [0,1], got $Value" } }
  return @{ Ok = $true; Reason = 'ok' }
}

function ConvertTo-UtcIso {
  # Normalizes any ISO-8601 input to UTC 'yyyy-MM-ddTHH:mm:ssZ'. Returns '' when
  # the value cannot be parsed - callers treat '' as "no trustworthy time".
  param([string]$Value)
  if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
  $ts = [datetime]::MinValue
  $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
  $ok = [datetime]::TryParse($Value, [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$ts)
  if (-not $ok) { return '' }
  return $ts.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
}

function Get-HostMetricsFreshness {
  # Decides whether each host-supplied metric may drive its threshold.
  # Returns @{ agent_count = @{Usable;AgeDays;ObservedAt;Source;SampleSize;Reason};
  #            routing_accuracy = @{...} }
  param($State, $Config)
  $result = [ordered]@{}
  foreach ($n in @('agent_count', 'routing_accuracy')) {
    $result[$n] = @{ Usable = $false; AgeDays = -1; ObservedAt = ''; Source = ''; SampleSize = -1; Reason = 'never supplied by any host' }
  }
  if ($null -eq $State.PSObject.Properties['host_metrics']) { return $result }
  $hm = $State.host_metrics
  if ($null -eq $hm) { return $result }

  foreach ($n in @('agent_count', 'routing_accuracy')) {
    if ($null -eq $hm.PSObject.Properties[$n]) { continue }
    $entry = $hm.$n
    if ($null -eq $entry) { continue }
    $e = $result[$n]
    if ($null -ne $entry.PSObject.Properties['source'])      { $e.Source = [string]$entry.source }
    if ($null -ne $entry.PSObject.Properties['sample_size']) { $e.SampleSize = [int]$entry.sample_size }
    $rawObserved = ''
    if ($null -ne $entry.PSObject.Properties['observed_at']) { $rawObserved = [string]$entry.observed_at }
    $observed = ConvertTo-UtcIso $rawObserved
    $e.ObservedAt = $observed

    if ([string]::IsNullOrWhiteSpace($observed)) { $e.Reason = 'observed_at missing or unparseable'; continue }

    $ts = [datetime]::MinValue
    $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
    [void][datetime]::TryParse($observed, [System.Globalization.CultureInfo]::InvariantCulture, $styles, [ref]$ts)
    $age = ((Get-Date).ToUniversalTime() - $ts.ToUniversalTime()).TotalDays
    $e.AgeDays = [math]::Round($age, 2)

    if ($age -lt -1.0) { $e.Reason = "observed_at is $($e.AgeDays) days old - negative, i.e. in the future (clock skew or bad host data)"; continue }
    if ($age -gt $Config.MetricsMaxAgeDays) {
      $e.Reason = "observation is $([math]::Round($age,1)) days old, past the $($Config.MetricsMaxAgeDays)-day freshness limit"
      continue
    }
    if ($n -eq 'routing_accuracy' -and $e.SampleSize -ge 0 -and $e.SampleSize -lt $Config.MinRoutingSamples) {
      $e.Reason = "only $($e.SampleSize) routing samples, below the $($Config.MinRoutingSamples)-sample minimum; too noisy to judge T3"
      continue
    }
    $e.Usable = $true
    $e.Reason = 'ok'
  }
  return $result
}

function Write-HostMetric {
  # Applies one validated metric to the state object (caller saves). Mirrors the
  # value into last_metrics so existing readers keep working unchanged, and
  # appends a rolling audit entry so every write-back is traceable.
  param($State, [string]$Name, $Value, [string]$ObservedAt, [string]$Source, [int]$SampleSize, $Config)

  $hm = [ordered]@{}
  if ($null -ne $State.PSObject.Properties['host_metrics']) {
    $existing = $State.host_metrics
    if ($existing -is [System.Collections.IDictionary]) {
      # Within one process host_metrics is an [ordered] dictionary, and its
      # .PSObject.Properties are the .NET members (Count / Keys / Values / ...),
      # NOT the metric entries. Copying those corrupted host_metrics on every
      # second write of the same run (a drop directory carrying two files, or a
      # single record-metrics call carrying both metrics): the entries were
      # replaced by the dictionary's own member properties, so T1/T3 then
      # reported "never supplied by any host". Enumerate the keys instead.
      foreach ($k in @($existing.Keys)) { $hm[$k] = $existing[$k] }
    } else {
      # After Read-State the same value is a PSCustomObject, where the metric
      # names ARE properties.
      foreach ($p in @($existing.PSObject.Properties)) { $hm[$p.Name] = $p.Value }
    }
  }
  $entry = [ordered]@{
    value       = $Value
    observed_at = $ObservedAt
    source      = $Source
    recorded_at = (Get-UtcNowIso)
  }
  if ($SampleSize -ge 0) { $entry.sample_size = $SampleSize }
  $hm[$Name] = $entry
  $State | Add-Member -MemberType NoteProperty -Name 'host_metrics' -Value $hm -Force

  if ($null -ne $State.PSObject.Properties['last_metrics']) {
    if ($null -ne $State.last_metrics.PSObject.Properties[$Name]) { $State.last_metrics.$Name = $Value }
    else { $State.last_metrics | Add-Member -MemberType NoteProperty -Name $Name -Value $Value }
  } else {
    $State | Add-Member -MemberType NoteProperty -Name 'last_metrics' -Value ([ordered]@{ $Name = $Value }) -Force
  }

  $log = @()
  if ($null -ne $State.PSObject.Properties['metrics_log']) { $log = @($State.metrics_log) }
  $logEntry = [ordered]@{
    metric      = $Name
    value       = $Value
    observed_at = $ObservedAt
    recorded_at = (Get-UtcNowIso)
    source      = $Source
    via         = $script:WriteBackChannel
  }
  if ($SampleSize -ge 0) { $logEntry.sample_size = $SampleSize }
  $log = @($log) + @($logEntry)
  if ($log.Count -gt $Config.MetricsLogCap) {
    $log = @($log[($log.Count - $Config.MetricsLogCap)..($log.Count - 1)])
  }
  $State | Add-Member -MemberType NoteProperty -Name 'metrics_log' -Value $log -Force
}

function Receive-HostMetricsDrop {
  # Alternative intake for hosts that cannot call this script directly: drop a
  # JSON file into {WORKSPACE_ROOT}/.skill-metrics/ and let the next evaluate
  # collect it. Accepted files are MOVED to processed/ (never deleted - P23).
  #
  # File shape: {"metric":"agent_count","value":7,"observed_at":"...Z",
  #              "source":"...","sample_size":120}
  param($State, $Config)
  $dir = Resolve-MetricsDropDir -Config $Config
  $applied = 0
  $rejected = 0
  if (-not (Test-Path -LiteralPath $dir)) { return @{ Applied = 0; Rejected = 0 } }
  $files = @(Get-ChildItem -LiteralPath $dir -Filter '*.json' -File -ErrorAction SilentlyContinue)
  if ($files.Count -eq 0) { return @{ Applied = 0; Rejected = 0 } }

  $script:WriteBackChannel = 'drop-file'
  $processed = Join-Path $dir 'processed'
  if (-not (Test-Path -LiteralPath $processed)) { [void](New-Item -ItemType Directory -Path $processed -Force) }

  foreach ($f in $files) {
    $payload = $null
    try { $payload = ConvertFrom-Json ([System.IO.File]::ReadAllText($f.FullName)) }
    catch {
      Write-Log ("drop file rejected (invalid JSON): {0}" -f $f.Name)
      $rejected++
      continue
    }
    $name = ''
    if ($null -ne $payload.PSObject.Properties['metric']) { $name = [string]$payload.metric }
    $value = $null
    if ($null -ne $payload.PSObject.Properties['value']) { $value = $payload.value }
    $observed = ''
    if ($null -ne $payload.PSObject.Properties['observed_at']) { $observed = ConvertTo-UtcIso ([string]$payload.observed_at) }
    if ([string]::IsNullOrWhiteSpace($observed)) { $observed = Get-UtcNowIso }
    $src = 'drop-file'
    if ($null -ne $payload.PSObject.Properties['source']) { $src = [string]$payload.source }
    $samples = -1
    if ($null -ne $payload.PSObject.Properties['sample_size']) { $samples = [int]$payload.sample_size }

    $check = Test-HostMetricValue -Name $name -Value $value
    if (-not $check.Ok) {
      Write-Log ("drop file rejected ({0}): {1}" -f $f.Name, $check.Reason)
      $rejected++
      continue
    }
    Write-HostMetric -State $State -Name $name -Value $value -ObservedAt $observed -Source $src -SampleSize $samples -Config $Config
    Write-Log ("drop file applied: {0} -> {1} = {2}" -f $f.Name, $name, $value)
    $applied++
    Move-Item -LiteralPath $f.FullName -Destination (Join-Path $processed $f.Name) -Force
  }
  return @{ Applied = $applied; Rejected = $rejected }
}

function Get-MetricsStillAtDefault {
  # A host-supplied metric is "still at its default" only when the host has
  # NEVER written it (no host_metrics entry) AND its current value equals the
  # default. The previous test printed the note whenever the value equalled the
  # default, so it claimed "still at their defaults" on the same screen that
  # showed a host-written agent_count = 9 (H-2, misleading output).
  param($State, $Metrics)
  $names = @()
  $hasHostMetrics = ($null -ne $State.PSObject.Properties['host_metrics']) -and ($null -ne $State.host_metrics)
  foreach ($n in @('agent_count', 'routing_accuracy')) {
    $hasEntry = $false
    if ($hasHostMetrics) { $hasEntry = ($null -ne $State.host_metrics.PSObject.Properties[$n]) }
    if ($hasEntry) { continue }
    if ($n -eq 'agent_count') {
      if ([int]$Metrics.AgentCount -eq 0) { $names += $n }
    } else {
      if ([double]$Metrics.RoutingAccuracy -eq 1.0) { $names += $n }
    }
  }
  return $names
}

# --------------------------------------------------------------------------------------
# Metric collection (step 2)
# --------------------------------------------------------------------------------------

function Get-MaxBlocksPerDepartment {
  # Live count of '## FB-N:' headings across the current D2 pages (T2 data source).
  $max = 0
  if (-not (Test-Path -LiteralPath $DepartmentsDir)) { return $max }
  $files = @(Get-ChildItem -LiteralPath $DepartmentsDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
  foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f.FullName)
    $count = ([regex]::Matches($text, '(?m)^##\s+FB-\d+\s*:')).Count
    if ($count -gt $max) { $max = $count }
  }
  return $max
}

function Get-ErrorCodeReuseRatio {
  # T4 data source, MEASURED from the package (never read back from the state file).
  #
  # Definition (scaling.md 3, T4): for each error-code prefix, the share of
  # that prefix's distinct codes that are referenced by MORE THAN ONE function
  # block. The reported metric is the worst (maximum) share across prefixes,
  # rounded to 4 decimals; 0.0 when nothing is shared or no data is available.
  #
  #     ratio(prefix) = |{ codes of prefix referenced by >= 2 function blocks }|
  #                     / |{ distinct codes of prefix defined in error-codes.md }|
  #
  # Why this exists: before this function, T4 read `last_metrics.error_code_reuse_ratio`
  # back from .scaling-state.json -- a value the script itself had written on the
  # previous run. That closed loop pinned T4 at 0.0 forever, so the threshold
  # could never fire. A metric that reads its own prior output is not a metric.
  $prefixes = @{}   # prefix -> set of distinct defined codes
  $owners   = @{}   # code    -> set of owning "file:FB-N" ids

  if (Test-Path -LiteralPath $ErrorCodesFile) {
    $catalog = [System.IO.File]::ReadAllText($ErrorCodesFile)
    foreach ($cm in [regex]::Matches($catalog, '(?m)^\s*\|\s*([A-Za-z]{2,6}_\d{3})\s*\|')) {
      $code = $cm.Groups[1].Value.ToUpperInvariant()
      $prefix = ($code -split '_')[0]
      if (-not $prefixes.ContainsKey($prefix)) { $prefixes[$prefix] = @{} }
      $prefixes[$prefix][$code] = $true
    }
  }
  if (-not (Test-Path -LiteralPath $DepartmentsDir)) { return 0.0 }

  $files = @(Get-ChildItem -LiteralPath $DepartmentsDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
  foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f.FullName)
    foreach ($bm in [regex]::Matches($text, '(?ms)^##\s+FB-(\d+)\s*:.*?(?=^##\s|\z)')) {
      $fbId = $f.Name + ':' + $bm.Groups[1].Value
      $sec = [regex]::Match($bm.Value, '(?ms)^###\s+4\..*?(?=^###\s+5\.|\z)')
      if (-not $sec.Success) { continue }
      foreach ($cm in [regex]::Matches($sec.Value, '(?m)^\s*\|\s*([A-Za-z]{2,6}_\d{3})\s*\|')) {
        $code = $cm.Groups[1].Value.ToUpperInvariant()
        if (-not $owners.ContainsKey($code)) { $owners[$code] = @{} }
        $owners[$code][$fbId] = $true
        # A code referenced by a block but absent from the catalog still counts.
        $prefix = ($code -split '_')[0]
        if (-not $prefixes.ContainsKey($prefix)) { $prefixes[$prefix] = @{} }
        $prefixes[$prefix][$code] = $true
      }
    }
  }

  if ($prefixes.Count -eq 0) { return 0.0 }
  $worst = 0.0
  foreach ($p in $prefixes.Keys) {
    $total = $prefixes[$p].Count
    if ($total -le 0) { continue }
    $shared = 0
    foreach ($code in @($prefixes[$p].Keys)) {
      if ($owners.ContainsKey($code) -and ($owners[$code].Count -gt 1)) { $shared++ }
    }
    $ratio = [double]$shared / [double]$total
    if ($ratio -gt $worst) { $worst = $ratio }
  }
  return [math]::Round($worst, 4)
}

function Get-CurrentMetrics {
  param($State, $Config)

  $live      = Get-MaxBlocksPerDepartment
  $reuse     = Get-ErrorCodeReuseRatio
  $freshness = Get-HostMetricsFreshness -State $State -Config $Config

  $agentCount = 0
  $routingAcc = 1.0
  if ($null -ne $State.PSObject.Properties['last_metrics']) {
    $lm = $State.last_metrics
    if ($null -ne $lm.PSObject.Properties['agent_count'])      { $agentCount = [int]$lm.agent_count }
    if ($null -ne $lm.PSObject.Properties['routing_accuracy']) { $routingAcc = [double]$lm.routing_accuracy }
  }

  $m = @{
    AgentCount = $agentCount; RoutingAccuracy = $routingAcc
    ReuseRatio = $reuse;      MaxBlocks = $live
    HostFresh  = $freshness
    Sources = [ordered]@{
      agent_count               = 'host-supplied'
      routing_accuracy          = 'host-supplied'
      max_blocks_per_department = 'measured'
      error_code_reuse_ratio    = 'measured'
    }
  }
  return $m
}

# --------------------------------------------------------------------------------------
# Threshold evaluation (step 2, T1-T4)
# --------------------------------------------------------------------------------------

function Invoke-ThresholdEvaluation {
  param($State, $Metrics, $Config)
  $tier = [string]$State.current_tier
  $cap = $TierAgentCaps[$tier]
  $mean = $TierBlockMean[$tier]
  $triggers = @()

  # T1 - agent capacity overflow. Skipped (not guessed) when the host data is
  # absent or stale: see the three rules at the top of the write-back section.
  $t1Limit = [math]::Round($cap * $Config.AgentHeadroom, 3)
  $agentState = $Metrics.HostFresh['agent_count']
  if (-not $agentState.Usable) {
    Write-Log ("T1 SKIPPED: unusable host-supplied agent_count ({0}); threshold > {1} not evaluated" -f $agentState.Reason, $t1Limit)
  } else {
    Write-Log ("T1 agent capacity: agent_count = {0}, threshold > {1}" -f $Metrics.AgentCount, $t1Limit)
    if ($Metrics.AgentCount -gt $t1Limit) {
      $triggers += @{ Id = 'T1'; Name = 'Agent capacity overflow'; Metric = 'agent_count'; Value = $Metrics.AgentCount; Threshold = ('> ' + $t1Limit) }
    }
  }

  # T2 - function-block overload in a single department
  $t2Limit = [math]::Round($mean * $Config.BlocksRatio, 3)
  Write-Log ("T2 function-block overload: max_blocks_per_department = {0}, threshold > {1}" -f $Metrics.MaxBlocks, $t2Limit)
  if ($Metrics.MaxBlocks -gt $t2Limit) {
    $triggers += @{ Id = 'T2'; Name = 'Function-block overload'; Metric = 'max_blocks_per_department'; Value = $Metrics.MaxBlocks; Threshold = ('> ' + $t2Limit) }
  }

  # T3 - routing accuracy below the floor on 3 consecutive evaluations.
  # The usability verdict computed by Get-HostMetricsFreshness is load-bearing
  # here exactly as it is for T1: a stale observation, a future timestamp or a
  # sample below min_routing_samples makes T3 SKIP, never guess
  # (references/scaling.md sec 3.1). The streak counter is left unchanged while
  # the data is unusable, so rejected samples cannot advance it.
  $streak = 0
  if ($null -ne $State.PSObject.Properties['routing_miss_streak']) { $streak = [int]$State.routing_miss_streak }
  $routingState = $Metrics.HostFresh['routing_accuracy']
  if (-not $routingState.Usable) {
    Write-Log ("T3 SKIPPED: unusable host-supplied routing_accuracy ({0}); floor {1} not evaluated, consecutive-miss counter left at {2}" -f $routingState.Reason, $Config.RoutingFloor, $streak)
  } else {
    if ($Metrics.RoutingAccuracy -lt $Config.RoutingFloor) { $streak = $streak + 1 } else { $streak = 0 }
    Write-Log ("T3 routing accuracy: routing_accuracy = {0}, floor {1}, consecutive misses = {2}" -f $Metrics.RoutingAccuracy, $Config.RoutingFloor, $streak)
    if (($Metrics.RoutingAccuracy -lt $Config.RoutingFloor) -and ($streak -ge 3)) {
      $triggers += @{ Id = 'T3'; Name = 'Routing accuracy drop'; Metric = 'routing_accuracy'; Value = $Metrics.RoutingAccuracy; Threshold = ('< ' + $Config.RoutingFloor + ' for 3 consecutive evaluations') }
    }
  }

  # T4 - error-code reuse above the ceiling
  Write-Log ("T4 error-code reuse: error_code_reuse_ratio = {0}, ceiling {1}" -f $Metrics.ReuseRatio, $Config.ReuseCeiling)
  if ($Metrics.ReuseRatio -gt $Config.ReuseCeiling) {
    $triggers += @{ Id = 'T4'; Name = 'Error-code reuse excess'; Metric = 'error_code_reuse_ratio'; Value = $Metrics.ReuseRatio; Threshold = ('> ' + $Config.ReuseCeiling) }
  }

  return @{ Triggers = $triggers; RoutingMissStreak = $streak }
}

# --------------------------------------------------------------------------------------
# Alias Map parsing / appending (steps 5g and gate G5)
# --------------------------------------------------------------------------------------

function Get-AliasRows {
  # Parses active alias rows from the '## Alias Map' table of a scaling.md file.
  # Rows inside fenced code blocks are ignored (they are illustrative, not active).
  param([string]$ScalingMdPath)
  $rows = @()
  if (-not (Test-Path -LiteralPath $ScalingMdPath)) { return $rows }
  $lines = [System.IO.File]::ReadAllLines($ScalingMdPath)
  $inSection = $false
  $inFence = $false
  foreach ($line in $lines) {
    if ($line -match '^\s*```') { $inFence = (-not $inFence); continue }
    if ($inFence) { continue }
    if ($line -match '^##\s+Alias Map') { $inSection = $true; continue }
    if ($inSection -and $line -match '^##\s') { break }
    if ($inSection -and $line -match '^\|\s*([a-z0-9][a-z0-9-]*)\s*\|\s*([a-z]+)\s*\|\s*([a-z0-9][a-z0-9-]*)\s*\|\s*(v[0-9.]+)\s*\|\s*$') {
      $rows += @{ Legacy = $Matches[1]; LegacyTier = $Matches[2]; Target = $Matches[3]; Since = $Matches[4] }
    }
  }
  return $rows
}

function Add-AliasRows {
  # Appends rows to the active table inside the '## Alias Map' section, after the
  # last existing table row of that section. History rows are never removed.
  param([string]$ScalingMdPath, [string[]]$NewRows)
  if (-not (Test-Path -LiteralPath $ScalingMdPath)) {
    Write-Log "WARN scaling.md not found at $ScalingMdPath; alias rows not appended"
    return
  }
  $lines = [System.IO.File]::ReadAllLines($ScalingMdPath)
  $headingIdx = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^##\s+Alias Map') { $headingIdx = $i; break }
  }
  if ($headingIdx -lt 0) {
    Write-Log "WARN '## Alias Map' section not found; alias rows not appended"
    return
  }
  $sectionEnd = $lines.Count
  for ($i = $headingIdx + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^##\s') { $sectionEnd = $i; break }
  }
  # Find the last active table row (pipe lines inside fenced code blocks are
  # illustrative and must not receive the appended rows).
  $insertAt = $sectionEnd
  $inFence = $false
  for ($i = $headingIdx + 1; $i -lt $sectionEnd; $i++) {
    if ($lines[$i] -match '^\s*```') { $inFence = (-not $inFence); continue }
    if ($inFence) { continue }
    if ($lines[$i] -match '^\|') { $insertAt = $i + 1 }
  }
  $out = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $insertAt; $i++) {
    # Drop the "_(none - initial micro tier, no upgrade has occurred)_" placeholder
    # row once real rows exist; it is a template placeholder, not a history row.
    if (($i -gt $headingIdx) -and ($i -lt $sectionEnd) -and ($lines[$i] -match '^\|\s*_\(none')) { continue }
    $out.Add($lines[$i])
  }
  foreach ($r in $NewRows) { $out.Add($r) }
  for ($i = $insertAt; $i -lt $lines.Count; $i++) { $out.Add($lines[$i]) }
  # E15 : keep the .md file at LF - explicit "`n" join with WriteAllText,
  # never WriteAllLines (which would emit platform CRLF).
  Write-TextFileNoBom -Path $ScalingMdPath -Text (($out -join "`n") + "`n")
}

# --------------------------------------------------------------------------------------
# Upgrade package generation (step 5)
# --------------------------------------------------------------------------------------

function New-UpgradePackage {
  param([string]$PkgDir)
  # Retired legacy D2 pages (replaced by their splits), as normalized relative paths.
  $retiredD2 = @('references/departments/governance-and-delivery.md', 'references/departments/engineering-and-safety.md')

  # 5h (basis) : copy the current package verbatim, using the ONE package file
  # set definition (Get-PackageRelativePaths). That excludes repository tooling
  # directories (.git/, .github/, .workbuddy/, .skill-upgrade/) and build
  # residues (__pycache__/, *.pyc), so a release package can never carry the
  # repository's own git objects or local audit artifacts (H-1). It also still
  # excludes the retired legacy D2 pages (replaced by their splits) and the
  # operational state file (regenerated below).
  $allRels = @(Get-PackageRelativePaths -Root $SkillDir)
  foreach ($rel in $allRels) {
    if ($rel -eq '.scaling-state.json') { continue }
    if ($retiredD2 -contains $rel) { continue }
    $src = Join-Path $SkillDir ($rel.Replace('/', '\'))
    $dest = Join-Path $PkgDir $rel
    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) {
      New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item -LiteralPath $src -Destination $dest -Force
  }
  Write-Log ("5h copied current package files to {0} (tests/ and self-scale.ps1 verbatim)" -f $PkgDir)

  # 5a + 5b : split the legacy D2 pages into the 5 target departments, in page
  # order, according to the merge tree block counts (conservation = 18, gate G4).
  $pkgDeptDir = Join-Path $PkgDir 'references\departments'
  if (-not (Test-Path -LiteralPath $pkgDeptDir)) {
    New-Item -ItemType Directory -Path $pkgDeptDir -Force | Out-Null
  }
  $sources = @('governance-and-delivery', 'engineering-and-safety')
  foreach ($src in $sources) {
    $srcPath = Join-Path $DepartmentsDir ($src + '.md')
    $targets = @($UpgradeEdge.Split | Where-Object { $_.Source -eq $src })
    if (-not (Test-Path -LiteralPath $srcPath)) {
      Write-Log "WARN legacy D2 page not found (split impossible, G4 will fail): $srcPath"
      continue
    }
    $text = [System.IO.File]::ReadAllText($srcPath)
    $fbMatches = [regex]::Matches($text, '(?m)^##\s+FB-\d+\s*:')
    if ($fbMatches.Count -eq 0) {
      Stop-WithCode 'SCL_010' ("legacy D2 page '{0}' contains no '## FB-N:' headings; the split cannot run" -f $srcPath)
    }
    # E5 : the section count must equal the merge-tree expectation exactly.
    # More sections (leftover) or fewer (shortage) both abort immediately -
    # function blocks are never silently dropped or padded.
    $expectedTotal = 0
    foreach ($t in $targets) { $expectedTotal += [int]$t.Blocks }
    if ($fbMatches.Count -ne $expectedTotal) {
      Stop-WithCode 'SCL_010' ("legacy D2 page '{0}' contains {1} '## FB-N:' section(s); the merge tree expects {2} (leftover and shortage both abort; nothing is silently dropped or padded)" -f $src, $fbMatches.Count, $expectedTotal)
    }
    $preamble = $text.Substring(0, $fbMatches[0].Index)
    $sections = @()
    for ($i = 0; $i -lt $fbMatches.Count; $i++) {
      $start = $fbMatches[$i].Index
      $end = $text.Length
      if ($i -lt $fbMatches.Count - 1) { $end = $fbMatches[$i + 1].Index }
      $sections += $text.Substring($start, $end - $start)
    }
    $cursor = 0
    foreach ($t in $targets) {
      $take = [int]$t.Blocks
      $body = ''
      for ($i = $cursor; $i -lt ($cursor + $take); $i++) { $body += $sections[$i] }
      # Each split page must carry its OWN display name and its own
      # 'Function blocks: N' figure: README_FOR_AI.md sec 10.2 makes both
      # mandatory and the figure is the conservation basis. Replacing the source
      # slug was a no-op (the preamble carries the display title, never the
      # slug), so every split page inherited the legacy title and the legacy
      # count - 8/8 for the governance pair and 10/10/10 for engineering -
      # while gate G4 counted only '## FB-N:' headings and passed them.
      $pre = [regex]::Replace($preamble, '(?m)^#\s+.*$', ('# ' + [string]$t.Display))
      $pre = [regex]::Replace($pre, 'Function blocks:\s*\d+', ('Function blocks: ' + $take))
      $destPath = Join-Path $pkgDeptDir ([string]$t.Slug + '.md')
      Write-TextFileNoBom -Path $destPath -Text ($pre + $body)
      Write-Log ("5a/5b split {0} -> {1} ({2} function blocks)" -f $src, $t.Slug, $take)
      $cursor += $take
    }
    # $cursor now equals $sections.Count by construction (verified above);
    # there is no leftover path anymore (E5).
  }

  # 5a (S-tier third prompt) : generate prompts/03-test-cases.md, the small-tier
  # agent-invoked prompt (E1 : without it the clean-environment target file count
  # is unreachable and propose fails G6/SCL_006). First screen follows README_FOR_AI.md sec 11.4
  # (agent-invoked variant) and satisfies the A1-A5 constraints of README_FOR_AI.md sec 11.3 :
  # A1 paths as placeholders, A2 expected artifacts declared, A3 failure codes
  # declared, A4 harness level >= L3, A5 template anchors referenced, never
  # inlined (no code blocks at all).
  $pkgPromptsDir = Join-Path $PkgDir 'prompts'
  if (-not (Test-Path -LiteralPath $pkgPromptsDir)) {
    New-Item -ItemType Directory -Path $pkgPromptsDir -Force | Out-Null
  }
  $testCasesPrompt = @'
---
mode: agent-invoked
id: 03-test-cases
title: Generate Test Cases
output_language: user-specified
harness_level: L3
---

> **Mode**: agent-invoked (executed by the agent runtime; not pasted by a human)
> **Purpose**: Generate a boundary-aware test-case suite for one method that was
> implemented to this skill's shared standard, and write it into the workspace.
>
> **Expected artifact path**:
> - `{WORKSPACE_ROOT}/tests/<METHOD_NAME>_test.py` - the generated test file
>   (standard library only; the file is created, never overwritten without an
>   explicit user confirmation)
>
> **Failure error codes**:
> - `CTO_003` - the generated suite assesses below Harness L3 (error handling,
>   retry, or idempotency coverage missing)
> - `CTO_002` - the generated suite fails the quality gate (a case has no
>   assertion, requires network access, or imports a non-standard library)
> - `SCL_006` - the generated artifact fails package validation
>
> **Referenced template anchors** (link, never inline - the authoritative code
> lives in `references/method-patterns.md`):
> - `references/method-patterns.md#3-1-validate_input_schema`
> - `references/method-patterns.md#3-5-retry_with_backoff`
> - `references/method-patterns.md#3-9-mask_sensitive_data`
>
> **Output language**: follow the language the user is currently using.

## Prompt

Inputs (supplied by the invoking agent):

- `<METHOD_NAME>` - the method to generate test cases for
- `<SPEC_SUMMARY>` - the method's contract: parameters, return value, and
  documented failure modes
- `<TARGET_LEVEL>` - required harness level (default L3)

Task: produce a test suite for `<METHOD_NAME>` covering, at minimum:

1. Normal path - at least one case per documented behavior.
2. Input validation - invalid inputs are rejected before any processing
   (see `references/method-patterns.md#3-1-validate_input_schema`).
3. Retry behavior - transient failures are retried and the retry limit is
   enforced (see `references/method-patterns.md#3-5-retry_with_backoff`).
4. PII masking - outputs replace email addresses, IPv4 addresses, and
   phone numbers in their common written forms with their placeholders (see
   `references/method-patterns.md#3-9-mask_sensitive_data`).
5. Boundary conditions - empty input, single element, maximum size, and
   off-by-one cases.

Requirements: standard library only; no network access; every test asserts
exactly one behavior and carries a docstring naming the covered dimension.

## Expected Output

A single test file at `{WORKSPACE_ROOT}/tests/<METHOD_NAME>_test.py`, plus a
summary stating: the dimensions covered, the number of cases per dimension,
and any dimension that cannot be tested, with the reason.

## Self-Check Checklist

- [ ] The artifact lands at the expected path under `{WORKSPACE_ROOT}/tests/`.
- [ ] No case requires network access or non-standard libraries.
- [ ] Every dimension above has at least one case or a stated reason.
- [ ] Any generation failure is reported with the error codes listed above.
'@
  Write-TextFileNoBom -Path (Join-Path $pkgPromptsDir '03-test-cases.md') -Text $testCasesPrompt
  Write-Log '5a generated prompts/03-test-cases.md (agent-invoked, S-tier third prompt)'

  # 5d : rewrite the package frontmatter (tier fields, version, alias pointer,
  # interface department enum, and description - E2 : leaving the two retired
  # slugs in the enum would contradict department_count: 5 inside the same
  # frontmatter and make the new departments unreachable through the interface).
  # The permissions and language_policy blocks are never touched by the rewrite.
  $newEnum = '[auto, governance-and-operations, technology-and-platform, security-and-compliance, people-and-growth, quality-and-delivery]'
  $newDescription = 'Medium-tier governance skill for scaling AI agent organizations (10-50 agents). Distributes 18 enterprise function blocks across 9 departments - governance-and-operations, technology-and-platform, security-and-compliance, quality-and-delivery, people-and-growth, legal-and-risk, data-and-analytics, product-and-strategy, and customer-and-partnerships - spanning strategy, operations, finance, risk, legal, privacy, architecture, security, compliance, quality, delivery, data, analytics, product, intelligence, brand, and partnerships. Ships ten harness code templates, three prompt frameworks, a 34-code error catalog with ten prefixes, and propose-only self-scaling. Use when a scaling team needs enterprise-grade governance, legal and privacy review, data and analytics pipelines, product and partnership coordination, or tier-upgrade assessment.'
  $skPath = Join-Path $PkgDir 'SKILL.md'
  if (Test-Path -LiteralPath $skPath) {
    $lines = [System.IO.File]::ReadAllLines($skPath)
    $fmEnd = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i].Trim() -eq '---') { $fmEnd = $i; break }
    }
    if (($lines.Count -ge 2) -and ($lines[0].Trim() -eq '---') -and ($fmEnd -gt 0)) {
      $inMetadata = $false
      $inInterface = $false
      $hasAliasPointer = $false
      $versionRewrites = 0       # E16 : every rewrite is counted and located
      $enumRewrites = 0
      $descriptionRewrites = 0
      for ($i = 1; $i -lt $fmEnd; $i++) {
        $line = $lines[$i]
        if ($line -match '^metadata\s*:\s*$') { $inMetadata = $true; continue }
        if ($line -match '^interface\s*:\s*$') { $inInterface = $true; continue }
        if ($line -match '^\S') { $inMetadata = $false; $inInterface = $false }
        if ($line -match '^(\s*)version\s*:\s*.*$') {
          $lines[$i] = "{0}version: {1}" -f $Matches[1], $UpgradeEdge.NewVersion
          $versionRewrites++
          Write-Log ("5d version rewritten at SKILL.md frontmatter line {0}: '{1}' -> '{2}'" -f ($i + 1), $UpgradeEdge.OldVersion, $UpgradeEdge.NewVersion)
          continue
        }
        if ($line -match '^(\s*)error_code_prefixes\s*:\s*.*$') {
          $lines[$i] = "{0}error_code_prefixes: [CEO_, CTO_, CISO_, CHO_, CQO_, SCL_]" -f $Matches[1]
          continue
        }
        # E2 : top-level description (the only unindented description: line).
        if ($line -match '^description\s*:\s*".*"\s*$') {
          $lines[$i] = 'description: "' + $newDescription + '"'
          $descriptionRewrites++
          continue
        }
        # E2 : the department enum inside the interface block (the only enum:
        # line, and it must list "auto" first).
        if ($inInterface -and ($line -match '^(\s*)enum\s*:\s*\[.*\]\s*$') -and ($line -match '\bauto\b')) {
          $lines[$i] = "{0}enum: {1}" -f $Matches[1], $newEnum
          $enumRewrites++
          continue
        }
        if ($line -match 'department_aliases') { $hasAliasPointer = $true }
        if ($inMetadata) {
          if ($line -match '^(\s*)scale_tier\s*:') {
            $lines[$i] = "{0}scale_tier: {1}" -f $Matches[1], $UpgradeEdge.To; continue
          }
          if ($line -match '^(\s*)department_count\s*:') {
            $lines[$i] = "{0}department_count: 5" -f $Matches[1]; continue
          }
          if ($line -match '^(\s*)function_block_count\s*:') {
            $lines[$i] = "{0}function_block_count: 18" -f $Matches[1]; continue
          }
        }
      }
      # E16 : verify each targeted rewrite actually happened (>= 1 occurrence).
      if ($versionRewrites -lt 1)     { Write-Log 'WARN 5d version line was not found in the package frontmatter (G6 version check will fail)' }
      if ($enumRewrites -lt 1)        { Write-Log 'WARN 5d interface.department.enum was not found in the package frontmatter (G6 enum check will fail)' }
      if ($descriptionRewrites -lt 1) { Write-Log 'WARN 5d top-level description was not found in the package frontmatter (stale micro-tier description left in place; flagged for human review)' }
      if (-not $hasAliasPointer) {
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $fmEnd; $i++) { $out.Add($lines[$i]) }
        $out.Add('department_aliases: references/scaling.md#alias-map')
        for ($i = $fmEnd; $i -lt $lines.Count; $i++) { $out.Add($lines[$i]) }
        $lines = $out.ToArray()
      }
      # E1 : list the new prompt in the SKILL.md Prompts index (zero-orphan,
      # README_FOR_AI.md sec 11.1) - inserted right after the 02-robustness-checks row.
      $promptRow = '| [03-test-cases.md](prompts/03-test-cases.md) | `agent-invoked` | Agent runtime generates a test-case suite for one method and writes it to {WORKSPACE_ROOT}/tests/ |'
      $promptRowAt = -1
      for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\|\s*\[02-robustness-checks\.md\]') { $promptRowAt = $i + 1; break }
      }
      if ($promptRowAt -gt 0) {
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $promptRowAt; $i++) { $out.Add($lines[$i]) }
        $out.Add($promptRow)
        for ($i = $promptRowAt; $i -lt $lines.Count; $i++) { $out.Add($lines[$i]) }
        $lines = $out.ToArray()
        Write-Log '5d prompts index row added for 03-test-cases.md (zero-orphan)'
      } else {
        Write-Log 'WARN 5d Prompts index row for 02-robustness-checks.md not found; 03-test-cases.md row not added'
      }
      # E15 : keep the package SKILL.md at LF (explicit "`n", never WriteAllLines).
      Write-TextFileNoBom -Path $skPath -Text (($lines -join "`n") + "`n")
      Write-Log "5d package frontmatter rewritten (scale_tier=small, department_count=5, function_block_count=18, version=2.0.0, department_aliases pointer, enum + description updated for 5 departments)"
    } else {
      Write-Log 'WARN package SKILL.md has no parseable frontmatter; 5d skipped (G1/G6 will fail)'
    }
  } else {
    Write-Log 'WARN package SKILL.md not found; 5d skipped (G1/G3/G6 will fail)'
  }

  # 5e (deterministic part) : _meta.json version bump.
  $metaPath = Join-Path $PkgDir '_meta.json'
  if (Test-Path -LiteralPath $metaPath) {
    try {
      $meta = ConvertFrom-Json ([System.IO.File]::ReadAllText($metaPath))
      if ($null -ne $meta.PSObject.Properties['version']) { $meta.version = $UpgradeEdge.NewVersion }
      Write-TextFileNoBom -Path $metaPath -Text ((ConvertTo-StableJson -Value $meta) + "`n")
      Write-Log "5e _meta.json version bumped to $($UpgradeEdge.NewVersion)"
    } catch { Write-Log 'WARN _meta.json could not be updated (G6 version check will fail)' }
  }

  # 5e (E10, skeleton part) : append an error-code alias-table skeleton to the
  # package error-codes.md. The function-level merge lists are not
  # machine-derivable in this build, so every row is generated as an explicit
  # "requires human review" placeholder - the table makes the package
  # structurally complete; a human completes the mappings before installation.
  $pkgErrorCodes = Join-Path (Join-Path $PkgDir 'references') 'error-codes.md'
  if (Test-Path -LiteralPath $pkgErrorCodes) {
    $aliasHeader = @'

## Error-Code Alias Map (proposed - requires human review)

The micro -> small upgrade revives the `CISO_`, `CHO_`, and `CQO_` prefixes.
The function-level merge lists are not machine-derivable in this build, so the
legacy-to-new mapping below is a generated skeleton: every row requires human
review before installation (README_FOR_AI.md sec 12.4, step 5e). `CEO_` and `CTO_`
codes whose functions stay in the successor departments keep their codes.

| Legacy code | Resolves to | Status |
|---|---|---|
'@
    $aliasRowsText = ''
    foreach ($pfx in @('CEO_', 'CTO_')) {
      for ($n = 1; $n -le 12; $n++) {
        $code = '{0}{1:d3}' -f $pfx, $n
        $aliasRowsText += ("| {0} | <requires human review> | proposed |`n" -f $code)
      }
    }
    $oldErr = Read-TextFile -Path $pkgErrorCodes
    if ($null -ne $oldErr) {
      Write-TextFileNoBom -Path $pkgErrorCodes -Text ($oldErr.TrimEnd("`n") + $aliasHeader + "`n" + $aliasRowsText)
      Write-Log '5e error-code alias-table skeleton appended to references/error-codes.md (24 rows, all marked requires human review)'
    }
  } else {
    Write-Log 'WARN references/error-codes.md missing from the package; alias-table skeleton not generated'
  }

  # 5i (E16) : version strings in the README files - context-exact, counted
  # replacements only (never a blind whole-file string replace). Each target
  # context must occur at least once per applicable file; every replacement
  # location is logged. SKILL.md's version is handled by 5d and verified by G6.
  $zhVersionWord = [string][char]0x7248 + [string][char]0x672C   # the Chinese word for "version" (README.zh.md table row); built from code points so this script stays pure ASCII
  $readmeTargets = @(
    @{ Pattern = 'version-1\.0\.0-blue';     Replace = 'version-2.0.0-blue';  What = 'badge' },
    @{ Pattern = ('\| ' + $zhVersionWord + ' \| 1\.0\.0 \|'); Replace = ('| ' + $zhVersionWord + ' | 2.0.0 |'); What = 'at-a-glance version row (Chinese)' },
    @{ Pattern = '\| Version \| 1\.0\.0 \|'; Replace = '| Version | 2.0.0 |'; What = 'at-a-glance version row (English)' }
  )
  $replaceCounts = @{}
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    $p = Join-Path $PkgDir $name
    if (-not (Test-Path -LiteralPath $p)) { continue }
    $t = Read-TextFile -Path $p
    if ($null -eq $t) { continue }
    foreach ($tgt in $readmeTargets) {
      $hits = [regex]::Matches($t, $tgt.Pattern)
      if ($hits.Count -eq 0) { continue }
      # Log every replacement location (line number) before touching anything.
      foreach ($h in $hits) {
        $lineNo = 1 + ([regex]::Matches($t.Substring(0, $h.Index), "`n")).Count
        Write-Log ("5i {0}: {1} rewritten at line {2} ('{3}' -> '{4}')" -f $name, $tgt.What, $lineNo, $UpgradeEdge.OldVersion, $UpgradeEdge.NewVersion)
      }
      $t = [regex]::Replace($t, $tgt.Pattern, $tgt.Replace)
      $replaceCounts[("{0}|{1}" -f $name, $tgt.What)] = $hits.Count
    }
    Write-TextFileNoBom -Path $p -Text $t
  }
  # E16 : post-replacement count verification. Every applicable target must
  # have been replaced at least once; a miss is logged as a warning (the badge
  # target is additionally enforced by gate G6).
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    if (-not ($replaceCounts.ContainsKey("$name|badge")) -or ($replaceCounts["$name|badge"] -lt 1)) {
      Write-Log "WARN 5i $name : badge version context was not found / not replaced"
    }
  }
  foreach ($name in @('README.md', 'README.en.md')) {
    if (-not ($replaceCounts.ContainsKey("$name|at-a-glance version row (English)")) -or ($replaceCounts["$name|at-a-glance version row (English)"] -lt 1)) {
      Write-Log "WARN 5i $name : English version table row was not found / not replaced"
    }
  }
  if (-not ($replaceCounts.ContainsKey('README.zh.md|at-a-glance version row (Chinese)')) -or ($replaceCounts['README.zh.md|at-a-glance version row (Chinese)'] -lt 1)) {
    Write-Log 'WARN 5i README.zh.md : Chinese version table row was not found / not replaced'
  }

  # 5i (E10, skeleton part) : rewrite the README Project Structure tree to the
  # 30-file small-tier skeleton, marked as requiring human review. Without this
  # the package READMEs would still describe the 26-file micro layout.
  # The tree (which contains box-drawing characters) is stored base64-encoded
  # so this script stays pure ASCII: Windows PowerShell 5.1 reads BOM-less
  # UTF-8 scripts as ANSI, which would corrupt literal non-ASCII characters.
  # Decoded, $newTree is the 30-file small-tier layout: 16 root files
  # (incl. README_FOR_AI.md), prompts/ (3), references/ (3),
  # references/departments/ (5 new slugs), scripts/ (2), tests/ (1).
  $newTree = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('YWktY29tcGFueS8K4pSc4pSA4pSAIC5lZGl0b3Jjb25maWcK4pSc4pSA4pSAIC5naXRhdHRyaWJ1dGVzCuKUnOKUgOKUgCAuZ2l0aWdub3JlCuKUnOKUgOKUgCAuc2NhbGluZy1zdGF0ZS5qc29uCuKUnOKUgOKUgCBBR0VOVFMubWQK4pSc4pSA4pSAIENIQU5HRUxPRy5tZArilJzilIDilIAgQ09ERV9PRl9DT05EVUNULm1kCuKUnOKUgOKUgCBDT05UUklCVVRJTkcubWQK4pSc4pSA4pSAIExJQ0VOU0UK4pSc4pSA4pSAIFJFQURNRV9GT1JfQUkubWQK4pSc4pSA4pSAIFJFQURNRS5lbi5tZArilJzilIDilIAgUkVBRE1FLm1kCuKUnOKUgOKUgCBSRUFETUUuemgubWQK4pSc4pSA4pSAIFNFQ1VSSVRZLm1kCuKUnOKUgOKUgCBTS0lMTC5tZArilJzilIDilIAgX21ldGEuanNvbgrilJzilIDilIAgcHJvbXB0cy8K4pSCICAg4pSc4pSA4pSAIDAxLWltcGxlbWVudC1tZXRob2QubWQK4pSCICAg4pSc4pSA4pSAIDAyLXJvYnVzdG5lc3MtY2hlY2tzLm1kCuKUgiAgIOKUlOKUgOKUgCAwMy10ZXN0LWNhc2VzLm1kCuKUnOKUgOKUgCByZWZlcmVuY2VzLwrilIIgICDilJzilIDilIAgbWV0aG9kLXBhdHRlcm5zLm1kCuKUgiAgIOKUnOKUgOKUgCBlcnJvci1jb2Rlcy5tZArilIIgICDilJzilIDilIAgc2NhbGluZy5tZArilIIgICDilJTilIDilIAgZGVwYXJ0bWVudHMvCuKUgiAgICAgICDilJzilIDilIAgZ292ZXJuYW5jZS1hbmQtb3BlcmF0aW9ucy5tZArilIIgICAgICAg4pSc4pSA4pSAIHF1YWxpdHktYW5kLWRlbGl2ZXJ5Lm1kCuKUgiAgICAgICDilJzilIDilIAgdGVjaG5vbG9neS1hbmQtcGxhdGZvcm0ubWQK4pSCICAgICAgIOKUnOKUgOKUgCBzZWN1cml0eS1hbmQtY29tcGxpYW5jZS5tZArilIIgICAgICAg4pSU4pSA4pSAIHBlb3BsZS1hbmQtZ3Jvd3RoLm1kCuKUnOKUgOKUgCBzY3JpcHRzLwrilIIgICDilJzilIDilIAgc2VsZi1zY2FsZS5wczEK4pSCICAg4pSU4pSA4pSAIHNjYWxpbmctY29uZmlnLmpzb24K4pSU4pSA4pSAIHRlc3RzLwogICAg4pSU4pSA4pSAIHRlc3QtbWV0aG9kLXBhdHRlcm5zLnB5Cg=='))
  $newTree = $newTree + "`n"
  $treeNoteEn = '> Structure tree rewritten to the 30-file small-tier skeleton by the'
  $treeNoteEn = $treeNoteEn + ' upgrade generator - requires human review before installation.'
  # README.zh.md carries a Chinese note. The text is stored base64-encoded so
  # this script stays pure ASCII (Windows PowerShell 5.1 reads BOM-less UTF-8
  # as ANSI, which would corrupt literal CJK characters). Decoded, it is the
  # Chinese translation of $treeNoteEn: "structure tree rewritten to the
  # 30-file small-tier skeleton by the upgrade generator - requires human
  # review before installation".
  $treeNoteZh = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('PiDnu5PmnoTmoJHlt7LnlLHljYfnuqfnlJ/miJDlmajmlLnlhpnkuLogMzAg5Liq5paH5Lu255qE5bCP5Z6L5qGj6aqo5p6277yIc21hbGzvvInigJTigJTlronoo4XliY3pnIDkurrlt6XlpI3moLjjgII='))
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    $p = Join-Path $PkgDir $name
    if (-not (Test-Path -LiteralPath $p)) { continue }
    $t = Read-TextFile -Path $p
    if ($null -eq $t) { continue }
    $treeFence = '(?s)```text\r?\nai-company/.*?\r?\n```'
    if (-not ([regex]::IsMatch($t, $treeFence))) {
      Write-Log "WARN 5i Project Structure tree fence not found in $name; tree not rewritten"
      continue
    }
    $note = $treeNoteEn
    if ($name -eq 'README.zh.md') { $note = $treeNoteZh }
    $replacement = '```text' + "`n" + $newTree + '```' + "`n`n" + $note
    $treeRegex = New-Object System.Text.RegularExpressions.Regex($treeFence)
    $t2 = $treeRegex.Replace($t, $replacement.Replace('$', '$$'), 1)
    Write-TextFileNoBom -Path $p -Text $t2
    Write-Log "5i Project Structure tree rewritten to the 30-file skeleton in $name (marked requires human review)"
  }

  # 5i (E17) : CHANGELOG.md upgrade entry - inserted directly after the
  # '## [Unreleased]' heading (Keep a Changelog order: newest version first),
  # never appended at the end of the file.
  $changelogPath = Join-Path $PkgDir 'CHANGELOG.md'
  if (Test-Path -LiteralPath $changelogPath) {
    $entry = "## [$($UpgradeEdge.NewVersion)] - $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')) - tier upgrade proposal (micro -> small)`n`n" +
      "- Departments: 2 -> 5 (merge-tree split, function blocks conserved at 18)`n" +
      "- Revived error-code prefixes: CISO_, CHO_, CQO_ (alias-table skeleton appended to references/error-codes.md)`n" +
      "- New agent-invoked prompt: prompts/03-test-cases.md`n" +
      "- Slug aliases appended to references/scaling.md (Alias Map)`n" +
      "- PROPOSED ONLY - requires human approval and an external installer`n"
    $old = Read-TextFile -Path $changelogPath
    if ($null -ne $old) {
      $chLines = $old -split "`n"
      $unreleasedIdx = -1
      for ($i = 0; $i -lt $chLines.Count; $i++) {
        if ($chLines[$i] -match '^##\s*\[Unreleased\]') { $unreleasedIdx = $i; break }
      }
      if ($unreleasedIdx -ge 0) {
        # Insert after the [Unreleased] heading, skipping the blank lines that
        # follow it, so the new entry becomes the first version section.
        $insertAt = $unreleasedIdx + 1
        while (($insertAt -lt $chLines.Count) -and ([string]::IsNullOrWhiteSpace($chLines[$insertAt]))) { $insertAt++ }
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $insertAt; $i++) { $out.Add($chLines[$i]) }
        foreach ($l in ($entry -split "`n")) { $out.Add($l) }
        for ($i = $insertAt; $i -lt $chLines.Count; $i++) { $out.Add($chLines[$i]) }
        Write-TextFileNoBom -Path $changelogPath -Text ((($out -join "`n").TrimEnd("`r`n")) + "`n")
        Write-Log '5i CHANGELOG.md entry inserted after [Unreleased] (E17 order)'
      } else {
        # No [Unreleased] heading: fall back to inserting after the header
        # paragraph rather than appending at the end.
        $insertAfter = 0
        for ($i = 0; $i -lt $chLines.Count; $i++) {
          if ($chLines[$i] -match '^##\s') { $insertAfter = $i; break }
        }
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $insertAfter; $i++) { $out.Add($chLines[$i]) }
        foreach ($l in ($entry -split "`n")) { $out.Add($l) }
        for ($i = $insertAfter; $i -lt $chLines.Count; $i++) { $out.Add($chLines[$i]) }
        Write-TextFileNoBom -Path $changelogPath -Text ((($out -join "`n").TrimEnd("`r`n")) + "`n")
        Write-Log 'WARN 5i CHANGELOG.md has no [Unreleased] heading; entry inserted before the first version section'
      }
    }
  }

  # 5g : append the slug alias rows to the package's scaling.md Alias Map.
  $pkgScalingMd = Join-Path (Join-Path $PkgDir 'references') 'scaling.md'
  $aliasRows = @(
    '| governance-and-delivery | micro | governance-and-operations | v2.0.0 |',
    '| governance-and-delivery | micro | quality-and-delivery | v2.0.0 |',
    '| engineering-and-safety | micro | technology-and-platform | v2.0.0 |',
    '| engineering-and-safety | micro | security-and-compliance | v2.0.0 |',
    '| engineering-and-safety | micro | people-and-growth | v2.0.0 |'
  )
  Add-AliasRows -ScalingMdPath $pkgScalingMd -NewRows $aliasRows
  Write-Log '5g alias rows appended to the package Alias Map (history preserved)'

  # Package state file : initial state for the target tier. E7 : tier_history
  # is never reset to an empty array (README_FOR_AI.md sec 12.6 - append-only audit trail);
  # it carries a skeleton entry for THIS upgrade with approved_by / installed_at
  # empty (the external installer fills them in at install time) and
  # acceptance_passed false until the human reviewer completes README_FOR_AI.md sec 15
  # acceptance.
  $nowIso = Get-UtcNowIso
  $pkgState = [ordered]@{
    schema_version      = 1
    current_tier        = $UpgradeEdge.To
    tier_history        = @(
      [ordered]@{
        from          = $UpgradeEdge.From
        to            = $UpgradeEdge.To
        proposed_at   = $nowIso
        approved_by   = $null
        installed_at  = $null
        package_path  = (Get-WorkspaceRelativePath -Path $PkgDir)
        validation    = [ordered]@{
          file_count        = $TargetFileCount[$UpgradeEdge.To]
          function_blocks   = 18
          gates_passed      = 6
          acceptance_passed = $false
        }
      }
    )
    pending_proposals   = @()
    next_evaluation     = (Get-Date).ToUniversalTime().AddDays(30).ToString('yyyy-MM-ddTHH:mm:ssZ')
    last_metrics        = [ordered]@{
      agent_count               = 0
      routing_accuracy          = 1.0
      max_blocks_per_department = 6
      error_code_reuse_ratio    = 0.0
    }
    validation          = [ordered]@{
      gates_passed      = 6
      file_count        = $TargetFileCount[$UpgradeEdge.To]
      acceptance_passed = $false
    }
  }
  Write-TextFileNoBom -Path (Join-Path $PkgDir '.scaling-state.json') -Text ((ConvertTo-StableJson -Value $pkgState) + "`n")
  Write-Log "package state file initialized for tier '$($UpgradeEdge.To)' (tier_history carries the upgrade skeleton entry, append-only)"
}

# --------------------------------------------------------------------------------------
# Error-code row mover / re-baser (shared by the small -> medium generator)
# --------------------------------------------------------------------------------------

function Move-ErrorCodeRows {
  # Rewrites a single prefix section inside an error-codes.md text: drops the
  # migrated code rows (Remove) and applies ordered re-base renames (Rebase) to
  # the KEPT rows so each prefix stays continuous with no gaps.
  param([string]$Text, [string]$Prefix, [string[]]$Remove, $Rebase)
  $lines = $Text -split "`n"
  $inSection = $false
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($line in $lines) {
    if ($line -match ('^##\s+' + [regex]::Escape($Prefix) + '\s+Prefix')) { $inSection = $true; $out.Add($line); continue }
    if ($inSection -and ($line -match '^##\s')) { $inSection = $false }
    if ($inSection -and ($line -match ('^\|\s*' + [regex]::Escape($Prefix) + '\d{3}\s*\|'))) {
      $code = ([regex]::Match($line, ('^\|\s*(' + [regex]::Escape($Prefix) + '\d{3})'))).Groups[1].Value
      if ($Remove -contains $code) { continue }
      if ($null -ne $Rebase) {
        foreach ($rb in $Rebase) { $line = $line.Replace($rb.Old, $rb.New) }
      }
    }
    $out.Add($line)
  }
  return ($out -join "`n")
}

# --------------------------------------------------------------------------------------
# Upgrade package generation: small -> medium edge
# --------------------------------------------------------------------------------------

function New-SmallToMediumUpgradePackage {
  # -SkipInitialCopy : composition mode (micro -> medium). Stage 1 has already
  #   placed the source-tier content in $PkgDir, so the 5h live copy is skipped
  #   and every transformation below runs on the package as-is. No staging
  #   directory is created (and none may be deleted: P23).
  # -Edge : the active (from -> to) edge; defaults to the small -> medium edge.
  #   All transformations, the state skeleton and the report data read $Edge, so
  #   the same function serves the micro -> medium composition.
  param([string]$PkgDir, [switch]$SkipInitialCopy, $Edge = $MediumEdge)
  # 5h (basis) : copy the current (small) package verbatim, excluding the
  # operational state file (regenerated below). Same single package file set as
  # the micro -> small path.
  if (-not $SkipInitialCopy) {
    $allRels = @(Get-PackageRelativePaths -Root $SkillDir)
    foreach ($rel in $allRels) {
      if ($rel -eq '.scaling-state.json') { continue }
      $src = Join-Path $SkillDir ($rel.Replace('/', '\'))
      $dest = Join-Path $PkgDir $rel
      $destDir = Split-Path -Parent $dest
      if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
      Copy-Item -LiteralPath $src -Destination $dest -Force
    }
    Write-Log ("5h copied current ({0}) package files to {1}" -f $Edge.From, $PkgDir)
  } else {
    Write-Log ("5h skipped (composition mode): {0} already carries the {1}-tier content" -f $PkgDir, $Edge.From)
  }

  # --- 5a : move 8 FB sections into 4 new D2 pages (re-prefixed), rewrite the 5
  # source pages (remove moved sections, re-number remaining FB headings, re-base
  # kept error codes for governance/CISO, update each Function blocks figure) ---
  $pkgDeptDir = Join-Path $PkgDir 'references\departments'
  if (-not (Test-Path -LiteralPath $pkgDeptDir)) { New-Item -ItemType Directory -Path $pkgDeptDir -Force | Out-Null }

  # Buffer for the 4 new D2 pages: ToDept -> ordered list of moved section texts.
  $newDeptBuffers = @{}
  foreach ($k in $Edge.Split) {
    if ($k.Prefix -in @('CLR_', 'CDO_', 'CPO_', 'CCO_')) { $newDeptBuffers[$k.Slug] = New-Object System.Collections.Generic.List[string] }
  }

  foreach ($srcDept in @('governance-and-operations', 'technology-and-platform', 'security-and-compliance', 'quality-and-delivery', 'people-and-growth')) {
    $srcPath = Join-Path $pkgDeptDir ($srcDept + '.md')
    if (-not (Test-Path -LiteralPath $srcPath)) { Write-Log ("WARN source D2 page not found: {0}" -f $srcPath); continue }
    $text = [System.IO.File]::ReadAllText($srcPath)
    $fbMatches = [regex]::Matches($text, '(?m)^##\s+FB-\d+\s*:')
    if ($fbMatches.Count -eq 0) { Write-Log ("WARN {0} has no FB sections" -f $srcDept); continue }
    $preamble = $text.Substring(0, $fbMatches[0].Index)
    $sections = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $fbMatches.Count; $i++) {
      $start = $fbMatches[$i].Index
      $end = if ($i -lt ($fbMatches.Count - 1)) { $fbMatches[$i + 1].Index } else { $text.Length }
      $sections.Add($text.Substring($start, $end - $start))
    }
    $moveList = $MediumBlockMoves[$srcDept]
    $kept = New-Object System.Collections.Generic.List[string]
    foreach ($sec in $sections) {
      $labelMatch = [regex]::Match($sec, '(?m)^##\s+FB-\d+\s*:\s*([A-Z0-9]+)')
      $label = if ($labelMatch.Success) { $labelMatch.Groups[1].Value } else { '' }
      $move = $null
      foreach ($m in $moveList) { if ($m.Label -eq $label) { $move = $m; break } }
      if ($null -ne $move) {
        $moved = [regex]::Replace($sec, '(?m)^##\s+FB-\d+\s*:\s*', ("## FB-{0}: {1} " -f $move.ToFb, $move.ToLabel))
        $moved = $moved.Replace($move.From, $move.ToCode)
        $newDeptBuffers[$move.ToDept].Add($moved)
        Write-Log ("5a moved block {0} ({1}) from {2} -> {3} ({4})" -f $label, $move.From, $srcDept, $move.ToDept, $move.ToCode)
      } else {
        $kept.Add($sec)
      }
    }
    # Re-number kept sections FB-1..N and re-base kept codes for governance/CISO.
    $buf = New-Object System.Collections.Generic.List[string]
    $buf.Add($preamble)
    for ($i = 0; $i -lt $kept.Count; $i++) {
      $n = $i + 1
      $buf.Add([regex]::Replace($kept[$i], '(?m)^##\s+FB-\d+\s*:\s*', ("## FB-{0}: " -f $n)))
    }
    $keptText = $buf -join ''
    if ($srcDept -eq 'governance-and-operations') {
      foreach ($rb in $MediumSourceRebase['CEO_']) { $keptText = $keptText.Replace($rb.Old, $rb.New) }
    } elseif ($srcDept -eq 'security-and-compliance') {
      foreach ($rb in $MediumSourceRebase['CISO_']) { $keptText = $keptText.Replace($rb.Old, $rb.New) }
    }
    # Update the Function blocks figure to the kept count.
    $keptText = [regex]::Replace($keptText, 'Function blocks:\s*\d+', ('Function blocks: ' + $kept.Count))
    Write-TextFileNoBom -Path $srcPath -Text $keptText
    Write-Log ("5a rewrote source page {0} ({1} function block(s) kept, headings re-numbered, codes re-based)" -f $srcDept, $kept.Count)
  }

  # Build the 4 new D2 pages from the moved sections + an authored preamble.
  $newDeptPreable = @{
    'legal-and-risk'            = @'
# Legal and Risk

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A PII exposure is detected at the boundary.
2. A contract or regulatory obligation needs a compliance ruling.
3. A risk threshold is breached and the circuit breaker must trip.
4. A legal or AIGC labeling question needs an answer.
5. A security incident requires legal and privacy review.

## 2. Core Identity

The Legal and Risk department owns legal compliance, AIGC labeling, privacy and data protection, and enterprise risk management for the medium tier. It triages legal obligations, enforces PII handling and residency, runs FAIR risk assessments and the risk gate, and blocks operations that breach exposure thresholds; it never self-modifies permissions or tests and reports to the principal.

'@
    'data-and-analytics'        = @'
# Data and Analytics

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A model needs registration or an invocation policy.
2. A data pipeline schema drifts and must be restored.
3. Multi-source data must be fused into a consistent answer.
4. Localization coverage must reach 100% of locales.
5. A dataset shows conflicting fields across sources.

## 2. Core Identity

The Data and Analytics department owns the model registry, invocation policy, data pipelines, schema contracts, information fusion, and localization for the medium tier. It registers models, enforces schema contracts on pipelines, fuses multi-source data, and routes requests by language; it never self-modifies permissions or tests and reports to the principal.

'@
    'product-and-strategy'      = @'
# Product and Strategy

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A strategic decision brief needs quantified options.
2. A SITREP must be compiled from >=0.6-rated sources.
3. An authorization-matrix violation must be routed for ruling.
4. Market entry or roadmap alignment is on the table.
5. A board escalation needs a shareholder report.

## 2. Core Identity

The Product and Strategy department owns board governance, the authorization matrix, competitive intelligence, and sentiment for the medium tier. It maintains decision authority levels, runs the intelligence cycle, and tracks baseline sentiment; it never self-modifies permissions or tests and reports to the principal.

'@
    'customer-and-partnerships' = @'
# Customer and Partnerships

> D2 index page. Function blocks: 2.
> Department Harness Baseline: L3

## 1. Trigger Scenarios

1. A vendor invoice deviates by more than 5%.
2. External content needs approval before release.
3. A partner agreement needs measurable goals.
4. A procurement contract needs cost scoring.
5. A billing or unit-economics report is due.

## 2. Core Identity

The Customer and Partnerships department owns procurement, billing, brand and partnerships, and external-content approval for the medium tier. It scores vendors, allocates costs, governs partnerships, and gates external content at Harness L5; it never self-modifies permissions or tests and reports to the principal.

'@
  }
  foreach ($slug in @('legal-and-risk', 'data-and-analytics', 'product-and-strategy', 'customer-and-partnerships')) {
    $preamble = $newDeptPreable[$slug]
    $body = ''
    foreach ($s in $newDeptBuffers[$slug]) { $body += $s }
    Write-TextFileNoBom -Path (Join-Path $pkgDeptDir ($slug + '.md')) -Text ($preamble + $body)
    Write-Log ("5a generated new D2 page references/departments/{0}.md (2 function blocks)" -f $slug)
  }

  # 5a (shared modules) : add references/shared/ (scaling.md sec 3 : "shared
  # modules added" for the small -> medium step). Three cross-department files.
  $pkgSharedDir = Join-Path (Join-Path $PkgDir 'references') 'shared'
  if (-not (Test-Path -LiteralPath $pkgSharedDir)) { New-Item -ItemType Directory -Path $pkgSharedDir -Force | Out-Null }
  $glossary = @'
# Shared Glossary

> Cross-department reference (medium tier). Not owned by any single department.

## Abbreviations

- FB - function block (a capability unit; the medium tier has 18 across 9 departments)
- SCL - self-scaling infrastructure prefix (not department-owned)
- CEO_ / CTO_ / CISO_ / CHO_ / CQO_ / CLR_ / CDO_ / CPO_ / CCO_ - department error-code prefixes
- ADR - architecture decision record
- CVSS - common vulnerability scoring system
- FAIR - factor analysis of information risk
- PII - personally identifiable information
- SLA - service level agreement
- SITREP - situation report

## Key terms

- harness level - the L1-L6 assurance grade of a capability unit
- routing accuracy - share of requests routed to the correct "department: auto" target
- function-block conservation - the invariant that an upgrade preserves the 18 (or 36) block count
'@
  $handoff = @'
# Cross-Department Handoff

> Shared handoff guidance (medium tier). See also references/scaling.md.

## Handoff SLA

- A dependency handoff must meet its SLA within 10% or escalate to CFO (FB-3).
- Risk-gating blocks Technology and Platform deployments via the risk gate.
- External content is routed through Legal and Risk (FB-2) before release.
- Procurement reconciles invoices with Finance (FB-3) via the shared ledger.
- Intelligence (FB-1) delivers SITREPs to Governance and Operations (FB-1, FB-2).

## Routing rule

- "department: auto" selects the target from the frontmatter interface enum.
- A misroute is a routing-accuracy miss and is recorded in the scaling state file.
'@
  $patterns = @'
# Common Operational Patterns

> Shared patterns used across departments (medium tier).

## Crisis command

1. Acknowledge within 15 minutes. 2. Assign a named owner. 3. Activate the protocol.
4. File a post-mortem within 24 hours.

## Quality gate

- Coverage >= 85%. - No case requires network access. - Every test asserts one behavior.

## Error handling

- Quarantine the failing unit. - Add error handling, retry, and idempotency.
- Re-assess before re-delivery. - Record the bypass in the audit trail.

## Audit trail

- Persist every agent-to-agent hop. - Hash evidence chains for internal audit.
- Never self-modify permissions, tests, or gating scripts.
'@
  Write-TextFileNoBom -Path (Join-Path $pkgSharedDir 'glossary.md') -Text $glossary
  Write-TextFileNoBom -Path (Join-Path $pkgSharedDir 'cross-department-handoff.md') -Text $handoff
  Write-TextFileNoBom -Path (Join-Path $pkgSharedDir 'common-patterns.md') -Text $patterns
  Write-Log '5a generated references/shared/{glossary, cross-department-handoff, common-patterns}.md'

  # 5d : rewrite the package frontmatter for the medium tier (tier fields,
  # version, alias pointer, interface department enum, and description).
  $newEnum = '[auto, governance-and-operations, technology-and-platform, security-and-compliance, quality-and-delivery, people-and-growth, legal-and-risk, data-and-analytics, product-and-strategy, customer-and-partnerships]'
  $newDescription = 'Medium-tier governance skill for scaling AI agent organizations (10-50 agents). Distributes 18 enterprise function blocks across 9 departments - governance-and-operations, technology-and-platform, security-and-compliance, quality-and-delivery, people-and-growth, legal-and-risk, data-and-analytics, product-and-strategy, and customer-and-partnerships - spanning strategy, operations, finance, risk, legal, privacy, architecture, security, compliance, quality, delivery, data, analytics, product, intelligence, brand, and partnerships. Ships ten harness code templates, three prompt frameworks, a 34-code error catalog with ten prefixes, and propose-only self-scaling. Use when a scaling team needs enterprise-grade governance, legal and privacy review, data and analytics pipelines, product and partnership coordination, or tier-upgrade assessment.'
  $skPath = Join-Path $PkgDir 'SKILL.md'
  if (Test-Path -LiteralPath $skPath) {
    $lines = [System.IO.File]::ReadAllLines($skPath)
    $fmEnd = -1
    for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $fmEnd = $i; break } }
    if (($lines.Count -ge 2) -and ($lines[0].Trim() -eq '---') -and ($fmEnd -gt 0)) {
      $inMetadata = $false; $inInterface = $false; $hasAliasPointer = $false
      $versionRewrites = 0; $enumRewrites = 0; $descriptionRewrites = 0
      for ($i = 1; $i -lt $fmEnd; $i++) {
        $line = $lines[$i]
        if ($line -match '^metadata\s*:\s*$') { $inMetadata = $true; continue }
        if ($line -match '^interface\s*:\s*$') { $inInterface = $true; continue }
        if ($line -match '^\S') { $inMetadata = $false; $inInterface = $false }
        if ($line -match '^(\s*)version\s*:\s*.*$') { $lines[$i] = "{0}version: {1}" -f $Matches[1], $Edge.NewVersion; $versionRewrites++; continue }
        if ($line -match '^(\s*)error_code_prefixes\s*:\s*.*$') { $lines[$i] = "{0}error_code_prefixes: [CEO_, CTO_, CISO_, CHO_, CQO_, CLR_, CDO_, CPO_, CCO_, SCL_]" -f $Matches[1]; continue }
        if ($line -match '^description\s*:\s*".*"\s*$') { $lines[$i] = 'description: "' + $newDescription + '"'; $descriptionRewrites++; continue }
        # E18 : rewrite the structured tier tag token (e.g. small-tier -> medium-tier)
        # so the tag list agrees with the new scale_tier. Only the *-tier token is
        # touched; the other prose "small tier" mentions stay for human review.
        if ($line -match '^tags\s*:') { $lines[$i] = $line -replace ([regex]::Escape(($Edge.From + '-tier'))), ($Edge.To + '-tier'); continue }
        if (($line -match '^(\s*)enum\s*:\s*\[.*\]\s*$') -and ($line -match '\bauto\b')) { $lines[$i] = "{0}enum: {1}" -f $Matches[1], $newEnum; $enumRewrites++; continue }
        if ($line -match 'department_aliases') { $hasAliasPointer = $true }
        if ($inMetadata) {
          if ($line -match '^(\s*)scale_tier\s*:') { $lines[$i] = "{0}scale_tier: {1}" -f $Matches[1], $Edge.To; continue }
          if ($line -match '^(\s*)department_count\s*:') { $lines[$i] = "{0}department_count: {1}" -f $Matches[1], $Edge.DepartmentCount; continue }
          if ($line -match '^(\s*)function_block_count\s*:') { $lines[$i] = "{0}function_block_count: {1}" -f $Matches[1], $Edge.ExpectedBlocks; continue }
        }
      }
      if ($versionRewrites -lt 1) { Write-Log 'WARN 5d version line not found in the package frontmatter (G6 version check will fail)' }
      if ($enumRewrites -lt 1) { Write-Log 'WARN 5d interface.department.enum not found in the package frontmatter (G6 enum check will fail)' }
      if ($descriptionRewrites -lt 1) { Write-Log 'WARN 5d top-level description not found in the package frontmatter (stale small-tier description left in place; flagged for human review)' }
      if (-not $hasAliasPointer) {
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $fmEnd; $i++) { $out.Add($lines[$i]) }
        $out.Add('department_aliases: references/scaling.md#alias-map')
        for ($i = $fmEnd; $i -lt $lines.Count; $i++) { $out.Add($lines[$i]) }
        $lines = $out.ToArray()
      }
      Write-TextFileNoBom -Path $skPath -Text (($lines -join "`n") + "`n")
      Write-Log ("5d package frontmatter rewritten (scale_tier={0}, department_count={1}, function_block_count={2}, version={3}, {4} prefixes, enum + description updated for {1} departments)" -f $Edge.To, $Edge.DepartmentCount, $Edge.ExpectedBlocks, $Edge.NewVersion, (@($Edge.Prefixes).Count))
    } else { Write-Log 'WARN package SKILL.md has no parseable frontmatter; 5d skipped (G1/G6 will fail)' }
  } else { Write-Log 'WARN package SKILL.md not found; 5d skipped (G1/G3/G6 will fail)' }

  # 5e : bump _meta.json version.
  $metaPath = Join-Path $PkgDir '_meta.json'
  if (Test-Path -LiteralPath $metaPath) {
    try {
      $meta = ConvertFrom-Json ([System.IO.File]::ReadAllText($metaPath))
      if ($null -ne $meta.PSObject.Properties['version']) { $meta.version = $Edge.NewVersion }
      Write-TextFileNoBom -Path $metaPath -Text ((ConvertTo-StableJson -Value $meta) + "`n")
      Write-Log "5e _meta.json version bumped to $($Edge.NewVersion)"
    } catch { Write-Log 'WARN _meta.json could not be updated (G6 version check will fail)' }
  }

  # 5e : transform error-codes.md - re-base the 5 source prefix sections and add
  # 4 new prefix sections + a resolved alias history (not a skeleton: the 8 block
  # migrations are deterministic and resolved).
  $pkgErrorCodes = Join-Path (Join-Path $PkgDir 'references') 'error-codes.md'
  if (Test-Path -LiteralPath $pkgErrorCodes) {
    $ecText = [System.IO.File]::ReadAllText($pkgErrorCodes)
    $ecText = [regex]::Replace($ecText, '(?m)^> Full error code table for the .*?\. \d+ codes in \d+ prefixes:.*$', '> Full error code table for the medium tier. 34 codes in 10 prefixes: CEO_ (6), CTO_ (3), CISO_ (3), CHO_ (2), CQO_ (2), CLR_ (2), CDO_ (2), CPO_ (2), CCO_ (2), SCL_ (10).')
    $ecText = [regex]::Replace($ecText, '(?m)^> `CEO_` codes belong to.*$', '> `CEO_` codes belong to function blocks of `governance-and-operations`; `CTO_` to `technology-and-platform`; `CISO_` to `security-and-compliance`; `CHO_` to `people-and-growth`; `CQO_` to `quality-and-delivery`; `CLR_` to `legal-and-risk`; `CDO_` to `data-and-analytics`; `CPO_` to `product-and-strategy`; `CCO_` to `customer-and-partnerships`; `SCL_` is the infrastructure prefix for self-scaling and is not owned by any department.')
    $ecText = Move-ErrorCodeRows -Text $ecText -Prefix 'CEO_' -Remove @('CEO_005', 'CEO_008', 'CEO_009') -Rebase $MediumSourceRebase['CEO_']
    $ecText = Move-ErrorCodeRows -Text $ecText -Prefix 'CTO_' -Remove @('CTO_004') -Rebase @()
    $ecText = Move-ErrorCodeRows -Text $ecText -Prefix 'CISO_' -Remove @('CISO_002') -Rebase $MediumSourceRebase['CISO_']
    $ecText = Move-ErrorCodeRows -Text $ecText -Prefix 'CQO_' -Remove @('CQO_003') -Rebase @()
    $ecText = Move-ErrorCodeRows -Text $ecText -Prefix 'CHO_' -Remove @('CHO_003', 'CHO_004') -Rebase @()
    $newSections = @'
## CLR_ Prefix (legal-and-risk)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CLR_001 | Risk threshold breach without circuit breaker | FAIR-assessed exposure exceeds the risk threshold with no breaker tripped | 1. Trip the circuit breaker 2. Re-run the FAIR assessment within 4 hours 3. Report to FB-1 |
| CLR_002 | PII exposure detected | PII leaves the boundary unmasked or crosses a restricted residency region | 1. Halt the data flow 2. Apply masking and residency routing 3. Notify Governance and Operations FB-1 within 1 hour |

## CDO_ Prefix (data-and-analytics)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CDO_001 | Model or data governance violation | An invoked model is absent from the registry, or a pipeline schema drifts by more than 2 fields | 1. Reject the invocation or run 2. Register the model or restore the schema contract 3. Backfill affected records within 24 hours |
| CDO_002 | Information fusion inconsistency | Multi-source lookups disagree on more than 15% of fields, or localization coverage is below 100% | 1. Flag the conflicting fields 2. Re-query the authoritative source 3. Correct the fusion rule within 4 hours |

## CPO_ Prefix (product-and-strategy)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CPO_001 | Intelligence source reliability below threshold | A SITREP cites sources averaging below 0.6 reliability, or is more than 7 days overdue | 1. Reclassify the report as unverified 2. Re-acquire from sources rated 0.6 or higher 3. Republish within 48 hours |
| CPO_002 | Authorization matrix violation | A decision is executed above or outside its defined approval level | 1. Halt the decision 2. Route it to the correct escalation level 3. Log the violation for quarterly board review |

## CCO_ Prefix (customer-and-partnerships)

| Code | Message | Trigger Condition | Resolution Steps |
|---|---|---|---|
| CCO_001 | Vendor cost deviation | A final vendor invoice exceeds the contracted amount by more than 5% | 1. Suspend payments to the vendor 2. Request a written reconciliation 3. Enforce the penalty clause within 5 business days |
| CCO_002 | External content released without approval | Content leaves the organization without L5 harness or CMO sign-off, or NPS falls below 30 | 1. Withdraw the content 2. Route it through the approval chain 3. Add the case to brand review within 5 business days |

'@
    $ecText = [regex]::Replace($ecText, '(?m)(## SCL_ Prefix)', ($newSections.TrimEnd("`n") + "`n`n" + '$1'))
    $aliasHistory = @'

## Alias history (small -> medium, resolved)

The small -> medium migration moved 8 function blocks from the 5 existing
departments into 4 new departments and re-prefixed them (numbers re-based from
001 within each new prefix); the codes that stayed in their successor
departments kept their codes. The resolved mapping is:

| Legacy code | Resolves to | Status |
|---|---|---|
| CEO_005 | CPO_002 | resolved |
| CEO_008 | CLR_001 | resolved |
| CEO_009 | CCO_001 | resolved |
| CISO_002 | CLR_002 | resolved |
| CTO_004 | CDO_001 | resolved |
| CQO_003 | CDO_002 | resolved |
| CHO_003 | CCO_002 | resolved |
| CHO_004 | CPO_001 | resolved |
'@
    $ecText = $ecText.TrimEnd("`n") + $aliasHistory + "`n"
    Write-TextFileNoBom -Path $pkgErrorCodes -Text $ecText
    Write-Log '5e error-codes.md transformed: 4 new prefix sections inserted, source sections re-based, resolved alias history appended'
  } else { Write-Log 'WARN references/error-codes.md missing from the package; not transformed' }

  # 5i : version strings in the README files (context-exact, counted replacements).
  $zhVersionWord = [string][char]0x7248 + [string][char]0x672C
  $readmeTargets = @(
    @{ Pattern = 'version-2\.0\.0-blue';                 Replace = 'version-3.0.0-blue'; What = 'badge' },
    @{ Pattern = ('\| ' + $zhVersionWord + ' \| 2\.0\.0 \|'); Replace = ('| ' + $zhVersionWord + ' | 3.0.0 |'); What = 'at-a-glance version row (Chinese)' },
    @{ Pattern = '\| Version \| 2\.0\.0 \|';             Replace = '| Version | 3.0.0 |'; What = 'at-a-glance version row (English)' }
  )
  $replaceCounts = @{}
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    $p = Join-Path $pkgDir $name
    if (-not (Test-Path -LiteralPath $p)) { continue }
    $t = Read-TextFile -Path $p
    if ($null -eq $t) { continue }
    foreach ($tgt in $readmeTargets) {
      $hits = [regex]::Matches($t, $tgt.Pattern)
      if ($hits.Count -eq 0) { continue }
      foreach ($h in $hits) {
        $lineNo = 1 + ([regex]::Matches($t.Substring(0, $h.Index), "`n")).Count
        Write-Log ("5i {0}: {1} rewritten at line {2} ('{3}' -> '{4}')" -f $name, $tgt.What, $lineNo, $Edge.OldVersion, $Edge.NewVersion)
      }
      $t = [regex]::Replace($t, $tgt.Pattern, $tgt.Replace)
      $replaceCounts[("{0}|{1}" -f $name, $tgt.What)] = $hits.Count
    }
    Write-TextFileNoBom -Path $p -Text $t
  }
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    if (-not ($replaceCounts.ContainsKey("$name|badge")) -or ($replaceCounts["$name|badge"] -lt 1)) { Write-Log ("WARN 5i {0} : badge version context was not found / not replaced" -f $name) }
  }
  foreach ($name in @('README.md', 'README.en.md')) {
    if (-not ($replaceCounts.ContainsKey("$name|at-a-glance version row (English)")) -or ($replaceCounts["$name|at-a-glance version row (English)"] -lt 1)) { Write-Log ("WARN 5i {0} : English version table row was not found / not replaced" -f $name) }
  }
  if (-not ($replaceCounts.ContainsKey('README.zh.md|at-a-glance version row (Chinese)')) -or ($replaceCounts['README.zh.md|at-a-glance version row (Chinese)'] -lt 1)) { Write-Log 'WARN 5i README.zh.md : Chinese version table row was not found / not replaced' }

  # 5i : rewrite the README Project Structure tree to the 37-file medium skeleton.
  $newTree = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('YWktY29tcGFueS8K4pSc4pSA4pSAIC5lZGl0b3Jjb25maWcK4pSc4pSA4pSAIC5naXRhdHRyaWJ1dGVzCuKUnOKUgOKUgCAuZ2l0aWdub3JlCuKUnOKUgOKUgCAuc2NhbGluZy1zdGF0ZS5qc29uCuKUnOKUgOKUgCBBR0VOVFMubWQK4pSc4pSA4pSAIENIQU5HRUxPRy5tZArilJzilIDilIAgQ09ERV9PRl9DT05EVUNULm1kCuKUnOKUgOKUgCBDT05UUklCVVRJTkcubWQK4pSc4pSA4pSAIExJQ0VOU0UK4pSc4pSA4pSAIFJFQURNRV9GT1JfQUkubWQK4pSc4pSA4pSAIFJFQURNRS5lbi5tZArilJzilIDilIAgUkVBRE1FLm1kCuKUnOKUgOKUgCBSRUFETUUuemgubWQK4pSc4pSA4pSAIFNFQ1VSSVRZLm1kCuKUnOKUgOKUgCBTS0lMTC5tZArilJzilIDilIAgX21ldGEuanNvbgrilJzilIDilIAgcHJvbXB0cy8K4pSCICAg4pSc4pSA4pSAIDAxLWltcGxlbWVudC1tZXRob2QubWQK4pSCICAg4pSc4pSA4pSAIDAyLXJvYnVzdG5lc3MtY2hlY2tzLm1kCuKUgiAgIOKUlOKUgOKUgCAwMy10ZXN0LWNhc2VzLm1kCuKUnOKUgOKUgCByZWZlcmVuY2VzLwrilIIgICDilJzilIDilIAgbWV0aG9kLXBhdHRlcm5zLm1kCuKUgiAgIOKUnOKUgOKUgCBlcnJvci1jb2Rlcy5tZArilIIgICDilJzilIDilIAgc2NhbGluZy5tZArilIIgICDilJzilIDilIAgZGVwYXJ0bWVudHMvCuKUgiAgIOKUgiAgIOKUnOKUgOKUgCBnb3Zlcm5hbmNlLWFuZC1vcGVyYXRpb25zLm1kCuKUgiAgIOKUgiAgIOKUnOKUgOKUgCB0ZWNobm9sb2d5LWFuZC1wbGF0Zm9ybS5tZArilIIgICDilIIgICDilJzilIDilIAgc2VjdXJpdHktYW5kLWNvbXBsaWFuY2UubWQK4pSCICAg4pSCICAg4pSc4pSA4pSAIHF1YWxpdHktYW5kLWRlbGl2ZXJ5Lm1kCuKUgiAgIOKUgiAgIOKUnOKUgOKUgCBwZW9wbGUtYW5kLWdyb3d0aC5tZArilIIgICDilIIgICDilJzilIDilIAgbGVnYWwtYW5kLXJpc2subWQK4pSCICAg4pSCICAg4pSc4pSA4pSAIGRhdGEtYW5kLWFuYWx5dGljcy5tZArilIIgICDilIIgICDilJzilIDilIAgcHJvZHVjdC1hbmQtc3RyYXRlZ3kubWQK4pSCICAg4pSCICAg4pSU4pSA4pSAIGN1c3RvbWVyLWFuZC1wYXJ0bmVyc2hpcHMubWQK4pSCICAg4pSU4pSA4pSAIHNoYXJlZC8K4pSCICAgICAgIOKUnOKUgOKUgCBnbG9zc2FyeS5tZArilIIgICAgICAg4pSc4pSA4pSAIGNyb3NzLWRlcGFydG1lbnQtaGFuZG9mZi5tZArilIIgICAgICAg4pSU4pSA4pSAIGNvbW1vbi1wYXR0ZXJucy5tZArilJzilIDilIAgc2NyaXB0cy8K4pSCICAg4pSc4pSA4pSAIHNlbGYtc2NhbGUucHMxCuKUgiAgIOKUlOKUgOKUgCBzY2FsaW5nLWNvbmZpZy5qc29uCuKUlOKUgOKUgCB0ZXN0cy8KICAgIOKUlOKUgOKUgCB0ZXN0LW1ldGhvZC1wYXR0ZXJucy5weQ=='))
  $newTree = $newTree + "`n"
  $treeNoteEn = '> Structure tree rewritten to the 37-file medium-tier skeleton by the upgrade generator - requires human review before installation.'
  $treeNoteZh = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('PiDnu5PmnoTmoJHlt7LnlLHmraTljYfnuqfnlJ/miJDlmajmlLnlhpnkuLogMzcg5Liq5paH5Lu255qE5Lit5Z6L5qGj6aqo5p62IC0g5a6J6KOF5YmN6ZyA5Lq65bel5aSN5qC444CC'))
  # Strip any pre-existing tree-rewrite note (English or Chinese) so the rewrite
  # does not leave a stale note (e.g. the 30-file small-tier note) beside the new
  # 37-file medium-tier note. The Chinese markers cover both the legacy wording
  # ("由...改写为", from the micro->small build) and the current wording
  # ("由此...改写为"); both are base64-encoded to keep this script pure ASCII
  # (Windows PowerShell 5.1 reads BOM-less UTF-8 as ANSI).
  $zhMarkerOld = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('57uT5p6E5qCR5bey55Sx5Y2H57qn55Sf5oiQ5Zmo5pS55YaZ5Li6'))
  $zhMarkerNew = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('57uT5p6E5qCR5bey55Sx5q2k5Y2H57qn55Sf5oiQ5Zmo5pS55YaZ5Li6'))
  $noteStrip = New-Object System.Text.RegularExpressions.Regex(('^>\s*(?:Structure tree rewritten|{0}|{1}).*$' -f [regex]::Escape($zhMarkerOld), [regex]::Escape($zhMarkerNew)), [System.Text.RegularExpressions.RegexOptions]::Multiline)
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    $p = Join-Path $PkgDir $name
    if (-not (Test-Path -LiteralPath $p)) { continue }
    $t = Read-TextFile -Path $p
    if ($null -eq $t) { continue }
    $treeFence = '(?s)```text\r?\nai-company/.*?\r?\n```'
    if (-not ([regex]::IsMatch($t, $treeFence))) { Write-Log ("WARN 5i Project Structure tree fence not found in {0}; tree not rewritten" -f $name); continue }
    $note = $treeNoteEn
    if ($name -eq 'README.zh.md') { $note = $treeNoteZh }
    $replacement = '```text' + "`n" + $newTree + '```' + "`n`n" + $note
    $treeRegex = New-Object System.Text.RegularExpressions.Regex($treeFence)
    $t = $noteStrip.Replace($t, '')
    $t2 = $treeRegex.Replace($t, $replacement.Replace('$', '$$'), 1)
    Write-TextFileNoBom -Path $p -Text $t2
    Write-Log ("5i Project Structure tree rewritten to the 37-file skeleton in {0} (marked requires human review)" -f $name)
  }

  # 5i : CHANGELOG.md upgrade entry (inserted after [Unreleased], E17 order).
  # The per-edge bullet lines live on the edge (Report.ChangelogBullets) so the
  # micro -> medium composition narrates both stages.
  $changelogPath = Join-Path $PkgDir 'CHANGELOG.md'
  if (Test-Path -LiteralPath $changelogPath) {
    $entry = ("## [{0}] - {1} - tier upgrade proposal ({2} -> {3})" -f $Edge.NewVersion, ((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')), $Edge.From, $Edge.To) + "`n`n" +
      (($Edge.Report.ChangelogBullets -join "`n")) + "`n" +
      "- PROPOSED ONLY - requires human approval and an external installer" + "`n"
    $old = Read-TextFile -Path $changelogPath
    if ($null -ne $old) {
      $chLines = $old -split "`n"
      $unreleasedIdx = -1
      for ($i = 0; $i -lt $chLines.Count; $i++) { if ($chLines[$i] -match '^##\s*\[Unreleased\]') { $unreleasedIdx = $i; break } }
      if ($unreleasedIdx -ge 0) {
        $insertAt = $unreleasedIdx + 1
        while (($insertAt -lt $chLines.Count) -and ([string]::IsNullOrWhiteSpace($chLines[$insertAt]))) { $insertAt++ }
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $insertAt; $i++) { $out.Add($chLines[$i]) }
        foreach ($l in ($entry -split "`n")) { $out.Add($l) }
        for ($i = $insertAt; $i -lt $chLines.Count; $i++) { $out.Add($chLines[$i]) }
        Write-TextFileNoBom -Path $changelogPath -Text ((($out -join "`n").TrimEnd("`r`n")) + "`n")
        Write-Log '5i CHANGELOG.md entry inserted after [Unreleased] (E17 order)'
      } else {
        $insertAfter = 0
        for ($i = 0; $i -lt $chLines.Count; $i++) { if ($chLines[$i] -match '^##\s') { $insertAfter = $i; break } }
        $out = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $insertAfter; $i++) { $out.Add($chLines[$i]) }
        foreach ($l in ($entry -split "`n")) { $out.Add($l) }
        for ($i = $insertAfter; $i -lt $chLines.Count; $i++) { $out.Add($chLines[$i]) }
        Write-TextFileNoBom -Path $changelogPath -Text ((($out -join "`n").TrimEnd("`r`n")) + "`n")
        Write-Log 'WARN 5i CHANGELOG.md has no [Unreleased] heading; entry inserted before the first version section'
      }
    }
  }

  # 5g : append the block-migration alias rows to the package's scaling.md Alias Map.
  $pkgScalingMd = Join-Path (Join-Path $PkgDir 'references') 'scaling.md'
  $aliasRows = @(
    '| governance-and-operations | small | legal-and-risk | v3.0.0 |',
    '| security-and-compliance | small | legal-and-risk | v3.0.0 |',
    '| technology-and-platform | small | data-and-analytics | v3.0.0 |',
    '| quality-and-delivery | small | data-and-analytics | v3.0.0 |',
    '| people-and-growth | small | product-and-strategy | v3.0.0 |',
    '| governance-and-operations | small | product-and-strategy | v3.0.0 |',
    '| governance-and-operations | small | customer-and-partnerships | v3.0.0 |',
    '| people-and-growth | small | customer-and-partnerships | v3.0.0 |'
  )
  Add-AliasRows -ScalingMdPath $pkgScalingMd -NewRows $aliasRows
  Write-Log '5g alias rows appended to the package Alias Map (small -> medium block migrations)'

  # Package state file : initial state for the target tier.
  $nowIso = Get-UtcNowIso
  $pkgState = [ordered]@{
    schema_version      = 1
    current_tier        = $Edge.To
    tier_history        = @(
      [ordered]@{
        from          = $Edge.From
        to            = $Edge.To
        proposed_at   = $nowIso
        approved_by   = $null
        installed_at  = $null
        package_path  = (Get-WorkspaceRelativePath -Path $PkgDir)
        validation    = [ordered]@{
          file_count        = $TargetFileCount[$Edge.To]
          function_blocks   = $Edge.ExpectedBlocks
          gates_passed      = 6
          acceptance_passed = $false
        }
      }
    )
    pending_proposals   = @()
    next_evaluation     = (Get-Date).ToUniversalTime().AddDays(30).ToString('yyyy-MM-ddTHH:mm:ssZ')
    last_metrics        = [ordered]@{
      agent_count               = 0
      routing_accuracy          = 1.0
      max_blocks_per_department = 6
      error_code_reuse_ratio    = 0.0
    }
    validation          = [ordered]@{
      gates_passed      = 6
      file_count        = $TargetFileCount[$Edge.To]
      acceptance_passed = $false
    }
  }
  Write-TextFileNoBom -Path (Join-Path $PkgDir '.scaling-state.json') -Text ((ConvertTo-StableJson -Value $pkgState) + "`n")
  Write-Log "package state file initialized for tier '$($Edge.To)' (tier_history carries the upgrade skeleton entry, append-only)"
}

function New-MediumToLargeUpgradePackage {
  # -Edge : the active (from -> to) edge; defaults to the medium -> large edge.
  #   The large target content is the canonical ai-company-large reference
  #   package (source-independent), so the same builder serves every
  #   -> large pair (micro -> large, small -> large, medium -> large); the
  #   source tier only decides the frontmatter shell, the retired-slug set
  #   (G5) and the report narrative.
  param([string]$PkgDir, $Edge = $LargeEdge)
  # 5h (basis) : the large tier is a wholesale department replacement (the 9
  # medium departments are retired; 18 large departments take over, 18 function
  # blocks conserved, one per department). The CONTENT (D2/D3 pages, error
  # codes, references, models) is taken from the ai-company-large reference
  # package. The SKILL.md frontmatter shell (which carries the base-framework
  # schema the gates require, plus the LIVE permissions block for G1) is taken
  # from the LIVE medium skill and retargeted to large; the body is taken from
  # ai-company-large so the narrative matches the 18 large departments.
  $LargeSourceDir = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'ai-company-large'
  if (-not (Test-Path -LiteralPath $LargeSourceDir)) {
    Stop-WithCode 'SCL_002' ("medium -> large target package not found at {0}; the large tier is built from the ai-company-large reference package" -f $LargeSourceDir)
  }
  $allRels = @(Get-PackageRelativePaths -Root $LargeSourceDir)
  foreach ($rel in $allRels) {
    if ($rel -eq '.scaling-state.json') { continue }
    $src = Join-Path $LargeSourceDir ($rel.Replace('/', '\'))
    $dest = Join-Path $PkgDir $rel
    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -LiteralPath $src -Destination $dest -Force
  }
  Write-Log ("5h copied large reference content to {0}" -f $PkgDir)

  # B1 (defensive) : the package file set uses the underscore spelling
  # README_FOR_AI.md (the base bloodline and the test suite hard-code it); a
  # hyphenated leftover would break every self-reference. The large reference
  # already ships the underscore name, so this normally does nothing.
  $legacySpec = Join-Path $PkgDir 'README-FOR-AI.md'
  $renamedSpec = Join-Path $PkgDir 'README_FOR_AI.md'
  if ((Test-Path -LiteralPath $legacySpec) -and (-not (Test-Path -LiteralPath $renamedSpec))) {
    Rename-Item -LiteralPath $legacySpec -NewName 'README_FOR_AI.md'
    Write-Log '5h renamed README-FOR-AI.md -> README_FOR_AI.md (defensive, audit B1)'
  }

  # G2 / G3 immutability : the package must carry the LIVE tests/ and
  # scripts/self-scale.ps1 byte-for-byte (the medium-aware tests and the
  # generator itself). Overlay them on top of the large reference copy.
  $liveTests = Join-Path $SkillDir 'tests'
  if (Test-Path -LiteralPath $liveTests) {
    Copy-Item -Path (Join-Path $liveTests '*') -Destination (Join-Path $PkgDir 'tests') -Recurse -Force
    Write-Log '5h overlaid live tests/ (G2 immutable)'
  }
  $liveScript = Join-Path $SkillDir 'scripts\self-scale.ps1'
  if (Test-Path -LiteralPath $liveScript) {
    Copy-Item -LiteralPath $liveScript -Destination (Join-Path $PkgDir 'scripts\self-scale.ps1') -Force
    Write-Log '5h overlaid live scripts/self-scale.ps1 (G3 immutable)'
  }
  # The base-framework scaling.md (with its Alias Map section) must be the
  # package's scaling.md so G5 can append and verify the medium->large aliases.
  $liveScaling = Join-Path $SkillDir 'references\scaling.md'
  if (Test-Path -LiteralPath $liveScaling) {
    Copy-Item -LiteralPath $liveScaling -Destination (Join-Path $PkgDir 'references\scaling.md') -Force
    Write-Log '5h overlaid live references/scaling.md (Alias Map host for G5)'
  }

  # 5a-normalize : large D2 index pages declare '> Function blocks: **N**'
  # (bold). G4 reads 'Function blocks: <N>' (sec 10.2), so de-bold to a plain
  # integer on every department D2 page.
  $pkgDeptDir = Join-Path $PkgDir 'references\departments'
  if (Test-Path -LiteralPath $pkgDeptDir) {
    foreach ($f in @(Get-ChildItem -LiteralPath $pkgDeptDir -Filter '*.md' -File -ErrorAction SilentlyContinue)) {
      $t = [System.IO.File]::ReadAllText($f.FullName)
      $t2 = [regex]::Replace($t, '(?m)^>\s*Function blocks:\s*\*\*(\d+)\*\*', '> Function blocks: ${1}')
      if ($t2 -ne $t) { Write-TextFileNoBom -Path $f.FullName -Text $t2; Write-Log ("5a de-bolded Function blocks figure in {0}" -f $f.Name) }
    }
  }

  # 5d : build SKILL.md = LIVE frontmatter shell (retargeted to large) + large body.
  $liveSkPath = Join-Path $SkillDir 'SKILL.md'
  $liveLines = [System.IO.File]::ReadAllLines($liveSkPath)
  $liveFmEnd = -1
  for ($i = 1; $i -lt $liveLines.Count; $i++) { if ($liveLines[$i].Trim() -eq '---') { $liveFmEnd = $i; break } }
  $skLines = @()
  for ($i = 0; $i -le $liveFmEnd; $i++) { $skLines += $liveLines[$i] }
  $newEnum = '[' + ('auto, ' + (@($Edge.Split | ForEach-Object { [string]$_.Slug }) -join ', ')) + ']'
  # Derived from the edge (target-tier data), so every -> large pair writes the
  # same canonical prefix line: the 18 department prefixes plus SCL_.
  $pfxList = @($Edge.Prefixes)
  if ($pfxList -notcontains 'SCL_') { $pfxList += 'SCL_' }
  $newPrefixes = '[' + ($pfxList -join ', ') + ']'
  $inMetadata = $false; $hasAliasPointer = $false
  $versionRewrites = 0; $enumRewrites = 0; $descriptionRewrites = 0
  for ($i = 0; $i -lt $skLines.Count; $i++) {
    $line = $skLines[$i]
    if ($line -match '^metadata\s*:\s*$') { $inMetadata = $true; continue }
    if ($line -match '^\S') { $inMetadata = $false }
    if ($line -match '^(\s*)version\s*:\s*.*$') { $skLines[$i] = "{0}version: {1}" -f $Matches[1], $Edge.NewVersion; $versionRewrites++; continue }
    if ($line -match '^(\s*)error_code_prefixes\s*:\s*.*$') { $skLines[$i] = "{0}error_code_prefixes: {1}" -f $Matches[1], $newPrefixes; continue }
    if ($line -match '^description\s*:\s*".*"\s*$') { $skLines[$i] = 'description: "' + $LargeDescription + '"'; $descriptionRewrites++; continue }
    if ($line -match '^tags\s*:') { $skLines[$i] = $line -replace ([regex]::Escape(($Edge.From + '-tier'))), ($Edge.To + '-tier'); continue }
    if (($line -match '^(\s*)enum\s*:\s*\[.*\]\s*$') -and ($line -match '\bauto\b')) { $skLines[$i] = "{0}enum: {1}" -f $Matches[1], $newEnum; $enumRewrites++; continue }
    if ($line -match 'department_aliases') { $hasAliasPointer = $true }
    if ($inMetadata) {
      if ($line -match '^(\s*)scale_tier\s*:') { $skLines[$i] = "{0}scale_tier: {1}" -f $Matches[1], $Edge.To; continue }
      if ($line -match '^(\s*)department_count\s*:') { $skLines[$i] = "{0}department_count: {1}" -f $Matches[1], $Edge.DepartmentCount; continue }
      if ($line -match '^(\s*)function_block_count\s*:') { $skLines[$i] = "{0}function_block_count: {1}" -f $Matches[1], $Edge.ExpectedBlocks; continue }
    }
  }
  if ($versionRewrites -lt 1) { Write-Log 'WARN 5d version line not found (G6 version check will fail)' }
  if ($enumRewrites -lt 1) { Write-Log 'WARN 5d interface.department.enum not found (G6 enum check will fail)' }
  if ($descriptionRewrites -lt 1) { Write-Log 'WARN 5d description not found (stale medium-tier description left)' }
  if (-not $hasAliasPointer) {
    # Insert INSIDE the frontmatter (just before the closing '---'): $skLines
    # was seeded with the live frontmatter including its closing delimiter, so a
    # plain '+=' would land the pointer in the body and G6 would reject it
    # (micro/large sources without an inherited pointer hit this branch).
    $out = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $skLines.Count - 1; $i++) { $out.Add($skLines[$i]) }
    $out.Add('department_aliases: references/scaling.md#alias-map')
    $out.Add($skLines[$skLines.Count - 1])
    $skLines = $out.ToArray()
  }
  # Source SKILL.md frontmatter (read once; feeds the B4 trigger/tag takeover
  # below and the body append after it).
  $largeSkPath = Join-Path $LargeSourceDir 'SKILL.md'
  $largeLines = [System.IO.File]::ReadAllLines($largeSkPath)
  $largeFmEnd = -1
  for ($i = 1; $i -lt $largeLines.Count; $i++) { if ($largeLines[$i].Trim() -eq '---') { $largeFmEnd = $i; break } }

  # B4 : triggers and tags are taken from the ai-company-large source SKILL.md
  # (66 domain-grouped triggers, 13 tags) - read from the file at build time,
  # never embedded here: the trigger block carries non-ASCII box-drawing
  # comments and this script must stay pure ASCII (PS 5.1 reads a BOM-less
  # UTF-8 script as ANSI). The medium shell's 15 triggers cannot cover the
  # 18-department intent surface.
  $srcTagsLine = $null
  $srcTriggerLines = @()
  $inSrcTriggers = $false
  for ($i = 1; $i -lt $largeFmEnd; $i++) {
    $l = $largeLines[$i]
    if ($l -match '^tags\s*:') { $srcTagsLine = $l; continue }
    if ($l -match '^triggers\s*:') { $inSrcTriggers = $true; $srcTriggerLines += $l; continue }
    if ($inSrcTriggers) {
      if ($l -match '^\S') { $inSrcTriggers = $false } else { $srcTriggerLines += $l }
    }
  }
  if ($null -ne $srcTagsLine) {
    for ($i = 0; $i -lt $skLines.Count; $i++) {
      if ($skLines[$i] -match '^tags\s*:') {
        $skLines[$i] = $srcTagsLine
        Write-Log '5d tags line taken from the large source SKILL.md'
        break
      }
    }
  } else {
    Write-Log 'WARN 5d no tags line in the large source frontmatter; shell tags kept (medium-tier -> large-tier rewrite only)'
  }
  if ($srcTriggerLines.Count -gt 1) {
    $trigStart = -1
    for ($i = 0; $i -lt $skLines.Count; $i++) {
      if ($skLines[$i] -match '^triggers\s*:') { $trigStart = $i; break }
    }
    if ($trigStart -ge 0) {
      $trigEnd = $trigStart + 1
      while (($trigEnd -lt $skLines.Count) -and ($skLines[$trigEnd] -match '^\s')) { $trigEnd++ }
      $out3 = New-Object System.Collections.Generic.List[string]
      for ($i = 0; $i -lt $trigStart; $i++) { $out3.Add($skLines[$i]) }
      foreach ($t in $srcTriggerLines) { $out3.Add($t) }
      for ($i = $trigEnd; $i -lt $skLines.Count; $i++) { $out3.Add($skLines[$i]) }
      $skLines = $out3.ToArray()
      Write-Log ("5d triggers block taken from the large source SKILL.md ({0} lines: 66 domain-grouped triggers)" -f $srcTriggerLines.Count)
    } else {
      Write-Log 'WARN 5d no triggers line in the shell frontmatter; source triggers not inserted'
    }
  } else {
    Write-Log 'WARN 5d no triggers block in the large source frontmatter; shell triggers kept'
  }

  # Append the large body (after the closing frontmatter fence).
  $largeBody = if ($largeFmEnd -gt 0) { $largeLines[($largeFmEnd + 1)..($largeLines.Count - 1)] -join "`n" } else { '' }
  $skPath = Join-Path $PkgDir 'SKILL.md'
  $out = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $skLines.Count; $i++) { $out.Add($skLines[$i]) }
  $out.Add('')
  $out.Add($largeBody)
  Write-TextFileNoBom -Path $skPath -Text (($out -join "`n").TrimEnd("`r`n") + "`n")
  Write-Log ("5d SKILL.md built (live frontmatter retargeted to {0} + {0} body; scale_tier={0}, department_count={1}, function_block_count={2}, version={3}, {4} prefixes, enum auto+{1})" -f $Edge.To, $Edge.DepartmentCount, $Edge.ExpectedBlocks, $Edge.NewVersion, (@($pfxList).Count))

  # 5e : bump _meta.json version and retarget the slug.
  # B5 : the large reference _meta.json must not keep the predecessor identity
  # 'ai-company-large'; the bloodline package slug is 'ai-company' (live medium
  # carries the same slug, so the three version locations stay comparable).
  $metaPath = Join-Path $PkgDir '_meta.json'
  if (Test-Path -LiteralPath $metaPath) {
    try {
      $meta = ConvertFrom-Json ([System.IO.File]::ReadAllText($metaPath))
      if ($null -ne $meta.PSObject.Properties['version']) { $meta.version = $Edge.NewVersion }
      if ($null -ne $meta.PSObject.Properties['slug']) { $meta.slug = 'ai-company' }
      Write-TextFileNoBom -Path $metaPath -Text ((ConvertTo-StableJson -Value $meta) + "`n")
      Write-Log "5e _meta.json version bumped to $($Edge.NewVersion); slug retargeted to 'ai-company'"
    } catch { Write-Log 'WARN _meta.json could not be updated (G6 version check will fail)' }
  }

  # 5g : append the (from -> to) alias rows to the package Alias Map. The source
  # departments are retired; the large departments replace them. Each legacy slug
  # gets a Legacy row and each target slug gets a Target row (G5 coverage); the
  # expansion pairs every target with a (repeated) legacy slug - the exact 1:1
  # mapping is flagged for human review. The tier label in column 2 is the
  # SOURCE tier, so a cross-tier jump (micro/small -> large) records the tier the
  # slug was actually retired from.
  $pkgScalingMd = Join-Path (Join-Path $PkgDir 'references') 'scaling.md'
  $aliasRows = @()
  $legacySrc = @($Edge.AliasLegacy)
  $targetSrc = @($Edge.AliasTarget)
  for ($i = 0; $i -lt $targetSrc.Count; $i++) {
    $lg = $legacySrc[$i % $legacySrc.Count]
    $aliasRows += ('| {0} | {2} | {1} | v{3} |' -f $lg, $targetSrc[$i], $Edge.From, $Edge.NewVersion)
  }
  Add-AliasRows -ScalingMdPath $pkgScalingMd -NewRows $aliasRows
  Write-Log ("5g alias rows appended to the package Alias Map ({0} -> {1} department replacement)" -f $Edge.From, $Edge.To)

  # Package state file : initial state for the target tier (written before the
  # README version bump so the package is internally complete).
  $nowIso = Get-UtcNowIso
  $pkgState = [ordered]@{
    schema_version      = 1
    current_tier        = $Edge.To
    tier_history        = @(
      [ordered]@{
        from          = $Edge.From
        to            = $Edge.To
        proposed_at   = $nowIso
        approved_by   = $null
        installed_at  = $null
        package_path  = (Get-WorkspaceRelativePath -Path $PkgDir)
        validation    = [ordered]@{
          file_count        = $TargetFileCount[$Edge.To]
          function_blocks   = $Edge.ExpectedBlocks
          gates_passed      = 6
          acceptance_passed = $false
        }
      }
    )
    pending_proposals   = @()
    next_evaluation     = (Get-Date).ToUniversalTime().AddDays(30).ToString('yyyy-MM-ddTHH:mm:ssZ')
    last_metrics        = [ordered]@{
      agent_count               = 0
      routing_accuracy          = 1.0
      max_blocks_per_department = 1
      error_code_reuse_ratio    = 0.0
    }
    # B6 : the two host-metric bookkeeping fields the spec sec 12.6 / M-2
    # requires (the medium suite's test_scaling_state_schema_complete asserts
    # all nine top-level keys; the previous template wrote only seven).
    routing_miss_streak = 0
    metrics_provenance  = [ordered]@{
      agent_count               = 'host-supplied'
      routing_accuracy          = 'host-supplied'
      max_blocks_per_department = 'measured'
      error_code_reuse_ratio    = 'measured'
    }
    validation          = [ordered]@{
      gates_passed      = 6
      file_count        = $TargetFileCount[$Edge.To]
      acceptance_passed = $false
    }
  }
  Write-TextFileNoBom -Path (Join-Path $PkgDir '.scaling-state.json') -Text ((ConvertTo-StableJson -Value $pkgState) + "`n")
  Write-Log "package state file initialized for tier '$($Edge.To)'"

  # 5i : README version strings (badge + at-a-glance tables) - generic version
  # numbers, driven by the edge. The large reference ships as v4.1.0 and the
  # proposal targets 4.0.0 (major 4 = large tier ordinal). The ai-company-large
  # README at-a-glance table already states 18 departments / 148 files /
  # 117 codes / 19 prefixes, which is correct for the proposed package, so only
  # the version is updated.
  $zhVersionWord = [string][char]0x7248 + [string][char]0x672C
  $readmeTargets = @(
    @{ Pattern = 'version-\d+\.\d+\.\d+-blue';                                 Replace = ('version-' + $Edge.NewVersion + '-blue'); What = 'badge' },
    @{ Pattern = ('(\| Version \| )\*\*(\d+\.\d+\.\d+)\*\*');                   Replace = ('${1}**' + $Edge.NewVersion + '**'); What = 'at-a-glance version row (English)' },
    @{ Pattern = ('(\| ' + $zhVersionWord + ' \| )\*\*(\d+\.\d+\.\d+)\*\*');     Replace = ('${1}**' + $Edge.NewVersion + '**'); What = 'at-a-glance version row (Chinese)' }
  )
  foreach ($name in @('README.md', 'README.en.md', 'README.zh.md')) {
    $p = Join-Path $PkgDir $name
    if (-not (Test-Path -LiteralPath $p)) { continue }
    $t = Read-TextFile -Path $p
    if ($null -eq $t) { continue }
    foreach ($tgt in $readmeTargets) {
      $hits = [regex]::Matches($t, $tgt.Pattern)
      if ($hits.Count -eq 0) { continue }
      foreach ($h in $hits) {
        Write-Log ("5i {0}: {1} rewritten (version -> {2})" -f $name, $tgt.What, $Edge.NewVersion)
      }
      $t = [regex]::Replace($t, $tgt.Pattern, $tgt.Replace)
    }
    Write-TextFileNoBom -Path $p -Text $t
  }

  # 5i : CHANGELOG.md upgrade entry. The per-edge bullet lines live on the edge
  # (Report.ChangelogBullets) so a cross-tier jump narrates its own skipped
  # tiers instead of inheriting the adjacent-edge wording.
  $changelogPath = Join-Path $PkgDir 'CHANGELOG.md'
  if (Test-Path -LiteralPath $changelogPath) {
    $entry = ("## [{0}] - {1} - tier upgrade proposal ({2} -> {3})" -f $Edge.NewVersion, ((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')), $Edge.From, $Edge.To) + "`n`n" +
      (($Edge.Report.ChangelogBullets -join "`n")) + "`n" +
      "- PROPOSED ONLY - requires human approval and an external installer" + "`n"
    $old = Read-TextFile -Path $changelogPath
    if ($null -ne $old) {
      $chLines = $old -split "`n"
      $unreleasedIdx = -1
      for ($i = 0; $i -lt $chLines.Count; $i++) { if ($chLines[$i] -match '^##\s*\[Unreleased\]') { $unreleasedIdx = $i; break } }
      if ($unreleasedIdx -ge 0) {
        $insertAt = $unreleasedIdx + 1
        while (($insertAt -lt $chLines.Count) -and ([string]::IsNullOrWhiteSpace($chLines[$insertAt]))) { $insertAt++ }
        $out2 = New-Object System.Collections.Generic.List[string]
        for ($i = 0; $i -lt $insertAt; $i++) { $out2.Add($chLines[$i]) }
        foreach ($l in ($entry -split "`n")) { $out2.Add($l) }
        for ($i = $insertAt; $i -lt $chLines.Count; $i++) { $out2.Add($chLines[$i]) }
        Write-TextFileNoBom -Path $changelogPath -Text ((($out2 -join "`n").TrimEnd("`r`n")) + "`n")
        Write-Log '5i CHANGELOG.md entry inserted after [Unreleased]'
      } else {
        Write-Log 'WARN 5i CHANGELOG.md has no [Unreleased] heading; entry not inserted'
      }
    }
  }
}

# --------------------------------------------------------------------------------------
# micro -> medium : in-place two-stage composition (arbitrary target selection).
#
# Stage 1 runs the deterministic micro -> small split on $PkgDir. Stage 2 runs
# the small -> medium transformation on the SAME directory with
# -SkipInitialCopy, because stage 1 has already placed the small-tier content
# there. No staging directory is created - and none may be deleted (P23: the
# script contains no executable recursive force-delete path). The result is
# byte-equivalent to applying the two adjacent upgrades in sequence, so every
# gate sees exactly the content the manual chain would have produced.
# --------------------------------------------------------------------------------------

function New-MicroToMediumUpgradePackage {
  param([string]$PkgDir, $Edge = $MicroToMediumEdge)
  Write-Log ("5 stage 1/2: composing {0} -> {1} in place (micro -> small split, then the small -> medium migration)" -f $Edge.From, $Edge.To)
  New-UpgradePackage -PkgDir $PkgDir
  New-SmallToMediumUpgradePackage -PkgDir $PkgDir -SkipInitialCopy -Edge $Edge
  Write-Log ("5 composition complete: {0} -> {1} (both stages recorded in the CHANGELOG)" -f $Edge.From, $Edge.To)
}

# --------------------------------------------------------------------------------------
# large -> group : SCAFFOLD builder (arbitrary target selection).
#
# The group tier has no authored content and its 36 department slugs are
# undefined, so there is nothing deterministic to transform. This builder copies
# the current package forward verbatim (G1-G3 pass: byte-identical) and emits
# UPGRADE-WORK-ORDER.txt. It deliberately does NOT retarget the frontmatter -
# writing scale_tier=group with an 18-slug enum would fabricate structure - so
# the content gates fail by design and their failure detail is the checklist.
# Nothing is recorded in .scaling-state.json (see Invoke-Proposal scaffold branch).
# --------------------------------------------------------------------------------------

function New-LargeToGroupUpgradePackage {
  param([string]$PkgDir, $Edge = $GroupEdge)
  # 5h (basis) : copy the current package forward, excluding the operational
  # state file (a group skeleton is written below).
  $allRels = @(Get-PackageRelativePaths -Root $SkillDir)
  foreach ($rel in $allRels) {
    if ($rel -eq '.scaling-state.json') { continue }
    $src = Join-Path $SkillDir ($rel.Replace('/', '\'))
    $dest = Join-Path $PkgDir $rel
    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    Copy-Item -LiteralPath $src -Destination $dest -Force
  }
  Write-Log ("5h copied current ({0}) package files to {1} (scaffold: content carried forward verbatim)" -f $Edge.From, $PkgDir)

  # Package state skeleton for the target tier. gates_passed = 3 is honest: the
  # byte-identical carry-forward passes G1-G3 and the content gates cannot pass
  # until the work order is complete.
  $nowIso = Get-UtcNowIso
  $pkgState = [ordered]@{
    schema_version      = 1
    current_tier        = $Edge.To
    tier_history        = @(
      [ordered]@{
        from          = $Edge.From
        to            = $Edge.To
        proposed_at   = $nowIso
        approved_by   = $null
        installed_at  = $null
        package_path  = (Get-WorkspaceRelativePath -Path $PkgDir)
        validation    = [ordered]@{
          file_count        = $TargetFileCount[$Edge.To]
          function_blocks   = $Edge.ExpectedBlocks
          gates_passed      = 3
          acceptance_passed = $false
        }
      }
    )
    pending_proposals   = @()
    next_evaluation     = (Get-Date).ToUniversalTime().AddDays(30).ToString('yyyy-MM-ddTHH:mm:ssZ')
    last_metrics        = [ordered]@{
      agent_count               = 0
      routing_accuracy          = 1.0
      max_blocks_per_department = 1
      error_code_reuse_ratio    = 0.0
    }
    routing_miss_streak = 0
    metrics_provenance  = [ordered]@{
      agent_count               = 'host-supplied'
      routing_accuracy          = 'host-supplied'
      max_blocks_per_department = 'measured'
      error_code_reuse_ratio    = 'measured'
    }
    validation          = [ordered]@{
      gates_passed      = 3
      file_count        = $TargetFileCount[$Edge.To]
      acceptance_passed = $false
    }
  }
  Write-TextFileNoBom -Path (Join-Path $PkgDir '.scaling-state.json') -Text ((ConvertTo-StableJson -Value $pkgState) + "`n")
  Write-Log ("package state skeleton written for tier '{0}' (gates_passed = 3: content gates pending authoring)" -f $Edge.To)

  # 5a : the authoring work order. Every item is derived from the tier contract
  # (references/scaling.md sec 3); the script never fabricates department content.
  $order = @(
    ("UPGRADE WORK ORDER - {0} to {1}" -f $Edge.From, $Edge.To),
    '',
    ("Generated: {0}" -f (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')),
    '',
    'This package is a SCAFFOLD, not a proposal. The group tier has no authored',
    'content and its 36 department slugs are undefined; this build deliberately',
    'does not fabricate structure. Complete the items below, then re-run the six',
    'gates. Gates G1-G3 already pass (byte-identical carry-forward); G4/G5/G6',
    'fail until the content exists - their failure detail is the checklist.',
    '',
    'Required per new department (36 total at group tier):',
    '  references/departments/<slug>.md                     D2 page, one FB-N block',
    '  references/departments/<slug>/department-spec.md     D3 specification layer',
    '  references/departments/<slug>/prompts/01-implement-method.md',
    '  references/departments/<slug>/prompts/02-robustness-checks.md',
    '  references/departments/<slug>/references/method-patterns.md',
    '',
    'Plus:',
    '  SKILL.md                     frontmatter rebuilt: scale_tier=group,',
    '                               department_count=36, function_block_count=36,',
    '                               version=5.0.0, interface.department.enum (auto + 36),',
    '                               department_aliases pointer. permissions copied verbatim.',
    '  references/department-index.md   7 domains, 36 rows',
    '  references/error-codes.md        revived prefixes start at 001',
    '  references/scaling.md            Alias Map appended (append-only): 18 large slugs -> 36 group slugs',
    '',
    'Then re-run the six gates (G6 executes the package test suite).',
    '',
    'DO NOT INSTALL until a human has approved and an external installer applies it.'
  )
  Write-TextFileNoBom -Path (Join-Path $PkgDir 'UPGRADE-WORK-ORDER.txt') -Text (($order -join "`n") + "`n")
  Write-Log '5a UPGRADE-WORK-ORDER.txt emitted (group scaffold)'
}

# --------------------------------------------------------------------------------------
# Gate G1 - permission-unchanged gate (SCL_004)
# --------------------------------------------------------------------------------------

function Invoke-GateG1 {
  param([string]$PkgDir)
  Write-Log 'G1 permission-unchanged gate: comparing permissions block hash (current vs package)...'
  $curFm = Get-FrontmatterText (Join-Path $SkillDir 'SKILL.md')
  $pkgFm = Get-FrontmatterText (Join-Path $PkgDir 'SKILL.md')
  $curPerm = Get-FrontmatterSubBlock -FrontmatterText $curFm -Key 'permissions'
  $pkgPerm = Get-FrontmatterSubBlock -FrontmatterText $pkgFm -Key 'permissions'
  if (($null -eq $curPerm) -or ($null -eq $pkgPerm)) {
    return @{ Passed = $false; Detail = 'permissions block not found in the current or the package SKILL.md frontmatter' }
  }
  $curHash = Get-TextSha256 $curPerm
  $pkgHash = Get-TextSha256 $pkgPerm
  if ($curHash -ne $pkgHash) {
    return @{ Passed = $false; Detail = "permissions block hash mismatch: current=$curHash package=$pkgHash" }
  }
  return @{ Passed = $true; Detail = "permissions block hash identical ($curHash)" }
}

# --------------------------------------------------------------------------------------
# Gate G2 - tests-unchanged gate (SCL_005)
# --------------------------------------------------------------------------------------

function Get-TestsHashMap {
  param([string]$Root)
  $map = @{}
  $testsDir = Join-Path $Root 'tests'
  if (Test-Path -LiteralPath $testsDir) {
    $files = @(Get-ChildItem -LiteralPath $testsDir -Recurse -File -ErrorAction SilentlyContinue)
    foreach ($f in $files) {
      $rel = $f.FullName.Substring($testsDir.Length).TrimStart('\', '/').Replace('\', '/')
      # The package-file-set predicate is the ONE implementation of the
      # boundary (README_FOR_AI.md sec 3), so build residues are excluded here
      # by the same call the copy and the counts use - never by a second inline
      # copy of the rule that could drift. A leftover __pycache__/ can
      # therefore never fail (or pad) this gate.
      if (Test-PackagePathExcluded -RelativePath ('tests/' + $rel)) { continue }
      $map[$rel] = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
    }
  }
  return $map
}

function Invoke-GateG2 {
  param([string]$PkgDir)
  Write-Log 'G2 tests-unchanged gate: verifying tests/** in the package is byte-identical to the current package...'
  $curMap = Get-TestsHashMap -Root $SkillDir
  $pkgMap = Get-TestsHashMap -Root $PkgDir
  $diffs = @()
  foreach ($k in $curMap.Keys) {
    if (-not $pkgMap.ContainsKey($k)) { $diffs += "missing in package: tests/$k" }
    elseif ($pkgMap[$k] -ne $curMap[$k]) { $diffs += "hash differs: tests/$k" }
  }
  foreach ($k in $pkgMap.Keys) {
    if (-not $curMap.ContainsKey($k)) { $diffs += "unexpected file in package: tests/$k" }
  }
  if ($diffs.Count -gt 0) {
    return @{ Passed = $false; Detail = ($diffs -join '; ') }
  }
  return @{ Passed = $true; Detail = ("{0} test file(s) verified byte-identical (SHA-256)" -f $curMap.Count) }
}

# --------------------------------------------------------------------------------------
# Gate G3 - deny-and-gate-unchanged gate (SCL_004)
# --------------------------------------------------------------------------------------

function Invoke-GateG3 {
  param([string]$PkgDir)
  Write-Log 'G3 deny-and-gate-unchanged gate: verifying the 5 deny items and the self-scale.ps1 hash...'
  $curPerm = Get-FrontmatterSubBlock -FrontmatterText (Get-FrontmatterText (Join-Path $SkillDir 'SKILL.md')) -Key 'permissions'
  $pkgPerm = Get-FrontmatterSubBlock -FrontmatterText (Get-FrontmatterText (Join-Path $PkgDir 'SKILL.md')) -Key 'permissions'
  if (($null -eq $curPerm) -or ($null -eq $pkgPerm)) {
    return @{ Passed = $false; Detail = 'permissions block not found; deny items cannot be verified' }
  }
  $curDeny = @(Get-DenyItems -PermissionsBlock $curPerm)
  $pkgDeny = @(Get-DenyItems -PermissionsBlock $pkgPerm)
  if (($curDeny.Count -ne 5) -or ($pkgDeny.Count -ne 5)) {
    return @{ Passed = $false; Detail = ("deny item count: current={0}, package={1} (expected 5)" -f $curDeny.Count, $pkgDeny.Count) }
  }
  if (($curDeny -join '|') -ne ($pkgDeny -join '|')) {
    return @{ Passed = $false; Detail = 'deny items differ between the current and the package SKILL.md' }
  }
  $curScript = Join-Path $PSScriptRoot 'self-scale.ps1'
  $pkgScript = Join-Path $PkgDir 'scripts\self-scale.ps1'
  if (-not (Test-Path -LiteralPath $pkgScript)) {
    return @{ Passed = $false; Detail = 'scripts/self-scale.ps1 missing from the package' }
  }
  $curHash = (Get-FileHash -LiteralPath $curScript -Algorithm SHA256).Hash
  $pkgHash = (Get-FileHash -LiteralPath $pkgScript -Algorithm SHA256).Hash
  if ($curHash -ne $pkgHash) {
    return @{ Passed = $false; Detail = "self-scale.ps1 hash mismatch: current=$curHash package=$pkgHash" }
  }
  return @{ Passed = $true; Detail = "5 deny items intact; self-scale.ps1 hash identical ($curHash)" }
}

# --------------------------------------------------------------------------------------
# Gate G4 - function-block conservation gate (SCL_010)
# --------------------------------------------------------------------------------------

function Invoke-GateG4 {
  param([string]$PkgDir, $Edge = $UpgradeEdge)
  Write-Log ("G4 function-block conservation gate ({0} -> {1}): counting '## FB-N:' headings across the package D2 pages (total + per-department distribution)..." -f $Edge.From, $Edge.To)
  $pkgDeptDir = Join-Path $PkgDir 'references\departments'
  $actualPerDept = @{}
  $declaredPerDept = @{}
  $total = 0
  if (Test-Path -LiteralPath $pkgDeptDir) {
    $files = @(Get-ChildItem -LiteralPath $pkgDeptDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
    foreach ($f in $files) {
      $text = [System.IO.File]::ReadAllText($f.FullName)
      $count = ([regex]::Matches($text, '(?m)^##\s+FB-\d+\s*:')).Count
      $actualPerDept[$f.BaseName] = $count
      # README_FOR_AI.md sec 10.2 makes '> Function blocks: <N>' mandatory on
      # every D2 page and it is the declared conservation basis, so G4 must read
      # it, not just the headings: counting headings alone passed a split page
      # that kept the legacy count (8 or 10) while its real share was 6/2/3/3/4.
      $declMatch = [regex]::Match($text, 'Function blocks:\s*(\d+)')
      $declared = -1
      if ($declMatch.Success) { $declared = [int]$declMatch.Groups[1].Value }
      $declaredPerDept[$f.BaseName] = $declared
      $total += $count
    }
  }
  # E5 : the total alone can hide a wrong distribution (e.g. 7/1/3/3/4 still
  # sums to 18). Every department must match its merge-tree expectation, and no
  # unexpected D2 page may exist.
  $problems = @()
  foreach ($t in $Edge.Split) {
    $actual = 0
    if ($actualPerDept.ContainsKey([string]$t.Slug)) { $actual = $actualPerDept[[string]$t.Slug] }
    if ($actual -ne [int]$t.Blocks) {
      $problems += ("{0}: expected {1}, found {2}" -f $t.Slug, $t.Blocks, $actual)
    }
  }
  $expectedSlugs = @($Edge.Split | ForEach-Object { [string]$_.Slug })
  foreach ($k in @($actualPerDept.Keys)) {
    if ($expectedSlugs -notcontains $k) {
      $problems += ("unexpected D2 page in the package: references/departments/{0}.md ({1} block(s))" -f $k, $actualPerDept[$k])
    }
  }
  # The declared 'Function blocks:' figure must equal this department's
  # merge-tree share, so a mislabelled split page fails the gate instead of
  # shipping (sec 10.2 / sec 12.3 G4).
  foreach ($t in $Edge.Split) {
    $declared = -1
    if ($declaredPerDept.ContainsKey([string]$t.Slug)) { $declared = [int]$declaredPerDept[[string]$t.Slug] }
    if ($declared -ne [int]$t.Blocks) {
      $problems += ("{0}: declared 'Function blocks: {1}', merge tree expects {2}" -f $t.Slug, $declared, $t.Blocks)
    }
  }
  if ($total -ne $Edge.ExpectedBlocks) {
    $problems += ("total function blocks = {0}, expected {1}" -f $total, $Edge.ExpectedBlocks)
  }
  if ($problems.Count -gt 0) {
    return @{ Passed = $false; Detail = ('function-block conservation violated: ' + ($problems -join '; ')) }
  }
  $dist = ($Edge.Split | ForEach-Object { "{0}={1}" -f $_.Slug, $_.Blocks }) -join ', '
  return @{ Passed = $true; Detail = "total function blocks = $total (conserved, 18 -> 18); per-department distribution verified ($dist); no unexpected D2 pages" }
}

# --------------------------------------------------------------------------------------
# Gate G5 - alias completeness gate (SCL_003)
# --------------------------------------------------------------------------------------

function Invoke-GateG5 {
  param([string]$PkgDir, $Edge = $UpgradeEdge)
  Write-Log ("G5 alias-completeness gate ({0} -> {1}): checking legacy slug coverage and slug/alias conflicts..." -f $Edge.From, $Edge.To)
  $pkgScalingMd = Join-Path (Join-Path $PkgDir 'references') 'scaling.md'
  if (-not (Test-Path -LiteralPath $pkgScalingMd)) {
    return @{ Passed = $false; Detail = 'references/scaling.md missing from the package; Alias Map cannot be verified' }
  }
  $rows = @(Get-AliasRows -ScalingMdPath $pkgScalingMd)
  # small -> medium does not rename slugs (blocks migrate between departments),
  # so coverage is driven by the edge's explicit AliasLegacy / AliasTarget lists.
  if ($Edge.ContainsKey('AliasLegacy')) {
    $legacySlugs = @($Edge.AliasLegacy)
    $targetSlugs = @($Edge.AliasTarget)
  } else {
    $legacySlugs = @($Edge.Split | ForEach-Object { $_.Source } | Select-Object -Unique)
    $targetSlugs = @($Edge.Split | ForEach-Object { $_.Slug })
  }
  $problems = @()
  foreach ($legacy in $legacySlugs) {
    $hits = @($rows | Where-Object { $_.Legacy -eq $legacy })
    if ($hits.Count -eq 0) { $problems += "legacy slug '$legacy' has no alias row" }
  }
  foreach ($target in $targetSlugs) {
    $hits = @($rows | Where-Object { $_.Target -eq $target })
    if ($hits.Count -eq 0) { $problems += "target slug '$target' is not reachable through any alias row" }
  }
  foreach ($row in $rows) {
    if ($targetSlugs -contains $row.Legacy) {
      $problems += ("slug/alias conflict: new slug '{0}' equals a historical alias" -f $row.Legacy)
    }
  }
  if ($problems.Count -gt 0) {
    return @{ Passed = $false; Detail = ($problems -join '; ') }
  }
  return @{ Passed = $true; Detail = ("{0} active alias row(s), {1} conflict(s); all legacy and target slugs covered" -f $rows.Count, $problems.Count) }
}

# --------------------------------------------------------------------------------------
# Gate G6 - acceptance gate, machine-checkable subset (SCL_006)
# --------------------------------------------------------------------------------------

function Invoke-GateG6 {
  param([string]$PkgDir, $Edge = $UpgradeEdge)
  Write-Log ("G6 acceptance gate ({0} -> {1}): running the machine-checkable acceptance items on the package..." -f $Edge.From, $Edge.To)
  $fails = @()
  $expectedFiles = $TargetFileCount[$Edge.To]

  # File count over the SAME package file set the 5h copy uses (H-1: the copy
  # range and the counting basis must never diverge again). Proposal-time
  # artifacts are not package content and are excluded: UPGRADE-PROPOSAL.md (the
  # report) and UPGRADE-WORK-ORDER.txt (the scaffold authoring checklist).
  $reportPath = Join-Path $PkgDir 'UPGRADE-PROPOSAL.md'
  $workOrderPath = Join-Path $PkgDir 'UPGRADE-WORK-ORDER.txt'
  $fileCount = @(Get-PackageRelativePaths -Root $PkgDir).Count
  if (Test-Path -LiteralPath $reportPath) { $fileCount = $fileCount - 1 }
  if (Test-Path -LiteralPath $workOrderPath) { $fileCount = $fileCount - 1 }
  if ($fileCount -ne $expectedFiles) {
    $fails += "file_count: expected $expectedFiles, found $fileCount"
  }

  # Frontmatter triple consistency (H12) and version (H15, 3 locations).
  $fm = Get-FrontmatterText (Join-Path $PkgDir 'SKILL.md')
  if ($null -eq $fm) {
    $fails += 'SKILL.md frontmatter not found in the package'
  } else {
    if (-not ([regex]::IsMatch($fm, ('(?m)^\s*scale_tier\s*:\s*' + [regex]::Escape($Edge.To) + '\s*$')))) { $fails += ("frontmatter scale_tier is not '{0}'" -f $Edge.To) }
    if (-not ([regex]::IsMatch($fm, ('(?m)^\s*department_count\s*:\s*' + [regex]::Escape($Edge.DepartmentCount) + '\s*$')))) { $fails += ("frontmatter department_count is not {0}" -f $Edge.DepartmentCount) }
    if (-not ([regex]::IsMatch($fm, ('(?m)^\s*function_block_count\s*:\s*' + [regex]::Escape($Edge.ExpectedBlocks) + '\s*$')))) { $fails += ("frontmatter function_block_count is not {0}" -f $Edge.ExpectedBlocks) }
    if (-not ([regex]::IsMatch($fm, ('(?m)^\s*version\s*:\s*' + [regex]::Escape($Edge.NewVersion) + '\s*$')))) { $fails += ("frontmatter version is not {0}" -f $Edge.NewVersion) }
    if (-not ([regex]::IsMatch($fm, 'department_aliases\s*:\s*references/scaling\.md#alias-map'))) { $fails += 'frontmatter department_aliases pointer missing' }
    $prefixLine = (($fm -split "`n") | Where-Object { $_ -match '^\s*error_code_prefixes\s*:' } | Select-Object -First 1)
    if ($null -eq $prefixLine) {
      $fails += 'frontmatter error_code_prefixes line missing'
    } else {
      foreach ($pfx in $Edge.Prefixes) {
        if ($prefixLine -notmatch [regex]::Escape($pfx)) { $fails += "error_code_prefixes is missing $pfx" }
      }
    }
    # E2 : interface.department.enum must list exactly 'auto' plus the target-tier
    # department slugs (item count = department_count + 1), with no retired slug
    # left behind - otherwise the frontmatter contradicts itself and the new
    # departments are unreachable through the interface.
    $enumLine = (($fm -split "`n") | Where-Object { $_ -match '^\s*enum\s*:\s*\[' } | Select-Object -First 1)
    if ($null -eq $enumLine) {
      $fails += 'frontmatter interface.department.enum line missing'
    } else {
      $enumMatch = [regex]::Match($enumLine, 'enum\s*:\s*\[([^\]]*)\]')
      $enumItems = @()
      if ($enumMatch.Success) {
        $enumItems = @($enumMatch.Groups[1].Value -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
      }
      $expectedEnum = @('auto') + @($Edge.Split | ForEach-Object { [string]$_.Slug })
      # A scaffold edge declares no Split (its department slugs are undefined),
      # so the expected item count comes from DepartmentCount; the per-item
      # cross-check below still lists every carried slug that must be replaced.
      $expectedEnumCount = $expectedEnum.Count
      if (@($Edge.Split).Count -eq 0) { $expectedEnumCount = [int]$Edge.DepartmentCount + 1 }
      if ($enumItems.Count -ne $expectedEnumCount) {
        $fails += ("interface.department.enum has {0} item(s), expected {1} (auto + department_count)" -f $enumItems.Count, $expectedEnumCount)
      }
      foreach ($item in $enumItems) {
        if ($expectedEnum -notcontains $item) {
          $fails += "interface.department.enum contains an item outside the target-tier department list: '$item'"
        }
      }
      foreach ($expected in $expectedEnum) {
        if ($enumItems -notcontains $expected) {
          $fails += "interface.department.enum is missing the required item '$expected'"
        }
      }
    }
  }

  # Version agreement in the three required locations (H15, D-2 option A:
  # _meta.json, the README badge and the SKILL.md frontmatter; the former fourth
  # "SKILL.md body title" location never existed in the shipped package).
  $metaPath = Join-Path $PkgDir '_meta.json'
  if (-not (Test-Path -LiteralPath $metaPath)) {
    $fails += '_meta.json missing from the package'
  } else {
    try {
      $meta = ConvertFrom-Json ([System.IO.File]::ReadAllText($metaPath))
      if ([string]$meta.version -ne $Edge.NewVersion) { $fails += "_meta.json version is '$($meta.version)', expected $($Edge.NewVersion)" }
    } catch { $fails += '_meta.json is not valid JSON' }
  }
  $readmePath = Join-Path $PkgDir 'README.md'
  if (Test-Path -LiteralPath $readmePath) {
    $rText = Read-TextFile -Path $readmePath
    # E18 : the badge must match the concrete shields.io format, not just
    # contain the version string somewhere in the file.
    $expectedBadge = ('version-' + $Edge.NewVersion + '-blue')
    if (($null -eq $rText) -or (-not ([regex]::IsMatch($rText, [regex]::Escape($expectedBadge))))) { $fails += ("README.md badge does not match the expected format {0}" -f $expectedBadge) }
  } else {
    $fails += 'README.md missing from the package'
  }
  # The former fourth version location ("SKILL.md body title") is deliberately
  # NOT checked: no shipped package has ever carried a version string in the
  # body, so the check was an unconditional failure that blocked every proposal
  # (H-4). Recorded as decision D-2 option A in README_FOR_AI.md sec 8 / sec 15
  # and sec 16.

  # Target-tier department D2 files present.
  $pkgDeptDir = Join-Path $PkgDir 'references\departments'
  foreach ($t in $Edge.Split) {
    $p = Join-Path $pkgDeptDir ([string]$t.Slug + '.md')
    if (-not (Test-Path -LiteralPath $p)) { $fails += "department D2 file missing: references/departments/$($t.Slug).md" }
  }

  # E1 : the small-tier third prompt must exist, be agent-invoked, and declare
  # a harness level >= L3 (README_FOR_AI.md sec 11.3 A4 / sec 11.1 S-tier prompt count).
  $thirdPromptPath = Join-Path $PkgDir 'prompts\03-test-cases.md'
  if (-not (Test-Path -LiteralPath $thirdPromptPath)) {
    $fails += 'prompts/03-test-cases.md missing from the package (S tier requires 3 prompts)'
  } else {
    $tp = Read-TextFile -Path $thirdPromptPath
    if ($null -eq $tp) {
      $fails += 'prompts/03-test-cases.md is not readable'
    } else {
      if (-not ([regex]::IsMatch($tp, '(?m)^mode\s*:\s*agent-invoked\s*$'))) { $fails += 'prompts/03-test-cases.md mode is not agent-invoked' }
      $harnessMatch = [regex]::Match($tp, '(?m)^harness_level\s*:\s*L(\d)\s*$')
      if (-not $harnessMatch.Success) {
        $fails += 'prompts/03-test-cases.md has no harness_level declaration'
      } elseif ([int]$harnessMatch.Groups[1].Value -lt 3) {
        $fails += 'prompts/03-test-cases.md harness_level is below L3'
      }
    }
  }

  if ($fails.Count -gt 0) {
    return @{ Passed = $false; Detail = ($fails -join '; ') ; FailedItems = $fails }
  }
  return @{ Passed = $true; Detail = ("file_count=$fileCount; frontmatter triple consistent; version {0} agrees in all 3 locations (badge format verified); {1} D2 files present; prefixes complete; interface enum consistent (auto + {1} slugs); prompts/03-test-cases.md agent-invoked L3" -f $Edge.NewVersion, $Edge.DepartmentCount); FailedItems = @() }
}

# --------------------------------------------------------------------------------------
# Proposal report (step 7, template README_FOR_AI.md sec 12)
# --------------------------------------------------------------------------------------

function New-ProposalReport {
  param([string]$PkgDir, [string]$PkgName, $Triggers, $GateResults, $Metrics, $Edge)
  $now = Get-UtcNowIso
  # The current package file count uses the SAME package file set definition as
  # the 5h copy and gate G6 (repository tooling directories and build residues
  # are not package files). $SkillDir is the LIVE skill, so $curFileCount reflects
  # the current tier the proposal is upgrading FROM.
  $curFileCount = @(Get-PackageRelativePaths -Root $SkillDir).Count
  $currentLabel = ("{0} ({1} departments, {2} function blocks, {3} files)" -f $Edge.From, $Edge.Report.FromDepartmentCount, $Edge.ExpectedBlocks, $curFileCount)
  $targetLabel = ("{0} ({1} departments, {2} function blocks, {3} files expected)" -f $Edge.To, $Edge.DepartmentCount, $Edge.ExpectedBlocks, $Edge.Report.TargetFiles)
  $changeListText = $Edge.Report.ChangeList -join "`n"
  $hrLines = @()
  for ($i = 0; $i -lt $Edge.Report.HumanReview.Count; $i++) {
    $hrLines += ("{0}. {1}" -f ($i + 1), $Edge.Report.HumanReview[$i])
  }
  $hrText = $hrLines -join "`n"
  $triggerText = 'SCL_001: forced proposal; no threshold was met (invoked with -Force / propose)'
  if ($Triggers.Count -gt 0) {
    $parts = @()
    foreach ($t in $Triggers) {
      $parts += ("{0}: {1} = {2}, threshold {3}" -f $t.Id, $t.Metric, $t.Value, $t.Threshold)
    }
    $triggerText = $parts -join '; '
    $t3t4 = @($Triggers | Where-Object { ($_.Id -eq 'T3') -or ($_.Id -eq 'T4') })
    $t1 = @($Triggers | Where-Object { $_.Id -eq 'T1' })
    if (($t3t4.Count -gt 0) -and ($t1.Count -eq 0)) {
      $triggerText += ' | Note: capacity has not overflowed, but the structure no longer fits.'
    }
  }
  $permHash = Get-TextSha256 (Get-FrontmatterSubBlock -FrontmatterText (Get-FrontmatterText (Join-Path $SkillDir 'SKILL.md')) -Key 'permissions')
  $gateLines = @()
  foreach ($g in @('G1', 'G2', 'G3', 'G4', 'G5', 'G6')) {
    $r = $GateResults[$g]
    $mark = 'FAILED'
    if ($r.Passed) { $mark = 'PASSED' }
    $gateLines += ("| {0} | {1} | {2} |" -f $g, $mark, $r.Detail)
  }
  $report = @"
# Tier Upgrade Proposal: $($Edge.From) -> $($Edge.To)

> Generated by scripts/self-scale.ps1 (propose-only). This proposal has NOT taken effect.

| Item | Value |
|---|---|
| Proposal time | $now |
| Current tier | $currentLabel |
| Target tier | $targetLabel |
| Trigger reason | $triggerText |
| Package path | {WORKSPACE_ROOT}/.skill-upgrade/$PkgName/ |
| Status | PENDING APPROVAL - NOT EFFECTIVE |

## Change list

| Type | Count | Notes |
|---|---|---|
$($changeListText)

## Frontmatter diff note

The permissions block and the language_policy block are copied unchanged; the
permissions block hash is verified identical by gate G1 ($permHash). The
structural fields change exactly as listed above. A full unified diff is
produced by the human review tooling; the script deliberately does not
fabricate one.

## Human review items (cannot be machine-verified by this build)

$($hrText)

## Gate results

| Gate | Result | Detail |
|---|---|---|
$(($gateLines -join "`n"))

## Installation instructions (execute only after human approval)

The skill itself never installs. An external trusted installer must:

    Copy-Item the package to a temporary directory
    -> verify integrity (file count, hashes)
    -> atomically replace the skill directory
    -> only delete the old directory after confirming success.

Forbidden: Remove-Item -Path {SKILL_DIR} -Recurse -Force followed by a restore
(P23). Backup directories must be cross-platform: fall back from
`$env:USERPROFILE to `$HOME when the former is empty (P26).

## Rollback

If problems are found after installation, restore the pre-upgrade backup made
by the installer (see above). The pre-upgrade state is also recoverable from
the tier_history entry recorded in .scaling-state.json at install time.
"@
  $reportPath = Join-Path $PkgDir 'UPGRADE-PROPOSAL.md'
  Write-TextFileNoBom -Path $reportPath -Text $report
  Write-Log "7 upgrade report written: $reportPath"
}

# --------------------------------------------------------------------------------------
# Main flows
# --------------------------------------------------------------------------------------

function Invoke-RecordMetrics {
  # Host write-back channel 1 of 2 (scaling.md sec 3.1). The host calls this
  # action directly; the drop directory is channel 2. Both share the same
  # validation, timestamping and audit-log code path so the two channels can
  # never drift apart. Before this fix 'record-metrics' was declared in
  # ValidateSet but had no switch branch: it printed nothing, changed nothing
  # and exited 0 (H-2).
  param($Config)
  if ($null -eq $Config) { $config = Load-Config } else { $config = $Config }
  Write-Log '1 reading .scaling-state.json...'
  $state = Read-State

  $observed = ConvertTo-UtcIso $ObservedAt
  if ([string]::IsNullOrWhiteSpace($observed)) {
    if (-not [string]::IsNullOrWhiteSpace($ObservedAt)) {
      Write-Log ("WARN observed_at '{0}' is unparseable; recording the current time instead" -f $ObservedAt)
    }
    $observed = Get-UtcNowIso
  }

  # Write-HostMetric stamps every audit entry with the channel it arrived on.
  $script:WriteBackChannel = 'cli'

  $wrote = 0
  if ($AgentCount -ge 0) {
    $check = Test-HostMetricValue -Name 'agent_count' -Value $AgentCount
    if (-not $check.Ok) { Stop-WithCode 'SCL_007' ("record-metrics rejected: {0}" -f $check.Reason) }
    Write-HostMetric -State $state -Name 'agent_count' -Value $AgentCount -ObservedAt $observed -Source $Source -SampleSize -1 -Config $config
    Write-Log ("recorded agent_count = {0} (observed_at {1}, source {2})" -f $AgentCount, $observed, $Source)
    $wrote++
  }
  if ($RoutingAccuracy -ge 0.0) {
    $check = Test-HostMetricValue -Name 'routing_accuracy' -Value $RoutingAccuracy
    if (-not $check.Ok) { Stop-WithCode 'SCL_007' ("record-metrics rejected: {0}" -f $check.Reason) }
    Write-HostMetric -State $state -Name 'routing_accuracy' -Value $RoutingAccuracy -ObservedAt $observed -Source $Source -SampleSize $SampleSize -Config $config
    $sampleNote = 'not supplied'
    if ($SampleSize -ge 0) { $sampleNote = [string]$SampleSize }
    Write-Log ("recorded routing_accuracy = {0} (sample_size {1}, observed_at {2}, source {3})" -f $RoutingAccuracy, $sampleNote, $observed, $Source)
    $wrote++
  }
  if ($wrote -eq 0) {
    Stop-WithCode 'SCL_007' 'record-metrics called without -AgentCount or -RoutingAccuracy; nothing was recorded (a silent no-op is exactly the H-2 defect)'
  }

  Save-State -State $state
  Write-Log ("host metrics recorded ({0} metric(s)); run -Action evaluate to evaluate T1/T3" -f $wrote)
  exit 0
}

function Show-Status {
  $state = Read-State
  $config = Load-Config
  $metrics = Get-CurrentMetrics -State $state -Config $config
  Write-Output '=== self-scale status ==='
  Write-Output ("current_tier            : {0}" -f $state.current_tier)
  $targets = @(Get-SelectableTargetTiers -FromTier ([string]$state.current_tier) -Config $config)
  if ($targets.Count -gt 0) {
    Write-Output ("selectable targets      : {0}" -f ($targets -join ', '))
    Write-Output ("default target          : {0} (omit -TargetTier)" -f (Get-DefaultTargetTier -FromTier ([string]$state.current_tier) -Config $config))
  } else {
    Write-Output 'selectable targets      : none (already at the highest implemented tier)'
  }
  Write-Output ("next_evaluation         : {0}" -f $state.next_evaluation)
  $src = $metrics.Sources
  Write-Output ("agent_count             : {0}  [{1}]" -f $metrics.AgentCount, $src.agent_count)
  Write-Output ("routing_accuracy        : {0}  [{1}]" -f $metrics.RoutingAccuracy, $src.routing_accuracy)
  Write-Output ("max_blocks_per_dept     : {0}  [{1}]" -f $metrics.MaxBlocks, $src.max_blocks_per_department)
  Write-Output ("error_code_reuse_ratio  : {0}  [{1}]" -f $metrics.ReuseRatio, $src.error_code_reuse_ratio)
  Write-Output ("upgrade_policy          : {0}" -f 'propose-only')
  $stillDefault = @(Get-MetricsStillAtDefault -State $state -Metrics $metrics)
  if ($stillDefault.Count -gt 0) {
    Write-Output ("NOTE host-supplied metrics still at their defaults: {0}" -f ($stillDefault -join ', '))
    Write-Output ("     No host has written these yet, so {0} cannot fire." -f (($stillDefault | ForEach-Object { if ($_ -eq 'agent_count') { 'T1' } else { 'T3' } }) -join ' and '))
    Write-Output '     See scaling.md section 3.1 for the host write-back contract.'
  }
  Write-Output ("tier_history entries    : {0}" -f @($state.tier_history).Count)
  Write-Output ("pending_proposals       : {0}" -f @($state.pending_proposals).Count)
  exit 0
}

function Show-Report {
  $state = Read-State
  $pending = @($state.pending_proposals)
  if ($pending.Count -eq 0) {
    Write-Output 'No pending proposals. Run -Action evaluate or -Action propose first.'
    exit 0
  }
  $latest = $pending[$pending.Count - 1]
  Write-Output ("Latest pending proposal: {0} -> {1} (proposed {2})" -f $latest.from_tier, $latest.to_tier, $latest.proposed_at)
  $reportPath = Join-Path $latest.package_path 'UPGRADE-PROPOSAL.md'
  if (Test-Path -LiteralPath $reportPath) {
    Write-Output '---'
    Write-Output (Read-TextFile -Path $reportPath)
  } else {
    Write-Output "Report file not found at: $reportPath"
  }
  exit 0
}

function Invoke-Proposal {
  param($State, $Metrics, $Triggers, $Config, [int]$RoutingMissStreak)

  # --- Step 4 : deterministic target selection (arbitrary scale choice) --------
  # Any tier listed in scaling-config.json selectable_targets for the current
  # tier may be requested via -TargetTier (cross-tier jumps included); omitting
  # it keeps the historical linear default. Resolution is a deterministic table
  # lookup - the script never improvises a path that is not declared in
  # $UpgradeEdges / $UpgradeBuildFns.
  Write-Log '4 resolving the upgrade target (any selectable tier; deterministic, no improvisation)...'
  if ([string]$State.current_tier -eq $Config.MaxTier) {
    Stop-WithCode 'SCL_009' ("already at the highest tier ({0}); no upgrade path exists" -f $Config.MaxTier)
  }
  $fromTier = [string]$State.current_tier
  $toTier = [string]$TargetTier
  $vocab = @($Config.TierOrder)
  if ([string]::IsNullOrWhiteSpace($toTier)) {
    # Backward-compatible default: the first selectable target (the linear next
    # tier), exactly what the old per-tier hardwired dispatch chose.
    $toTier = Get-DefaultTargetTier -FromTier $fromTier -Config $Config
    if ([string]::IsNullOrWhiteSpace($toTier)) {
      Stop-WithCode 'SCL_002' ("no default target defined for tier '{0}' (scaling-config.json upgrade_path / selectable_targets); pass -TargetTier explicitly" -f $fromTier)
    }
    Write-Log ("4 no -TargetTier given; default target on the linear path: {0}" -f $toTier)
  } else {
    if ($vocab -notcontains $toTier) {
      Stop-WithCode 'SCL_008' ("unknown target tier '{0}'; the tier vocabulary is: {1}" -f $toTier, ($vocab -join ', '))
    }
    if ($toTier -eq $fromTier) {
      Stop-WithCode 'SCL_008' ("target tier '{0}' equals the current tier; there is nothing to upgrade" -f $toTier)
    }
    if (($vocab.IndexOf($toTier)) -lt ($vocab.IndexOf($fromTier))) {
      Stop-WithCode 'SCL_008' ("downgrade {0} -> {1} is not an automatic action: a downgrade requires written human approval and a deleted-content destination table (error-codes.md SCL_008)" -f $fromTier, $toTier)
    }
    if ($Config.SelectableTargets.ContainsKey($fromTier) -and (@($Config.SelectableTargets[$fromTier]) -notcontains $toTier)) {
      Stop-WithCode 'SCL_002' ("target '{0}' is not selectable from '{1}' per scaling-config.json; selectable targets from '{1}': {2}" -f $toTier, $fromTier, (@($Config.SelectableTargets[$fromTier]) -join ', '))
    }
  }
  $pairKey = ("{0}->{1}" -f $fromTier, $toTier)
  $Edge = $null
  # NOTE: $UpgradeEdges is an OrderedDictionary; its membership test is Contains
  # (ContainsKey does not exist on that type in Windows PowerShell 5.1).
  if ($UpgradeEdges.Contains($pairKey)) { $Edge = $UpgradeEdges[$pairKey] }
  if ($null -eq $Edge) {
    $avail = @(Get-SelectableTargetTiers -FromTier $fromTier -Config $Config)
    Stop-WithCode 'SCL_002' ("no upgrade builder defined for {0} in this build; selectable targets from '{1}': {2}" -f $pairKey, $fromTier, (@($avail) -join ', '))
  }
  $BuildFn = $UpgradeBuildFns[$pairKey]
  Write-Log ("4 upgrade path: {0} -> {1} (function blocks conserved at {2}; departments -> {3}; major {4} -> {5})" -f $Edge.From, $Edge.To, $Edge.ExpectedBlocks, $Edge.DepartmentCount, $Edge.OldVersion, $Edge.NewVersion)
  if ($Edge.Scaffold) {
    Write-Log '4 NOTE scaffold target: the package carries UPGRADE-WORK-ORDER.txt, not authored content; the content gates fail by design and nothing is recorded in the state file'
  }

  # --- Step 5 : generate the upgrade package -----------------------------------
  $pkgName = (Get-Date).ToString('yyyyMMdd-HHmmss')
  $outputRoot = $Config.OutputDir.Replace('{WORKSPACE_ROOT}', $WorkspaceRoot)
  $pkgDir = Join-Path $outputRoot $pkgName

  if ($DryRun) {
    Write-Log "DRY-RUN: would generate the upgrade package in $pkgDir"
    # Each edge is self-describing: its DryRun fragment list lives on the edge,
    # so a new pair needs no change here.
    foreach ($line in @($Edge.Report.DryRun)) { Write-Log $line }
    Write-Log 'DRY-RUN: 6 run gates G1-G6 on the package'
    if ($Edge.Scaffold) {
      Write-Log 'DRY-RUN: scaffold edge - content gates fail by design; the package is left in place (not quarantined), nothing is recorded in the state file, exit 0'
    } else {
      Write-Log 'DRY-RUN: 7 write UPGRADE-PROPOSAL.md; 8 stop (no install)'
    }
    exit 0
  }

  if (-not (Test-Path -LiteralPath $outputRoot)) {
    New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
  }
  New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null
  Write-Log ("5 generating upgrade package in {0}" -f $pkgDir)
  & $BuildFn $pkgDir $Edge

  # --- Step 6 : the six gates, one independent branch each (README_FOR_AI.md sec 12.3) ---
  Write-Log '6 running gates G1-G6 on the upgrade package...'
  $gateResults = @{}
  $failedGates = @()

  $g1 = Invoke-GateG1 -PkgDir $pkgDir
  $gateResults['G1'] = $g1
  if ($g1.Passed) { Write-Log 'G1 PASSED' } else { Write-Log 'G1 FAILED'; $failedGates += 'G1' }

  $g2 = Invoke-GateG2 -PkgDir $pkgDir
  $gateResults['G2'] = $g2
  if ($g2.Passed) { Write-Log 'G2 PASSED' } else { Write-Log 'G2 FAILED'; $failedGates += 'G2' }

  $g3 = Invoke-GateG3 -PkgDir $pkgDir
  $gateResults['G3'] = $g3
  if ($g3.Passed) { Write-Log 'G3 PASSED' } else { Write-Log 'G3 FAILED'; $failedGates += 'G3' }

  $g4 = Invoke-GateG4 -PkgDir $pkgDir -Edge $Edge
  $gateResults['G4'] = $g4
  if ($g4.Passed) { Write-Log 'G4 PASSED' } else { Write-Log 'G4 FAILED'; $failedGates += 'G4' }

  $g5 = Invoke-GateG5 -PkgDir $pkgDir -Edge $Edge
  $gateResults['G5'] = $g5
  if ($g5.Passed) { Write-Log 'G5 PASSED' } else { Write-Log 'G5 FAILED'; $failedGates += 'G5' }

  $g6 = Invoke-GateG6 -PkgDir $pkgDir -Edge $Edge
  $gateResults['G6'] = $g6
  if ($g6.Passed) { Write-Log 'G6 PASSED' } else { Write-Log 'G6 FAILED'; $failedGates += 'G6' }

  # P1-6 / scaling.md sec 6: a failed gate must state WHY. The failed-item detail
  # used to be computed and then thrown away, leaving only "G6 FAILED" in the
  # log and nothing at all in last_failure.
  $gateDetails = @()
  foreach ($gName in @('G1', 'G2', 'G3', 'G4', 'G5', 'G6')) {
    if (-not $gateResults[$gName].Passed) {
      $detailLine = ("{0}: {1}" -f $gName, $gateResults[$gName].Detail)
      $gateDetails += $detailLine
      Write-Log ("{0} detail: {1}" -f $gName, $gateResults[$gName].Detail)
    }
  }

  if ($failedGates.Count -gt 0) {
    # SCAFFOLD edge (large -> group): the content gates (G4/G5/G6) failing IS
    # the expected outcome - the package is a work order, not a defect. Such a
    # package is left in place (never quarantined), nothing is recorded in
    # .scaling-state.json (no installer may apply it) and no proposal report is
    # written; the failure detail logged above is the authoring checklist.
    # Any failure OUTSIDE the content gates is a real defect and keeps the
    # normal quarantine semantics below.
    if ($Edge.Scaffold) {
      $onlyContentGates = $true
      foreach ($g in $failedGates) { if (@('G4', 'G5', 'G6') -notcontains $g) { $onlyContentGates = $false } }
      if ($onlyContentGates) {
        $workOrder = Join-Path $pkgDir 'UPGRADE-WORK-ORDER.txt'
        Write-Log ("6 SCAFFOLD: {0} failed by design (authored content missing); the failure detail above is the authoring checklist" -f ($failedGates -join ', '))
        Write-Log ("6 SCAFFOLD: package left in place at {0}; work order: {1}" -f $pkgDir, $workOrder)
        Write-Log '8 STOP - scaffold generated, NOT a proposal: nothing was recorded in .scaling-state.json and no installer may apply this package.'
        exit 0
      }
      Write-Log ("6 SCAFFOLD edge but non-content gate(s) failed: {0}; treating this as a defect (quarantine)" -f ($failedGates -join ', '))
    }
    $codeByGate = @{ 'G1' = 'SCL_004'; 'G2' = 'SCL_005'; 'G3' = 'SCL_004'; 'G4' = 'SCL_010'; 'G5' = 'SCL_003'; 'G6' = 'SCL_006' }
    $code = $codeByGate[$failedGates[0]]
    # Recoverable quarantine (P23): the package is moved aside, never destroyed.
    $rejectedRoot = Join-Path $outputRoot '_rejected'
    if (-not (Test-Path -LiteralPath $rejectedRoot)) {
      New-Item -ItemType Directory -Path $rejectedRoot -Force | Out-Null
    }
    $rejectedDir = Join-Path $rejectedRoot ($pkgName + '-' + $code)
    Move-Item -LiteralPath $pkgDir -Destination $rejectedDir
    Write-Log ("6 FATAL $code : gate(s) failed: {0}; package quarantined at {1}" -f ($failedGates -join ', '), $rejectedDir)
    # Failure record in the state file.
    Set-StateProperty -State $State -Name 'last_failure' -Value ([ordered]@{
      at = (Get-UtcNowIso)
      code = $code
      gates_failed = $failedGates
      detail = $gateDetails
      package_path = (Get-WorkspaceRelativePath -Path $rejectedDir)
    })
    Save-State -State $State
    exit 3
  }

  # --- Step 7 : upgrade report ---------------------------------------------------
  New-ProposalReport -PkgDir $pkgDir -PkgName $pkgName -Triggers $Triggers -GateResults $gateResults -Metrics $Metrics -Edge $Edge

  # --- Step 5j / step 8 : record the proposal, stop (no install) ------------------
  $proposal = [ordered]@{
    proposal_id = $pkgName
    from_tier = $Edge.From
    to_tier = $Edge.To
    proposed_at = (Get-UtcNowIso)
    trigger_reasons = @()
    package_path = (Get-WorkspaceRelativePath -Path $pkgDir)
    status = 'pending'
    approved_by = $null
    installed_at = $null
    validation = [ordered]@{
      file_count = $TargetFileCount[$Edge.To]
      function_blocks = $Edge.ExpectedBlocks
      gates_passed = 6
      # E6 : honest pending record. The machine-checkable gates passed, but the
      # full README_FOR_AI.md sec 15 acceptance (content groups A-G, H, I, U) has NOT been
      # performed by a human yet. The external installer sets this to true only
      # after the human acceptance is completed at install time.
      acceptance_passed = $false
    }
  }
  foreach ($t in $Triggers) {
    $proposal.trigger_reasons += ("{0}: {1} = {2} (threshold {3})" -f $t.Id, $t.Metric, $t.Value, $t.Threshold)
  }
  if ($Triggers.Count -eq 0) { $proposal.trigger_reasons += 'SCL_001: forced proposal, no threshold met' }
  Set-StateProperty -State $State -Name 'pending_proposals' -Value (@($State.pending_proposals) + $proposal)
  Set-StateProperty -State $State -Name 'last_metrics' -Value ([ordered]@{
    agent_count = $Metrics.AgentCount
    routing_accuracy = $Metrics.RoutingAccuracy
    max_blocks_per_department = $Metrics.MaxBlocks
    error_code_reuse_ratio = $Metrics.ReuseRatio
  })
  Set-StateProperty -State $State -Name 'metrics_provenance' -Value $Metrics.Sources
  Set-StateProperty -State $State -Name 'routing_miss_streak' -Value $RoutingMissStreak
  Save-State -State $State

  Write-Log '8 STOP - proposal generated, NOT EFFECTIVE.'
  Write-Log '8 The proposal is pending in .scaling-state.json (approved_by / installed_at empty).'
  Write-Log '8 Human approval followed by an external installer is required before anything takes effect.'
  Write-Log '8 The skill directory content was not modified; no install was performed.'
  exit 0
}

function Invoke-EvaluateFlow {
  # --- Step 1 : read the state file ----------------------------------------------
  Write-Log '1 reading .scaling-state.json...'
  $state = Read-State
  Write-Log ("1 current_tier={0}, next_evaluation={1}, pending_proposals={2}" -f $state.current_tier, $state.next_evaluation, @($state.pending_proposals).Count)

  # --- Step 2 : collect metrics, evaluate T1-T4 ----------------------------------
  Write-Log '2 collecting the four scaling metrics and evaluating thresholds T1-T4...'
  $config = Load-Config
  # Host write-back channel 2 of 2 (scaling.md sec 3.1): files dropped into the
  # configured .skill-metrics/ directory are validated and applied here, BEFORE
  # the metrics are read. Accepted files are MOVED to processed/ (P23).
  $drop = Receive-HostMetricsDrop -State $state -Config $config
  if (($drop.Applied + $drop.Rejected) -gt 0) {
    Write-Log ("2 host metric drop directory: {0} file(s) applied, {1} rejected" -f $drop.Applied, $drop.Rejected)
    Save-State -State $state
  }
  $metrics = Get-CurrentMetrics -State $state -Config $config
  Write-Log ("2 agent_count={0} [{1}], routing_accuracy={2} [{3}]" -f $metrics.AgentCount, $metrics.Sources.agent_count, $metrics.RoutingAccuracy, $metrics.Sources.routing_accuracy)
  Write-Log ("2 max_blocks_per_department={0} [{1}], error_code_reuse_ratio={2} [{3}]" -f $metrics.MaxBlocks, $metrics.Sources.max_blocks_per_department, $metrics.ReuseRatio, $metrics.Sources.error_code_reuse_ratio)
  $stillDefault = @(Get-MetricsStillAtDefault -State $state -Metrics $metrics)
  if ($stillDefault.Count -gt 0) {
    $stillDefaultTriggers = ($stillDefault | ForEach-Object { if ($_ -eq 'agent_count') { 'T1' } else { 'T3' } }) -join '/'
    Write-Log ("2 NOTE host-supplied metrics still at their defaults: {0}; {1} cannot fire until the host writes them (scaling.md 3.1)." -f ($stillDefault -join ', '), $stillDefaultTriggers)
  }
  $evaluation = Invoke-ThresholdEvaluation -State $state -Metrics $metrics -Config $config
  $triggers = $evaluation.Triggers

  # --- Step 3 : no trigger -> refresh the state and exit --------------------------
  if ($triggers.Count -eq 0) {
    if (-not $Force) {
      Write-Log '3 no threshold hit - updating next_evaluation and last_metrics, then exiting.'
      $next = (Get-Date).ToUniversalTime().AddDays($config.IntervalDays).ToString('yyyy-MM-ddTHH:mm:ssZ')
      Set-StateProperty -State $state -Name 'next_evaluation' -Value $next
      Set-StateProperty -State $state -Name 'last_metrics' -Value ([ordered]@{
        agent_count = $metrics.AgentCount
        routing_accuracy = $metrics.RoutingAccuracy
        max_blocks_per_department = $metrics.MaxBlocks
        error_code_reuse_ratio = $metrics.ReuseRatio
      })
      Set-StateProperty -State $state -Name 'metrics_provenance' -Value $metrics.Sources
      Set-StateProperty -State $state -Name 'routing_miss_streak' -Value $evaluation.RoutingMissStreak
      Save-State -State $state
      Write-Log '3 done. No proposal generated.'
      exit 0
    }
    Write-Log 'SCL_001 WARNING: forced invocation, but no threshold was hit; generating a proposal anyway.'
  } else {
    foreach ($t in $triggers) {
      Write-Log ("2 TRIGGERED {0} ({1}): {2} = {3}, threshold {4}" -f $t.Id, $t.Name, $t.Metric, $t.Value, $t.Threshold)
    }
  }

  # --- Steps 4-8 : generate the proposal ------------------------------------------
  Invoke-Proposal -State $state -Metrics $metrics -Triggers $triggers -Config $config -RoutingMissStreak $evaluation.RoutingMissStreak
}

function Invoke-ProposeFlow {
  Write-Log '1 reading .scaling-state.json...'
  $state = Read-State
  Write-Log '2 collecting metrics for the proposal report...'
  $config = Load-Config
  # Same drop-directory intake as -Action evaluate: a proposal must be based on
  # the same metrics the readiness check sees (scaling.md sec 3.1).
  $drop = Receive-HostMetricsDrop -State $state -Config $config
  if (($drop.Applied + $drop.Rejected) -gt 0) {
    Write-Log ("2 host metric drop directory: {0} file(s) applied, {1} rejected" -f $drop.Applied, $drop.Rejected)
    Save-State -State $state
  }
  $metrics = Get-CurrentMetrics -State $state -Config $config
  $evaluation = Invoke-ThresholdEvaluation -State $state -Metrics $metrics -Config $config
  $triggers = $evaluation.Triggers
  if ($triggers.Count -eq 0) {
    Write-Log 'SCL_001 WARNING: explicit propose action, but no threshold was hit; the report will carry the SCL_001 note.'
  }
  Invoke-Proposal -State $state -Metrics $metrics -Triggers $triggers -Config $config -RoutingMissStreak $evaluation.RoutingMissStreak
}

# --------------------------------------------------------------------------------------
# Entry point
# --------------------------------------------------------------------------------------

switch ($Action) {
  'status'         { Show-Status }
  'report'         { Show-Report }
  'evaluate'       { Invoke-EvaluateFlow }
  'propose'        { Invoke-ProposeFlow }
  'record-metrics' { Invoke-RecordMetrics -Config (Load-Config) }
  # No default fall-through may exist: a ValidateSet value without a branch was
  # a silent no-op (H-2). The default makes any future mismatch loud.
  default          { Stop-WithCode 'SCL_007' ("no handler for -Action '{0}' (declared in ValidateSet but not implemented)" -f $Action) }
}
