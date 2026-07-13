#!/usr/bin/env python3
import http.client
import json
import subprocess
import sys
from datetime import datetime

CITY = "Casablanca"
COUNTRY = "Morocco"


def get_prayer_by_city(country, city, date):
    try:
        conn = http.client.HTTPSConnection("api.aladhan.com")
        safe_city = city.replace(" ", "%20")
        safe_country = country.replace(" ", "%20")
        path = f"/v1/timingsByCity/{date}?city={safe_city}&country={safe_country}&state={safe_city}&method=3"
        conn.request("GET", path, headers={"Accept-Encoding": ""})
        response = conn.getresponse()
        data = json.loads(response.read().decode())
        conn.close()
        return data
    except Exception:
        return None


def get_date():
    return datetime.now().strftime("%d-%m-%Y")


def main():
    date = get_date()
    response_data = get_prayer_by_city(COUNTRY, CITY, date)

    if not response_data or response_data.get("code") != 200:
        if len(sys.argv) > 1 and sys.argv[1] in ["--schedule", "--plain"]:
            print("Error: Offline or API issue.")
        else:
            print(json.dumps({"text": "🕌 --:--", "tooltip": "Offline or API Error"}))
        return

    timings = response_data["data"]["timings"]
    core_prayers = {k: timings[k] for k in ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]}

    now = datetime.now()
    current_time = now.time()

    next_prayer = None
    next_prayer_time_str = None

    for name, t_str in core_prayers.items():
        p_time = datetime.strptime(t_str, "%H:%M").time()
        if p_time > current_time:
            next_prayer = name
            next_prayer_time_str = t_str
            break

    if not next_prayer:
        next_prayer = "Fajr"
        next_prayer_time_str = core_prayers["Fajr"]

    time_obj = datetime.strptime(next_prayer_time_str, "%H:%M")
    formatted_12h = time_obj.strftime("%I:%M %p")

    # 1. Handle --schedule flag (For clean Waybar on-click notifications)
    if len(sys.argv) > 1 and sys.argv[1] == "--schedule":
        schedule_lines = [f"Today's Schedule for {CITY}:", "───────────────────"]
        for name, t_str in core_prayers.items():
            marker = "➔ " if name == next_prayer else "  "
            t_12h = datetime.strptime(t_str, "%H:%M").strftime("%I:%M %p")
            schedule_lines.append(f"{marker}{name}: {t_12h}")
        print("\n".join(schedule_lines))
        return

    # 2. Handle --plain flag (For your bash daemon script)
    if len(sys.argv) > 1 and sys.argv[1] == "--plain":
        print(f"{next_prayer} {next_prayer_time_str}")
        return

    # 3. Handle --check flag (For cron/background alerts)
    if len(sys.argv) > 1 and sys.argv[1] == "--check":
        for name, t_str in core_prayers.items():
            if now.strftime("%H:%M") == t_str:
                t_12h = datetime.strptime(t_str, "%H:%M").strftime("%I:%M %p")
                subprocess.run(
                    [
                        "notify-send",
                        "-u",
                        "critical",
                        "-a",
                        "Muezzin",
                        f"Time for {name}",
                        f"It is now time for {name} ({t_12h})",
                    ]
                )
        return

    # Default: Output JSON for Waybar's main bar interface
    tooltip_lines = [f"🕌 Timings for {CITY}:", "-------------------"]
    for name, t_str in core_prayers.items():
        marker = " ➔ " if name == next_prayer else "    "
        t_12h = datetime.strptime(t_str, "%H:%M").strftime("%I:%M %p")
        tooltip_lines.append(f"{marker}{name}: {t_12h}")

    output = {
        "text": f"🕌 {next_prayer} {formatted_12h}",
        "tooltip": "\n".join(tooltip_lines),
    }
    print(json.dumps(output))


if __name__ == "__main__":
    main()
