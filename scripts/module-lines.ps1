<#
The optional-module contract, defined once and dot-sourced by both build
scripts.

The governance package installs in modules: core-rules.md and client-profiles.md
are always present, while the five files listed in $OptionalModules are chosen
per repository at install time. Three things reproduce that choice - govern-init
(when it scaffolds), govern-update (when it refreshes the mandatory-rules block),
and build-empty.ps1 (when it assembles the core-only oracle). If they disagree by
so much as a blank line, every update lands as a spurious whole-block diff, which
is exactly what ai-docs/procedures/govern-update.md spends a paragraph
preventing. So the transformation lives here, in one place, and the procedures
are told to read it from here rather than restating it.

Note on encoding: every literal string in this file is deliberately ASCII-only,
for the same reason as build.ps1 - the .md files it slices contain typographic
punctuation, and this script must never retype that text.
#>

# The modules an install may decline. core-rules.md and client-profiles.md are
# deliberately absent from this list: they are always installed.
$OptionalModules = @(
    'coding-rules.md',
    'coding-patterns.md',
    'writing-rules.md',
    'writing-patterns.md',
    'agent-workflow.md'
)

# Nesting: a craft companion cannot be installed without its rules module.
# govern-init's step 2a prompts in this order and enforces the same rule.
$ModuleParents = @{
    'coding-patterns.md'  = 'coding-rules.md'
    'writing-patterns.md' = 'writing-rules.md'
}

# The bounds of the optional-module unit inside an assembled entry file. Both
# AGENTS.md ("Then read the module your task calls for") and
# .github/copilot-instructions.md ("Then open the module ...") match the lead-in
# on the substring below, so one anchor pair serves both.
$ModuleUnitLeadIn = 'the module your task calls for'
$ModuleUnitTail   = 'Where craft meets safety, safety and correctness win.'

# A module's bullet is a top-level or nested list item, identified by the module
# its link POINTS AT.
$ModuleBulletPattern = '^\s*- \*\*\['

# Deliberately matched on the link target, not on the filename appearing anywhere
# in the line. A bullet that mentions a sibling in passing - "the craft companion
# to `coding-rules.md`" - is a completely natural edit, and a substring test would
# then delete the wrong bullet. Nothing downstream would catch it: a full build
# drops nothing, a core-only build drops everything, and only a mid-case selection
# shows the difference (which is why the harness asserts one).
function Get-ModuleLinkPattern([string]$module) {
    '\]\((\.{1,2}/)*ai-governance/' + [regex]::Escape($module) + '\)'
}

# Expand a requested module selection to the set actually installed: 'all' means
# every optional module, 'core' means none of them. Any other value is treated as
# an explicit list, and a craft companion named without its parent is an error
# rather than a silent promotion.
function Resolve-Modules([string[]]$requested) {
    if ($null -eq $requested -or $requested.Count -eq 0) { return @() }
    if ($requested.Count -eq 1 -and $requested[0] -eq 'all')  { return @($OptionalModules) }
    if ($requested.Count -eq 1 -and $requested[0] -eq 'core') { return @() }

    $selected = @()
    foreach ($m in $requested) {
        $name = if ($m.EndsWith('.md')) { $m } else { "$m.md" }
        if ($OptionalModules -notcontains $name) {
            throw "Unknown module '$m'. Valid: $($OptionalModules -join ', '), or 'all' / 'core'."
        }
        $selected += $name
    }
    foreach ($child in $ModuleParents.Keys) {
        if ($selected -contains $child -and $selected -notcontains $ModuleParents[$child]) {
            throw "Module '$child' requires '$($ModuleParents[$child])' - a craft companion cannot be installed without its rules module."
        }
    }
    return @($selected)
}

# Remove the bullet line for every optional module not in $keep.
#
# When $keep leaves no optional module at all, remove the whole unit - the
# lead-in paragraph, the list, and the tail line - rather than leaving a lead-in
# sentence dangling above an empty list. That degenerate case is the core-only
# install, which is a supported shape, not an edge case.
function Remove-ModuleLines([string]$content, [string[]]$keep, [string]$label) {
    $leadInIdx = $content.IndexOf($ModuleUnitLeadIn)
    if ($leadInIdx -lt 0) {
        throw "Source shape changed - module-list lead-in not found for $label : '$ModuleUnitLeadIn'"
    }
    $tailIdx = $content.IndexOf($ModuleUnitTail)
    if ($tailIdx -lt 0) {
        throw "Source shape changed - module-list tail not found for $label : '$ModuleUnitTail'"
    }
    if ($tailIdx -lt $leadInIdx) {
        throw "Source shape changed - module-list tail precedes its lead-in for $label"
    }

    $kept = @($OptionalModules | Where-Object { $keep -contains $_ })
    $drop = @($OptionalModules | Where-Object { $keep -notcontains $_ })

    if ($drop.Count -eq 0) { return $content }

    if ($kept.Count -eq 0) {
        # Cut from the start of the lead-in paragraph through the blank line
        # after the tail, leaving the paragraphs on either side intact.
        $start = $content.LastIndexOf("`n`n", $leadInIdx)
        if ($start -lt 0) {
            throw "Source shape changed - no paragraph break before the module list for $label"
        }
        $start = $start + 2
        $end = $tailIdx + $ModuleUnitTail.Length
        if ($content.Substring($end).StartsWith("`n`n")) { $end = $end + 2 }
        return $content.Substring(0, $start) + $content.Substring($end)
    }

    $out = foreach ($line in ($content -split "`n")) {
        $dropThis = $false
        if ($line -match $ModuleBulletPattern) {
            foreach ($m in $drop) {
                if ($line -match (Get-ModuleLinkPattern $m)) { $dropThis = $true; break }
            }
        }
        if (-not $dropThis) { $line }
    }
    return ($out -join "`n")
}
