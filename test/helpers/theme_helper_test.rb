# frozen_string_literal: true

require "test_helper"

class Herald::ThemeHelperTest < ActionView::TestCase
  include Herald::ThemeHelper

  teardown do
    KeystoneUi.reset_configuration!
  end

  test "herald_accent delegates to AccentColors" do
    assert_equal KeystoneUi::AccentColors[:text], herald_accent(:text)
  end

  test "herald_surface delegates to SurfaceColors" do
    assert_equal KeystoneUi::SurfaceColors[:body], herald_surface(:body)
  end

  test "herald_accent_link_classes includes accent text and hover:underline" do
    classes = herald_accent_link_classes

    assert_includes classes, KeystoneUi::AccentColors[:text]
    assert_includes classes, KeystoneUi::AccentColors[:dark_text]
    assert_includes classes, "hover:underline"
  end

  test "herald_title_hover_classes produces group-hover variants" do
    classes = herald_title_hover_classes

    KeystoneUi::AccentColors[:text].split.each do |token|
      assert_includes classes, "group-hover:#{token}"
    end
  end

  test "herald_accent_badge_classes includes accent badge colors" do
    KeystoneUi.configure { |c| c.accent = :emerald }
    classes = herald_accent_badge_classes

    assert_includes classes, "bg-emerald-100"
    assert_includes classes, "text-emerald-700"
    assert_not_includes classes, "bg-blue-100"
  end

  test "herald_accent_focus_classes includes focus border and ring" do
    KeystoneUi.configure { |c| c.accent = :emerald }
    classes = herald_accent_focus_classes

    assert_includes classes, "focus:border-emerald-500"
    assert_includes classes, "focus:ring-emerald-500"
  end

  test "herald_accent_inline_link_classes includes link colors without underline" do
    KeystoneUi.configure { |c| c.accent = :emerald }
    classes = herald_accent_inline_link_classes

    assert_includes classes, "text-emerald-600"
    assert_includes classes, "hover:text-emerald-900"
    assert_not_includes classes, "underline"
  end

  test "colors change when host app configures a custom accent" do
    KeystoneUi.configure do |c|
      c.accent = {
        border: "border-[#A0333D]/20",
        bg: "bg-[#A0333D]/10",
        text: "text-[#D4636D]",
        dark_text: "text-[#D4636D]",
        hover_border: "hover:border-[#A0333D]/50",
        dark_hover_border: "hover:border-[#A0333D]/50",
        hover_text: "hover:text-[#E07A83]",
        dark_hover_text: "hover:text-[#E07A83]"
      }
    end

    assert_equal "text-[#D4636D]", herald_accent(:text)
    assert_includes herald_accent_link_classes, "text-[#D4636D]"
    assert_includes herald_title_hover_classes, "group-hover:text-[#D4636D]"
  end
end
