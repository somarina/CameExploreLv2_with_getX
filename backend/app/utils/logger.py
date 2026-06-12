from rich.console import Console
from rich.panel import Panel
from rich import print

console = Console()


def log_success(message):
    console.print(
        f"[bold green]✓ SUCCESS[/bold green] {message}"
    )


def log_error(message):
    console.print(
        f"[bold red]✗ ERROR[/bold red] {message}"
    )


def log_info(message):
    console.print(
        f"[bold cyan]ℹ INFO[/bold cyan] {message}"
    )


def log_upload(filename):
    console.print(
        Panel.fit(
            f"[green]{filename}[/green]",
            title="📸 Uploaded File",
            border_style="green",
        )
    )