# UcF Standard File Naming and Digital Organization

This document outlines the standardized naming conventions and organizational structure for all digital files within the UcF ecosystem, ensuring consistency and efficiency across all projects and departments.

## File Naming Conventions

### General Format
`[Project]-[Type]-[Description]-[Version].[extension]`

### Dreamflo System Files
- **Templates**: `Dreamflo-Template-[Purpose]-[Version].md`
- **Instructions**: `Dreamflo-Instructions-[Topic]-[Version].md`
- **Visuals**: `Dreamflo-Visual-[Type]-[Version].[extension]`

### Business Documents
- **Plans**: `[Business]-Plan-[Department]-[Year].md`
- **Reports**: `[Business]-Report-[Type]-[Date].md`
- **Proposals**: `[Client]-Proposal-[Project]-[Date].md`

### Media Assets
- **Images**: `[Project]-Image-[Description]-[Size].[extension]`
- **Videos**: `[Project]-Video-[Description]-[Resolution].[extension]`
- **Audio**: `[Project]-Audio-[Description]-[Length].[extension]`

## Directory Structure

```
UcF/
├── Dreamflo/
│   ├── Templates/
│   ├── Instructions/
│   ├── Visuals/
│   └── Implementation/
├── Businesses/
│   ├── cFish.io/
│   ├── FischEYe/
│   └── tYberius/
├── Projects/
│   ├── [ProjectName]/
│   │   ├── Planning/
│   │   ├── Execution/
│   │   └── Delivery/
└── Resources/
    ├── Training/
    ├── Marketing/
    └── Documentation/
```

## Version Control Guidelines

- **Major Updates**: Increment the first number (1.0 → 2.0)
- **Minor Updates**: Increment the second number (1.0 → 1.1)
- **Revisions**: Add revision indicator (1.0-R1, 1.0-R2)

## Implementation Requirements

- All team members must adhere to these naming conventions
- File migrations should be completed by [target date]
- Regular audits will ensure compliance with these standards
- Integration with automated tools will help maintain consistency 