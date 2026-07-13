#import "@preview/modern-cv:0.10.0": *

= Skills

#resume-skill-item("Spoken Languages", (strong("English"), strong("Arabic"), "French"))
#resume-skill-item(
  "Programming Languages",
  (
    strong("Rust"),
    strong("C"),
    strong("Python"),
    strong("Bash"),
    strong("TypeScript"),
    strong("JavaScript"),
    strong("Latex"),
    strong("Typst"),
  ),
)
#resume-skill-item(
  "Frameworks",
  (
    strong("React"),
    strong("Next.js"),
    strong("Svelte"),
    strong("Nuxt.js"),
    strong("Tailwind"),
  ),
)
#resume-skill-item(
  "Programs",
  (
    strong("Excel"),
    "Word",
    "Powerpoint",
    "Visual Studio",
    "git",
    "Zed"
  ),
)
// spacing fix, not needed if you use `resume-skill-grid`
// #block(below: 0.65em)

// An alternative way of list out your resume skills
// #resume-skill-grid(
//   categories-with-values: (
//     "Programming Languages": (
//       strong("C++"),
//       strong("Python"),
//       "Rust",
//       "Java",
//       "C#",
//       "JavaScript",
//       "TypeScript",
//     ),
//     "Spoken Languages": (
//       strong("English"),
//       "Spanish",
//       "Greek",
//     ),
//     "Programs": (
//       strong("Excel"),
//       "Word",
//       "Powerpoint",
//       "Visual Studio",
//       "git",
//       "Zed"
//     ),

//   ),
// )
