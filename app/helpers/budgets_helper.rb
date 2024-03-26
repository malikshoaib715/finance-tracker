module BudgetsHelper
  BAR_CLASSES = { ok: "bg-emerald-500", warning: "bg-amber-500", over: "bg-rose-500" }.freeze

  def budget_bar(budget)
    width = [ (budget.ratio * 100).round, 100 ].min
    tag.div class: "h-2 w-full overflow-hidden rounded-full bg-slate-100",
            role: "progressbar", aria: { valuenow: (budget.ratio * 100).round, valuemin: 0, valuemax: 100 } do
      tag.div class: [ "h-full rounded-full", BAR_CLASSES.fetch(budget.status) ], style: "width: #{width}%"
    end
  end
end
