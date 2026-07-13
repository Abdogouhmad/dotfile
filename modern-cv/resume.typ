#import "@preview/modern-cv:0.10.0": *
#import "@preview/fontawesome:0.6.1"
#let clay = rgb("#3A2B20")
#let sep = box[#h(5pt)#text("|", weight: "bold", baseline: 2pt, fill: clay, stroke: 0.5pt + clay )#h(5pt)]

#show: resume.with(
  author: (
    firstname: "Abderrahman",
    lastname: "Gouhmad",
    email: "gouhmad@hotmail.com",
    homepage: "https://agouhmad.vercel.app",
    phone: "+212 666 123 158",
    github: "Abdogouhmad",
    twitter: "a3bdor7man",
    linkedin: "abdogouhmad",
    address: "Casablanca, Morocco",
    positions: (
      "Software Engineer",
      "Full Stack Developer",
      "Customer Support"
    ),
  ),
  keywords: ("Engineer", "Customer Support"),
  description: "Abderrahman resume",
  profile-picture: none,
  date: datetime.today().display(),
  language: "en",
  colored-headers: true,
  show-footer: false,
  show-address-icon: false,
  paper-size: "us-letter",
  accent-color: clay,

  contact-items-separator: sep,
)

#include "sections/projects.typ"
#include "sections/experience.typ"
#include "sections/skills.typ"
#include "sections/education.typ"
