.pragma library

// Mapping to infer actual application names from generic StatusNotifierItem tooltips.
// Add or modify keywords here to support more applications.
// `keywords` should be lowercase strings that might appear in the application's tooltip.

const TooltipMappings = [
    { keywords: ["discord", "unread message"], name: "Discord" },
    { keywords: ["element"], name: "Element" },
    { keywords: ["teams"], name: "Teams" },
    { keywords: ["1password"], name: "1Password" },
    { keywords: ["slack"], name: "Slack" },
    { keywords: ["obsidian"], name: "Obsidian" }
];

function getAppNameFromTooltip(tooltipTitle) {
    if (!tooltipTitle) return null;

    var lcTooltip = tooltipTitle.toLowerCase();

    for (var i = 0; i < TooltipMappings.length; i++) {
        var mapping = TooltipMappings[i];
        for (var j = 0; j < mapping.keywords.length; j++) {
            // Note: includes keyword match might be broad, but works well for these generic Electron wrappers
            if (lcTooltip.includes(mapping.keywords[j])) {
                return mapping.name;
            }
        }
    }

    return null;
}
