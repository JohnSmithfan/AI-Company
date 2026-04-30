## 3. Mermaid Diagrams

Mermaid provides a text-based approach to creating diagrams that integrates seamlessly with Markdown documentation. The following templates cover the most common enterprise use cases.

### 3.1 Flowchart Templates

#### Basic Flowchart

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#1e40af', 'primaryTextColor': '#fff', 'primaryBorderColor': '#1e40af', 'lineColor': '#64748b', 'secondaryColor': '#f1f5f9'}}}%%
flowchart TD
    A[Start: Receive User Request] --> B{Validate Request Type}
    B -->|Data Query| C[Route to Data Agent]
    B -->|Analysis| D[Route to Analysis Agent]
    B -->|Report| E[Route to Report Agent]
    B -->|Unknown| F[Route to General Agent]
    C --> G[Execute Data Retrieval]
    D --> H[Perform Analysis]
    E --> I[Generate Report]
    F --> J[General Processing]
    G --> K{Data Available?}
    H --> L{Analysis Complete?}
    I --> M{Report Valid?}
    J --> N{Processing Success?}
    K -->|Yes| O[Return Data]
    K -->|No| P[Log Error - Return Empty]
    L -->|Yes| Q[Return Insights]
    L -->|No| R[Log Warning - Return Partial]
    M -->|Yes| S[Deliver Report]
    M -->|No| T[Regenerate Report]
    N -->|Yes| U[Return Result]
    N -->|No| V[Escalate to Human]
    O --> Z[End: Response Delivered]
    Q --> Z
    S --> Z
    U --> Z
    P --> Z
    R --> Z
    T --> I
    V --> Z
```

#### Decision Tree Flowchart

```mermaid
%%{init: {'theme': 'base'}}%%
flowchart TD
    START([User Query Received]) --> TYPE{Query Type?}
    TYPE -->|Financial| FIN[Financial Data Module]
    TYPE -->|Operational| OPS[Operations Module]
    TYPE -->|Strategic| STR[Strategic Module]
    TYPE -->|Technical| TECH[Technical Module]
    
    FIN --> FIN_TYPE{Data Category?}
    FIN_TYPE -->|Stock/Price| STOCK[Stock Data API]
    FIN_TYPE -->|Fund/NAV| FUND[Fund Data API]
    FIN_TYPE -->|Macro| MACRO[Macro Economic API]
    FIN_TYPE -->|Forex| FOREX[Forex API]
    
    OPS --> OPS_TYPE{Operation Type?}
    OPS_TYPE -->|Inventory| INV[Inventory Check]
    OPS_TYPE -->|Supply Chain| SC[Supply Chain Analysis]
    OPS_TYPE -->|Quality| QA[Quality Metrics]
    
    STR --> STR_TYPE{Analysis Type?}
    STR_TYPE -->|Market| MARKET[Market Analysis]
    STR_TYPE -->|Competitor| COMP[Competitor Intel]
    STR_TYPE -->|Trend| TREND[Trend Analysis]
    
    TECH --> TECH_TYPE{Tech Domain?}
    TECH_TYPE -->|Infrastructure| INFRA[Infra Monitoring]
    TECH_TYPE -->|Application| APP[App Performance]
    TECH_TYPE -->|Security| SEC[Security Alert]
    
    STOCK --> RESP[Format Response]
    FUND --> RESP
    MACRO --> RESP
    FOREX --> RESP
    INV --> RESP
    SC --> RESP
    QA --> RESP
    MARKET --> RESP
    COMP --> RESP
    TREND --> RESP
    INFRA --> RESP
    APP --> RESP
    SEC --> RESP
    
    RESP --> END([Response Delivered])
```

### 3.2 Sequence Diagram Templates

#### Multi-Agent Communication Sequence

```mermaid
%%{init: {'theme': 'base'}}%%
sequenceDiagram
    autonumber
    participant CEO as CEO Agent
    participant CTO as CTO Agent
    participant CFO as CFO Agent
    participant CMO as CMO Agent
    participant COO as COO Agent
    
    CEO->>CTO: Request technical assessment
    Note over CTO: Evaluating infrastructure needs
    
    CTO->>CFO: Query budget implications
    CFO-->>CTO: Budget analysis returned
    CTO->>COO: Coordinate deployment timeline
    COO-->>CTO: Timeline confirmed
    
    CTO-->>CEO: Technical roadmap proposal
    
    CEO->>CMO: Request market positioning
    CMO->>CFO: Query pricing strategy impact
    CFO-->>CMO: Pricing analysis complete
    CMO->>CTO: Technical feasibility check
    CTO-->>CMO: Feasibility confirmed
    
    CMO-->>CEO: Market strategy complete
    
    CEO->>COO: Request operational readiness
    COO->>CTO: Technical requirements
    COO->>CFO: Resource allocation
    COO->>CMO: Marketing timeline
    
    Note over COO: Consolidating operational plan
    
    COO-->>CEO: Operational readiness report
    CEO->>CEO: Compile executive decision
```

#### Request Processing Sequence

```mermaid
%%{init: {'theme': 'base'}}%%
sequenceDiagram
    autonumber
    participant User as External User
    participant Gateway as API Gateway
    participant Auth as Auth Service
    participant Router as Request Router
    participant Executor as Agent Executor
    participant Cache as Cache Layer
    participant DB as Database
    
    User->>Gateway: Submit request
    
    Gateway->>Auth: Validate credentials
    Auth-->>Gateway: Auth token issued
    
    Gateway->>Router: Route request
    Router->>Cache: Check cache
    
    alt Cache Hit
        Cache-->>Router: Return cached response
        Router-->>Gateway: Cached data
        Gateway-->>User: Response delivered
    else Cache Miss
        Cache-->>Router: Cache miss
        Router->>Executor: Submit task
        
        Executor->>DB: Query necessary data
        DB-->>Executor: Data returned
        
        Executor->>Executor: Process request
        Note over Executor: AI Agent processing
        
        Executor->>Cache: Store result
        Cache-->>Executor: Cached successfully
        
        Executor-->>Router: Processed result
        Router-->>Gateway: Final response
        Gateway-->>User: Response delivered
    end
    
    Note over User,DB: All data processed within sandbox environment
```

### 3.3 Gantt Chart Templates

#### Project Timeline Gantt

```mermaid
%%{init: {'theme': 'base', 'gantt': {'titleTopMargin': 25, 'barHeight': 20, 'barGap': 6, 'topPadding': 50, 'leftPadding': 120, 'gridLineStart': 35, 'fontSize': 12, 'sectionFontSize': 14}}}%%
gantt
    title AI-Company v5.0 Deployment Roadmap
    dateFormat YYYY-MM-DD
    
    section Planning
    Requirements Gathering    :done, plan1, 2026-04-01, 7d
    Architecture Design       :done, plan2, 2026-04-08, 10d
    Technical Specification   :done, plan3, 2026-04-18, 5d
    
    section Development
    Core Agent Framework       :active, dev1, 2026-04-23, 14d
    Visualization Module       :crit, dev2, 2026-04-23, 14d
    Report Generation          :dev3, 2026-05-01, 10d
    Integration Testing        :dev4, 2026-05-05, 7d
    
    section Deployment
    Staging Environment        :dep1, 2026-05-12, 5d
    User Acceptance Testing    :dep2, 2026-05-17, 5d
    Production Deployment      :crit, dep3, 2026-05-22, 3d
    Post-Launch Monitoring     :dep4, 2026-05-25, 14d
    
    section Training
    Documentation              :train1, 2026-05-01, 14d
    User Training Sessions     :train2, 2026-05-15, 7d
    Admin Training             :train3, 2026-05-18, 5d
```

#### Quarterly Roadmap Gantt

```mermaid
%%{init: {'theme': 'base', 'gantt': {'titleTopMargin': 25, 'barHeight': 16, 'barGap': 4, 'topPadding': 50, 'leftPadding': 150}}}%%
gantt
    title Q2 2026 Strategic Initiatives
    dateFormat YYYY-MM-DD
    
    section Revenue
    Enterprise Sales Push     :2026-04-01, 2026-06-30
    Pricing Optimization      :2026-04-15, 2026-05-15
    Upsell Campaign            :2026-05-01, 2026-06-15
    
    section Product
    v5.0 Core Release          :milestone, 2026-04-30
    Visualization Suite       :2026-04-15, 2026-05-30
    API v2 Launch              :2026-06-01, 2026-06-30
    
    section Operations
    Process Automation        :2026-04-01, 2026-05-31
    Quality Assurance          :2026-04-15, 2026-06-30
    Vendor Consolidation       :2026-05-15, 2026-06-30
    
    section People
    Engineering Hiring        :2026-04-01, 2026-06-30
    Leadership Training        :2026-04-15, 2026-05-15
    Team Offsite               :2026-06-15, 2026-06-17
```

### 3.4 Entity Relationship Diagram

```mermaid
%%{init: {'theme': 'base'}}%%
erDiagram
    COMPANY ||--o{ AGENT : employs
    COMPANY ||--o{ DEPARTMENT : contains
    DEPARTMENT ||--o{ AGENT : manages
    DEPARTMENT ||--o{ SKILL : requires
    
    AGENT ||--o{ SKILL : has
    AGENT ||--o{ TASK : executes
    AGENT }o--o| TEAM : belongs_to
    
    TASK ||--|| REPORT : generates
    TASK ||--o| METRIC : produces
    
    TEAM ||--o{ REPORT : produces
    TEAM ||--o{ METRIC : tracks
    
    COMPANY {
        string company_id PK
        string name
        string industry
        datetime founded
    }
    
    DEPARTMENT {
        string dept_id PK
        string company_id FK
        string name
        string level
    }
    
    AGENT {
        string agent_id PK
        string dept_id FK
        string name
        string role
        string status
        datetime created
    }
    
    SKILL {
        string skill_id PK
        string name
        string category
        version version
    }
    
    TASK {
        string task_id PK
        string agent_id FK
        string type
        string status
        datetime created
        datetime completed
    }
    
    REPORT {
        string report_id PK
        string task_id FK
        string team_id FK
        string type
        json content
        datetime generated
    }
    
    METRIC {
        string metric_id PK
        string task_id FK
        string team_id FK
        string name
        float value
        datetime timestamp
    }
    
    TEAM {
        string team_id PK
        string name
        string purpose
    }
```

### 3.5 State Diagram

```mermaid
%%{init: {'theme': 'base'}}%%
stateDiagram-v2
    [*] --> Idle
    
    state Idle {
        [*] --> Ready
        Ready --> Processing : Task Received
        Processing --> Complete : Success
        Processing --> Failed : Error
        Complete --> Ready
        Failed --> Ready : Retry
        Failed --> [*] : Abort
    }
    
    Idle --> Processing : Initiate
    Processing --> Analyzing : Data Loaded
    Analyzing --> Synthesizing : Analysis Complete
    Synthesizing --> Formatting : Synthesis Ready
    Formatting --> Delivering : Format Validated
    
    Delivering --> Success : ACK Received
    Delivering --> Retrying : NACK Received
    Retrying --> Delivering : Retry Success
    Retrying --> Failed : Max Retries
    Failed --> [*]
    
    Success --> [*]
    
    note right of Idle
        System returns to Idle
        after successful delivery
        or abort
    end note
```

#### Compliance Notes for Mermaid Diagrams

- All diagrams must include AIGC labeling in the comment block header
- Sequence diagrams should not exceed 15 participants for readability
- Gantt charts are limited to 20 tasks per chart
- ER diagrams must include primary keys (PK) and foreign keys (FK) notation
- State diagrams must have clear terminal states ([*])

---

## 4. Integration with CEO Command Center

This section describes how the visualization module integrates with the CEO command center to provide unified executive intelligence.

### 4.1 Architecture Overview

The visualization module operates as a plug-in component within the AI-Company unified skill architecture. The integration follows a layered approach:

```
┌─────────────────────────────────────────────────────────────┐
│                    CEO Command Center                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │           Visualization Module (This Guide)        │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐ │   │
│  │  │ Charts  │ │Reports  │ │Diagrams │ │Integration│ │   │
│  │  │ (Chart.js│ │ Templates│ │(Mermaid)│ │   APIs    │ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Core AI-Company Framework              │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐ │   │
│  │  │ HQ Core │ │ Audit   │ │Command  │ │ Response│ │   │
│  │  │ Module  │ │ Module  │ │ Parser  │ │  Formatter│ │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └────────┘ │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Data Flow Integration

The visualization module receives structured data from the CEO command center through the following flow:

1. **Request Reception**: The CEO agent receives a natural language query
2. **Intent Classification**: Determines if visualization is needed
3. **Data Aggregation**: HQ core module gathers required data
4. **Template Selection**: Choose appropriate visualization template
5. **Rendering**: Generate HTML with embedded Chart.js or Mermaid
6. **Compliance Check**: Verify AIGC labeling and data safety
7. **Delivery**: Present visualization to user

### 4.3 Command Center API Reference

#### Available Visualization Commands

| Command | Description | Output |
|---------|-------------|--------|
| `show chart [type]` | Generate specific chart type | HTML with Chart.js |
| `generate report [template]` | Create report from template | Formatted HTML report |
| `render diagram [type]` | Create Mermaid diagram | SVG/PNG diagram |
| `export dashboard` | Export current view | Standalone HTML |

#### Integration Code Example

```javascript
// Integration example for CEO Command Center
// AIGC Generated Content - Internal Use Only

const VisualizationModule = {
  // Chart configuration presets
  chartPresets: {
    line: { tension: 0.4, fill: true, borderWidth: 2 },
    bar: { borderRadius: 6, barPercentage: 0.8 },
    pie: { cutout: 0, hoverOffset: 10 },
    doughnut: { cutout: '60%', hoverOffset: 12 }
  },

  // Color palettes for enterprise dashboards
  colorPalettes: {
    primary: ['#1e40af', '#3b82f6', '#60a5fa', '#93c5fd', '#dbeafe'],
    success: ['#059669', '#10b981', '#34d399', '#6ee7b7'],
    warning: ['#d97706', '#f59e0b', '#fbbf24'],
    danger: ['#dc2626', '#ef4444', '#f87171'],
    neutral: ['#64748b', '#94a3b8', '#cbd5e1', '#e2e8f0']
  },

  // Default configuration
  defaults: {
    responsive: true,
    maintainAspectRatio: false,
    animation: { duration: 750, easing: 'easeInOutQuart' },
    plugins: {
      legend: { position: 'bottom', labels: { padding: 16 } },
      tooltip: { enabled: true, callbacks: {} },
      datalabels: { display: false }
    }
  },

  // Create chart with presets
  createChart: function(type, data, options = {}) {
    const config = {
      type: type,
      data: data,
      options: {
        ...this.defaults,
        ...options,
        plugins: {
          ...this.defaults.plugins,
          ...(options.plugins || {})
        }
      }
    };
    
    // Inject AIGC compliance callback
    if (config.options.plugins.tooltip) {
      const originalFooter = config.options.plugins.tooltip.callbacks.footer;
      config.options.plugins.tooltip.callbacks.footer = function() {
        const defaultFooter = '\nAIGC Generated - Verify Data Accuracy';
        return originalFooter ? originalFooter() + defaultFooter : defaultFooter;
      };
    }
    
    return new Chart(config);
  },

  // Generate report from template
  generateReport: function(templateName, data) {
    const templates = this.reportTemplates;
    if (!templates[templateName]) {
      throw new Error(`Template '${templateName}' not found`);
    }
    
    const template = templates[templateName];
    return this.renderTemplate(template, data);
  },

  // Render Mermaid diagram
  renderMermaid: function(definition, container) {
    // Sanitize input to prevent injection
    const sanitized = this.sanitizeMermaid(definition);
    
    mermaid.init({
      theme: 'base',
      securityLevel: 'loose',
      fontFamily: 'system-ui, sans-serif'
    }, sanitized);
  },

  // Security: Prevent injection in Mermaid
  sanitizeMermaid: function(input) {
    // Remove any potentially dangerous patterns
    return input
      .replace(/javascript:/gi, '')
      .replace(/on\w+=/gi, '')
      .replace(/<script/gi, '')
      .replace(/<\/script>/gi, '');
  },

  // Export dashboard as standalone HTML
  exportDashboard: function(chartInstances) {
    const html = this.generateStandaloneHTML(chartInstances);
    return this.createBlob(html, 'text/html');
  }
};
```

### 4.4 Dashboard Configuration

The visualization module supports configurable dashboard layouts:

```javascript
// Dashboard layout configurations
const dashboardLayouts = {
  executive: {
    name: 'Executive Overview',
    widgets: [
      { type: 'stat', position: 'top', metrics: ['revenue', 'users', 'growth'] },
      { type: 'line', position: 'main', chart: 'trend' },
      { type: 'table', position: 'side', data: 'topAccounts' }
    ]
  },
  
  financial: {
    name: 'Financial Dashboard',
    widgets: [
      { type: 'gauge', position: 'top', metrics: ['target', 'achieved', 'forecast'] },
      { type: 'bar', position: 'main', chart: 'revenueByRegion' },
      { type: 'pie', position: 'side', chart: 'expenseBreakdown' }
    ]
  },
  
  operational: {
    name: 'Operations Center',
    widgets: [
      { type: 'heatmap', position: 'main', data: 'activityMap' },
      { type: 'gantt', position: 'below', data: 'projectTimeline' },
      { type: 'table', position: 'side', data: 'incidents' }
    ]
  }
};
```

### 4.5 Performance Optimization

To ensure optimal performance in the CEO command center:

1. **Lazy Loading**: Charts are rendered only when visible in viewport
2. **Debounced Updates**: Data refreshes are debounced to prevent excessive re-renders
3. **Web Workers**: Heavy data processing occurs off the main thread
4. **Canvas Caching**: Rendered charts are cached as images during scroll
5. **Progressive Enhancement**: Basic HTML tables are shown while charts load

---

