module CategoriesHelper
  # Full class names so Tailwind's scanner picks them up.
  DOT_CLASSES = {
    "slate" => "bg-slate-500", "red" => "bg-red-500", "orange" => "bg-orange-500", "amber" => "bg-amber-500",
    "lime" => "bg-lime-500", "emerald" => "bg-emerald-500", "teal" => "bg-teal-500", "sky" => "bg-sky-500",
    "indigo" => "bg-indigo-500", "violet" => "bg-violet-500", "pink" => "bg-pink-500"
  }.freeze

  BADGE_CLASSES = {
    "slate" => "bg-slate-100 text-slate-700", "red" => "bg-red-100 text-red-700",
    "orange" => "bg-orange-100 text-orange-700", "amber" => "bg-amber-100 text-amber-800",
    "lime" => "bg-lime-100 text-lime-800", "emerald" => "bg-emerald-100 text-emerald-700",
    "teal" => "bg-teal-100 text-teal-700", "sky" => "bg-sky-100 text-sky-700",
    "indigo" => "bg-indigo-100 text-indigo-700", "violet" => "bg-violet-100 text-violet-700",
    "pink" => "bg-pink-100 text-pink-700"
  }.freeze

  def category_dot(color)
    tag.span class: [ "inline-block h-2.5 w-2.5 rounded-full", DOT_CLASSES.fetch(color, DOT_CLASSES["slate"]) ]
  end

  def category_badge(category)
    tag.span category.name, class: [ "inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium",
                                      BADGE_CLASSES.fetch(category.color, BADGE_CLASSES["slate"]) ]
  end
end
