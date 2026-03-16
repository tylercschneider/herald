# frozen_string_literal: true

require "test_helper"

class Herald::ThemeHelperTest < ActionView::TestCase
  include Herald::ThemeHelper

  test "herald_accent_link_classes includes accent text and hover:underline" do
    classes = herald_accent_link_classes

    assert_includes classes, "text-accent-600"
    assert_includes classes, "dark:text-accent-400"
    assert_includes classes, "hover:underline"
  end

  test "herald_title_hover_classes produces group-hover variants" do
    classes = herald_title_hover_classes

    assert_includes classes, "group-hover:text-accent-600"
    assert_includes classes, "group-hover:dark:text-accent-400"
  end

  test "herald_accent_badge_classes includes accent badge colors" do
    classes = herald_accent_badge_classes

    assert_includes classes, "bg-accent-100"
    assert_includes classes, "text-accent-700"
    assert_includes classes, "dark:bg-accent-900/50"
    assert_includes classes, "dark:text-accent-400"
  end

  test "herald_accent_focus_classes includes focus border and ring" do
    classes = herald_accent_focus_classes

    assert_includes classes, "focus:border-accent-500"
    assert_includes classes, "focus:ring-accent-500"
  end

  test "herald_accent_inline_link_classes includes link colors" do
    classes = herald_accent_inline_link_classes

    assert_includes classes, "text-accent-600"
    assert_includes classes, "hover:text-accent-900"
    assert_includes classes, "text-sm"
  end
end
