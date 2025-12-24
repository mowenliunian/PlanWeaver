"""
Proposal Helper Functions
Utility functions for proposal generation and formatting.
"""

from typing import Dict, List, Optional
from datetime import datetime, timedelta


def format_proposal_section(title: str, content: str, icon: str = "") -> str:
    """
    Format a proposal section with consistent styling.

    Args:
        title: Section title
        content: Section content
        icon: Optional emoji icon

    Returns:
        Formatted markdown section
    """
    icon_prefix = f"{icon} " if icon else ""
    return f"\n## {icon_prefix}{title}\n\n{content}\n"


def validate_section_completeness(section: str, required_elements: List[str]) -> Dict[str, bool]:
    """
    Validate that a section contains all required elements.

    Args:
        section: Section content to validate
        required_elements: List of required element keywords

    Returns:
        Dictionary mapping each element to presence status
    """
    section_lower = section.lower()
    return {element: element.lower() in section_lower for element in required_elements}


def generate_timeline_phases(total_weeks: int) -> List[Dict[str, any]]:
    """
    Generate standard project timeline phases.

    Args:
        total_weeks: Total project duration in weeks

    Returns:
        List of phase dictionaries with duration and activities
    """
    if total_weeks < 4:
        phases = [
            {"name": "Planning", "weeks": max(1, total_weeks // 4)},
            {"name": "Execution", "weeks": max(1, total_weeks // 2)},
            {"name": "Review & Launch", "weeks": max(1, total_weeks // 4)},
        ]
    else:
        phases = [
            {"name": "Planning & Design", "weeks": max(1, total_weeks // 5)},
            {"name": "Development", "weeks": max(2, total_weeks // 2)},
            {"name": "Testing & Refinement", "weeks": max(1, total_weeks // 5)},
            {"name": "Deployment", "weeks": max(1, total_weeks // 10)},
        ]

    # Adjust to match total weeks
    current_total = sum(p["weeks"] for p in phases)
    if current_total < total_weeks:
        phases[-1]["weeks"] += total_weeks - current_total

    return phases


def calculate_budget_with_contingency(base_costs: Dict[str, float], contingency_percent: float = 15.0) -> Dict[str, any]:
    """
    Calculate budget with contingency buffer.

    Args:
        base_costs: Dictionary of cost categories to base amounts
        contingency_percent: Contingency percentage (default 15%)

    Returns:
        Dictionary with breakdown and total
    """
    subtotal = sum(base_costs.values())
    contingency = subtotal * (contingency_percent / 100)
    total = subtotal + contingency

    return {
        "breakdown": {**base_costs, "Contingency": contingency},
        "subtotal": subtotal,
        "contingency": contingency,
        "total": total,
        "contingency_percent": contingency_percent
    }


def format_risk_table(risks: List[Dict[str, str]]) -> str:
    """
    Format risks into a markdown table.

    Args:
        risks: List of risk dictionaries with 'name', 'impact', 'probability', 'mitigation'

    Returns:
        Formatted markdown table
    """
    table = "| Risk | Impact | Probability | Mitigation |\n"
    table += "|------|--------|-------------|------------|\n"
    for risk in risks:
        table += f"| {risk.get('name', '')} | {risk.get('impact', '')} | {risk.get('probability', '')} | {risk.get('mitigation', '')} |\n"
    return table


def estimate_project_complexity(brief: str) -> str:
    """
    Estimate project complexity based on brief content.

    Args:
        brief: Project brief text

    Returns:
        Complexity level: 'Low', 'Medium', or 'High'
    """
    complexity_keywords = {
        'high': ['enterprise', 'scalable', 'integration', 'multi-team', 'complex', 'architecture'],
        'medium': ['application', 'database', 'api', 'frontend', 'backend'],
        'low': ['simple', 'basic', 'prototype', 'mvp', 'single-page']
    }

    brief_lower = brief.lower()

    high_count = sum(1 for kw in complexity_keywords['high'] if kw in brief_lower)
    medium_count = sum(1 for kw in complexity_keywords['medium'] if kw in brief_lower)

    if high_count >= 2 or brief_lower.count('and') > 5:
        return 'High'
    elif medium_count >= 2 or brief_lower.count('and') > 2:
        return 'Medium'
    else:
        return 'Low'


def generate_success_metrics(project_type: str) -> List[str]:
    """
    Generate relevant success metrics based on project type.

    Args:
        project_type: Type of project (proposal, event, initiative, etc.)

    Returns:
        List of success metric descriptions
    """
    common_metrics = [
        "On-time delivery (all milestones met by target dates)",
        "Budget adherence (final cost within 10% of estimate)"
    ]

    type_specific = {
        'proposal': [
            "Stakeholder approval rating",
            "Implementation readiness score",
            "Risk mitigation coverage"
        ],
        'event': [
            "Attendee satisfaction rate (target: 4.5/5)",
            "Attendance rate vs. registration",
            "Budget execution efficiency"
        ],
        'initiative': [
            "Adoption rate among target users",
            "Impact measurement achievement",
            "Sustainability beyond launch"
        ]
    }

    return common_metrics + type_specific.get(project_type.lower(), common_metrics)


def current_date_plus_weeks(weeks: int) -> str:
    """
    Get a date string weeks from now.

    Args:
        weeks: Number of weeks to add

    Returns:
        Formatted date string
    """
    future_date = datetime.now() + timedelta(weeks=weeks)
    return future_date.strftime("%B %d, %Y")
