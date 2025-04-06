# cFish.io Organizational Structure

## Overview

This document outlines the organizational structure of the cFish.io project, aligned with tY FischEYe's goals and UcF best practices. The reorganization focuses on creating a clear separation between the MD-JSON synchronization system and the WordPress website while maintaining UcF's departmental structure principles.

## Directory Structure

```
cFish.io/
├── sync-system/           # MD-JSON Synchronization System
│   ├── core/              # Core implementation files
│   ├── agents/            # Agent-based architecture components
│   ├── utils/             # Utility functions and helpers
│   └── tests/             # Test files and test data
│
├── web/                   # WordPress Website
│   ├── wp-content/        # WordPress content files
│   └── shortlinks/        # Shortlink system for u.cfish.io
│
├── docs/                  # Documentation organized by UcF structure
│   ├── u1-overheads/      # Business administration, front office
│   ├── u4-production/     # Production documentation
│   ├── u5-data-management/# Data management and system documentation
│   ├── u6-social/         # Social media and communications
│   └── u7-specialized/    # Specialized operations documentation
│
├── tools/                 # Development and operational tools
│
└── scripts/               # Batch files, PowerShell scripts for automation
```

## UcF Hierarchies ~ Organization Structure

### UcF Spaces for Each Department/Subsidiary/Business Unit

- **U- Universal**: Universally relevant to all of UcF
- **U1- UcFish trust? + holdingz companY**: Overhead trust & holding company _(Uc)_
- **U2- tYFeAiz**: R&D~AI Integration _(z)_ {?incoorp?}
- **U3- FiscHouse**: Brick n mortar, private, Operations home of all UcF _(FH)_ {eventual Llc}
- **U4- UcWebZ**: UcF Web 1-3.0+, presence, Ops, + production _(W)_ {?incoorp?} [internal + external web work] ~ slogan "Uc, our WebZ P.O.P"
- **U5- the UZ**: UcF "DSS" (cooperate DispatcheZ, customer ServiceZ, teamZ Success) _(U)_ {?int. incoorp?} [internal + external communications] ~ Slogan "We Uz DSS! [we use dis]"
- **U6- FischEYe**: Production Design Company {Llc} _(Fe)_
- **U7- tYberius Designz | tYDi | tY**: Designer + Director {Llc} _(Y)_

### Universal UcF Departments + Subsidiary Structures

- **Dept 1.10**: OVR (Overheads) ~ "Soul" - front office, sales, client work
- **Dept 2.7**: R+D (Research and Development) ~ "Mind" - innovations, markets, prototyping
- **Dept 3.3**: OPz (Physical Operations) ~ "Body" - facilities, logistics; resource allocation
- **Dept 4.4**: PRO (Production) ~ "Produce"
- **Dept 5.5**: SMC (Societal/Multi-Media/Communications) ~ "Communicate"
- **Dept 6.9**: DMT (Data Management/Connecting) ~ "Connect"
- **Dept 7.7**: SPEC (Spec Ops - Specific functions unique to each subsidiary, e.g., Design, Client Relations, Technical Support) ~ "Serve"

### Universal UcF Lists for Departmental Workflows and Jobs

Within each department folder, distinct lists for workflows are established:

#### Standard Workflow Organization (A)

- **OVR**: Admin/Office(1.01), Financials/Business(1.8), HR/Sales-Project mgmt/Client mgmt(1.10)
- **R+D**: Innovation Projects, Market Research, Prototyping(2.0-7 [one for each dept])
- **OPz**: Daily Operations(3.0), Logistics(3.1), Resource Allocation(3.2), Facilities(3.3)
- **PRO**: Manufacturing(4.1), Quality Control(4.2), Delivery Systems(4.3), Maintenance(4.4)
- **DMT**: Database Management(5.1), Network Security (5.2), IT Support (5.3), Customer Support (5.4), Team success (5.5)
- **SMC**: Campaign Management-Pre pro (6.3), Public Relations-Audio pro (6.6), Content Creation-Video pro/SPFX post (6.9)
- **SPEC**: Tailor to specific needs of each subsidiary (7.0-7[one for each dept]) (e.g., Technical Integrations for Fe, Branding for tY.Di)

#### Emergency Environments UcF SOP - Hierarchal Structures (B) {P.O.R.~O.D.S.S.}

- **PRO**: Manufacturing(4.1), Quality Control(4.2), Delivery Systems(4.3), Maintenance(4.4)
- **OVR**: Admin/Office(1.01), Financials/Business(1.8), HR/Sales/Clients Management(1.10)
- **R+D**: Innovation Projects, Market Research, Prototyping(2.0-7[one for each dept])
- **OPz**: Daily Operations(3.1), Logistics(3.2), Resource Allocation(3.3), Future Scape(3.4)
- **DMT**: Database Management(5.1), Network Security (5.2), IT Support (5.3), Customer Support (5.4), Team success (5.5)
- **SMC**: Campaign Management(6.3), Public Relations(6.6), Content Creation(6.9)
- **SPEC**: Tailor to specific needs of each subsidiary(7.0-7[one for each dept]) (e.g., Technical Integrations + Engineering for Fe, Branding + Directing for tY.Di)

## Naming Conventions and Organization

### Universal UcF Naming Conventions

- Hierarchical naming convention format: `[CompanyPrefix] [Dept#].[Function#] [Project or Task Identifier + optional date]`
- Example: `Uc 1.8 meet 03-15` (instead of UcF-OVR-Finance Meeting 03-15)
- Status, assignments, and tags should be included in all items and containers universally in UcF
- Ensure consistent use of these identifiers across ClickUp/Notion/Vendasta for easy access and searchability

### Implementation Considerations

- Maintain consistent numbering system across all entities
- Use standardized templates for documentation
- Ensure cross-referencing between related departments
- Keep naming conventions uniform across all levels

This organizational structure enables seamless integration between the holding company and subsidiaries while maintaining individual operational autonomy. Each department's numbering system (1.0-7.0) provides clear lineage and helps in tracking, reporting, and resource allocation across the entire organization.

_Updated 03-13-2025 | AI: Cursor (Claude 3.7 Sonnet)_ 