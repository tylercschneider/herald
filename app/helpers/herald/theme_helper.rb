# frozen_string_literal: true

module Herald
  module ThemeHelper
    def herald_accent_link_classes
      "text-accent-600 dark:text-accent-400 hover:underline"
    end

    def herald_accent_badge_classes
      "bg-accent-100 text-accent-700 dark:bg-accent-900/50 dark:text-accent-400"
    end

    def herald_accent_inline_link_classes
      "text-sm text-accent-600 hover:text-accent-900 dark:text-accent-400 dark:hover:text-accent-300"
    end

    def herald_accent_focus_classes
      "focus:border-accent-500 focus:ring-accent-500 dark:focus:border-accent-400 dark:focus:ring-accent-400"
    end

    def herald_title_hover_classes
      "group-hover:text-accent-600 group-hover:dark:text-accent-400"
    end
  end
end
