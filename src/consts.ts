export const SITE = {
  title: "John Fay",
  description: "Software Engineer Manager — building teams and shipping products.",
  author: "John Fay",
  url: "https://keonik.dev",
};

export const NAV_LINKS = [
  { text: "Home", href: "/" },
  { text: "Blog", href: "/blog" },
  { text: "Projects", href: "/projects" },
  { text: "Work", href: "/work" },
] as const;

export const SOCIALS = [
  { name: "GitHub", href: "https://github.com/keonik", icon: "github" },
  { name: "LinkedIn", href: "https://www.linkedin.com/in/johnkfay/", icon: "linkedin" },
  { name: "Email", href: "mailto:john.k.fay@gmail.com", icon: "email" },
] as const;
