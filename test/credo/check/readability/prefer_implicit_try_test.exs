defmodule Credo.Check.Readability.PreferImplicitTryTest do
  use Credo.TestHelper

  @described_check Credo.Check.Readability.PreferImplicitTry

  #
  # cases NOT raising issues
  #

  test "it should NOT report implicit use of `try`" do
"""
defmodule ModuleWithImplicitTry do
  def failing_function(first) do
    to_string(first)
  rescue
    _ -> :rescued
  end
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  test "it should NOT report a violation in cases where we need `try`" do
"""
defmodule ModuleWithExplicitTry do
  def failing_function(first) do
    other_function()

    str =
      try do
        to_string(first)
      rescue
        _ -> "rescued"
      end

    to_atom(string)
  end
end
""" |> to_source_file
    |> refute_issues(@described_check)
  end

  #
  # cases raising issues
  #

  test "it should report cases where a `try` block is the entire body of the function" do
"""
defmodule ModuleWithExplicitTry do
  def failing_function(first) do
    try do
      to_string(first)
    rescue
      _ -> :rescued
    end
  end
end
""" |> to_source_file
    |> assert_issue(@described_check)
  end

  test "it should report cases where a `try` block is the entire body of a private function" do
"""
defmodule ModuleWithExplicitTry do
  defp failing_function(first) do
    try do
      to_string(first)
    rescue
      _ -> :rescued
    end
  end
end
""" |> to_source_file
    |> assert_issue(@described_check)
  end

  test "it should report cases where a `try` block is the entire body of macro definition" do
"""
defmodule ModuleWithExplicitTry do
  defmacro failing_function(first) do
    try do
      to_string(unquote(first))
    rescue
      _ -> :rescued
    end
  end
end
""" |> to_source_file
    |> assert_issue(@described_check)
  end

end
