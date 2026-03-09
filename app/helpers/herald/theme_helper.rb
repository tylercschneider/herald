# frozen_string_literal: true

module Herald
  module ThemeHelper
    def herald_accent(key)
      KeystoneUi::AccentColors[key]
    end

    def herald_surface(key)
      KeystoneUi::SurfaceColors[key]
    end

    def herald_accent_link_classes
      "#{herald_accent(:text)} #{herald_accent(:dark_text)} hover:underline"
    end

    def herald_accent_badge_classes
      "#{herald_accent(:badge_bg)} #{herald_accent(:badge_text)} #{herald_accent(:badge_dark_bg)} #{herald_accent(:badge_dark_text)}"
    end

    def herald_accent_focus_classes
      "#{herald_accent(:focus_border)} #{herald_accent(:focus_ring)} #{herald_accent(:dark_focus_border)} #{herald_accent(:dark_focus_ring)}"
    end

    def herald_title_hover_classes
      # Converts accent text classes to group-hover variants
      # e.g. "text-blue-600" → "group-hover:text-blue-600"
      [herald_accent(:text), herald_accent(:dark_text)].map { |c|
        c.split.map { |token| "group-hover:#{token}" }.join(" ")
      }.join(" ")
    end
  end
end
