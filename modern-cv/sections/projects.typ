#import "@preview/modern-cv:0.10.0": *
#let accent-color = rgb(255, 0, 0)
#let ltx = github-link("Abdgouhmad/ltx")
#let walt = github-link("Abdgouhmad/walt")
= Projects

#resume-entry(
  title: "Rust Latex project manager",
  location: ltx,
  date: "Jun 2026 - Present",
  description: "Developer",
  location-color: accent-color
)

#resume-item[
  - Designed and implemented a robust crates that facilitate `Ltx` cli.
  - Wrote extensive documentation and unit tests for the library and published it on Github.
]

#resume-entry(
  title: "Walt mobile app",
  location: walt,
  date: "Apr. 2026 - Jun. 2026",
  description: "Developer",
  location-color: accent-color,
  accent-color: accent-color
)

#resume-item[
  - Architected declarative UI with Jetpack Compose following Material Design 3.
  - implemented local database to store user preferences and data.
]
