#!/usr/bin/env python3
"""
Fetch Advent of Code puzzle brief and input for a given year and day.

Usage: python grab-aoc.py <year> <day>
Example: python grab-aoc.py 2025 2

Session cookie is grabbed automatically from your browser (Zen/Firefox).
Falls back to .aoc-session file or AOC_SESSION env var.
"""

import argparse
import os
import sys
from pathlib import Path

try:
    import requests
    from bs4 import BeautifulSoup
except ImportError:
    print("Missing dependencies. Install with:")
    print("  pip install requests beautifulsoup4 browser-cookie3")
    sys.exit(1)


def get_session_from_browser():
    """Try to get AOC session cookie from browser."""
    # Try Zen browser first (Firefox-based, custom location)
    if session := get_session_from_zen():
        return session

    try:
        import browser_cookie3
    except ImportError:
        return None

    # Try Firefox
    try:
        cj = browser_cookie3.firefox(domain_name="adventofcode.com")
        for cookie in cj:
            if cookie.name == "session":
                return cookie.value
    except Exception:
        pass

    # Try Chrome as fallback
    try:
        cj = browser_cookie3.chrome(domain_name="adventofcode.com")
        for cookie in cj:
            if cookie.name == "session":
                return cookie.value
    except Exception:
        pass

    return None


def get_session_from_zen():
    """Get AOC session cookie from Zen browser."""
    import glob
    import shutil
    import sqlite3
    import tempfile

    # Zen stores profiles in ~/Library/Application Support/zen/Profiles/
    zen_profiles = Path.home() / "Library/Application Support/zen/Profiles"
    if not zen_profiles.exists():
        return None

    # Find cookies.sqlite in any profile
    cookie_files = list(zen_profiles.glob("*/cookies.sqlite"))
    if not cookie_files:
        return None

    # Copy to temp file (browser may have it locked)
    for cookie_file in cookie_files:
        try:
            with tempfile.NamedTemporaryFile(delete=False, suffix=".sqlite") as tmp:
                shutil.copy2(cookie_file, tmp.name)
                tmp_path = tmp.name

            conn = sqlite3.connect(tmp_path)
            cursor = conn.cursor()
            cursor.execute(
                "SELECT value FROM moz_cookies WHERE host = '.adventofcode.com' AND name = 'session'"
            )
            row = cursor.fetchone()
            conn.close()
            os.unlink(tmp_path)

            if row:
                return row[0]
        except Exception:
            continue

    return None


def get_session_cookie():
    """Get AOC session cookie from browser, file, or environment."""
    # Try browser first
    if session := get_session_from_browser():
        print("  (using session from browser)")
        return session

    # Check environment variable
    if session := os.environ.get("AOC_SESSION"):
        return session.strip()

    # Check .aoc-session file in script directory
    session_file = Path(__file__).parent / ".aoc-session"
    if session_file.exists():
        return session_file.read_text().strip()

    print("Error: No AOC session cookie found.")
    print("Options:")
    print("  1. Install browser-cookie3: pip install browser-cookie3")
    print("  2. Set AOC_SESSION env var")
    print("  3. Create .aoc-session file with your session cookie")
    sys.exit(1)


def find_year_folder(base_dir: Path, year: int, language: str | None) -> Path:
    """Find existing year folder or create one with specified language."""
    # Look for existing {year}_* folders
    existing = list(base_dir.glob(f"{year}_*"))

    if existing:
        if len(existing) == 1:
            return existing[0]
        # Multiple matches - need language to disambiguate
        if language:
            for folder in existing:
                if folder.name == f"{year}_{language}":
                    return folder
        print(f"Error: Multiple folders found for {year}:")
        for f in existing:
            print(f"  {f.name}")
        print("Please specify the language (e.g., 'zig', 'elixir')")
        sys.exit(1)

    # No existing folder - prompt for language if not provided
    if not language:
        language = input(f"No folder found for {year}. Enter language (e.g., zig, elixir, python): ").strip()
        if not language:
            print("Error: Language required to create new folder")
            sys.exit(1)

    return base_dir / f"{year}_{language}"


def fetch_brief(year: int, day: int, session: str) -> str:
    """Fetch and convert puzzle description to markdown."""
    url = f"https://adventofcode.com/{year}/day/{day}"
    headers = {"Cookie": f"session={session}"}

    response = requests.get(url, headers=headers)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    articles = soup.find_all("article", class_="day-desc")

    if not articles:
        print(f"Error: No puzzle found at {url}")
        sys.exit(1)

    lines = []
    for article in articles:
        lines.append(html_to_text(article))

    return "\n".join(lines)


def html_to_text(element) -> str:
    """Convert HTML article to plain text markdown."""
    result = []

    for child in element.children:
        if child.name == "h2":
            result.append(child.get_text().strip())
            result.append("")
        elif child.name == "p":
            text = child.get_text()
            result.append(text)
            result.append("")
        elif child.name == "pre":
            code = child.get_text()
            result.append(code)
        elif child.name == "ul":
            for li in child.find_all("li"):
                result.append(li.get_text())
        elif child.name is None:
            text = str(child).strip()
            if text:
                result.append(text)

    return "\n".join(result)


def fetch_input(year: int, day: int, session: str) -> str:
    """Fetch puzzle input."""
    url = f"https://adventofcode.com/{year}/day/{day}/input"
    headers = {"Cookie": f"session={session}"}

    response = requests.get(url, headers=headers)
    response.raise_for_status()

    return response.text


def main():
    parser = argparse.ArgumentParser(description="Fetch Advent of Code puzzle data")
    parser.add_argument("year", type=int, help="Puzzle year (e.g., 2025)")
    parser.add_argument("day", type=int, help="Puzzle day (1-25)")
    parser.add_argument(
        "language", nargs="?", default=None,
        help="Language folder suffix (e.g., 'zig' for 2025_zig). Auto-detected if folder exists."
    )
    parser.add_argument(
        "--output", "-o",
        type=Path,
        help="Output directory (overrides year/language detection)"
    )

    args = parser.parse_args()

    if not 1 <= args.day <= 25:
        print("Error: Day must be between 1 and 25")
        sys.exit(1)

    session = get_session_cookie()

    # Determine output directory
    script_dir = Path(__file__).parent
    if args.output:
        out_dir = args.output
    else:
        # Find or create year_language folder
        year_folder = find_year_folder(script_dir, args.year, args.language)
        out_dir = year_folder / "resources" / f"day_{args.day}"

    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"Fetching day {args.day} of {args.year}...")

    # Fetch and save brief
    print("  Fetching puzzle description...")
    brief = fetch_brief(args.year, args.day, session)
    brief_path = out_dir / "brief.md"
    brief_path.write_text(brief)
    print(f"  Saved: {brief_path}")

    # Fetch and save input
    print("  Fetching puzzle input...")
    puzzle_input = fetch_input(args.year, args.day, session)
    input_path = out_dir / "input"
    input_path.write_text(puzzle_input)
    print(f"  Saved: {input_path}")

    print("Done!")


if __name__ == "__main__":
    main()
